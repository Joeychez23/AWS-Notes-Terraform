# AWS Notes + Terraform

AWS study notes, plus the Terraform written while learning to host Node apps
on EC2. The Terraform builds a public network in **us-west-1**, an Application
Load Balancer with HTTP and HTTPS target groups, and an Auto Scaling group
whose launch template sets up Nginx as a reverse proxy in front of the app.
The Nginx and Certbot notes behind that setup are included too.

## Contents

| Path | What it is |
| --- | --- |
| `Nginx-config/AWS Notes.pdf` | Cloud Practitioner–style notes on about 80 AWS services and concepts: scaling, serverless, networking, security and compliance, databases, Well-Architected pillars, pricing models, and support plans |
| `Nginx-config/HTTP/` | EC2 setup without Nginx: nvm + Node, an `iptables` redirect from 80/443 to the app port, MongoDB 5 on Amazon Linux 2, and `pm2` |
| `Nginx-config/HTTPS/` | Ubuntu 20.04 + Nginx reverse proxy + Let's Encrypt (Certbot) walkthrough, with screenshots of the `default` site file and certificate location, and the reference video |
| `Nginx-config/nginx-default-config.txt` | Minimal `/etc/nginx/sites-available/default`: port 80 → Node on `:8080`, with WebSocket upgrade headers |
| `Nginx-config/bootstrap.txt` | EC2 user-data script used for [Tone Radar](https://tone-radar.aws-prac-route53.com/): writes the Certbot-managed HTTPS server block, adds the load-balancer health-check path, pulls the repo, and starts the app with `forever` |
| `Nginx-config/Screen Shot *.png` | Course reference images: a VPC diagram (subnets, NACL, route table, internet gateway, peering) and common ports (22, 3389, 80, 443) |
| `global/s3/` | Placeholder for a remote-state bucket (empty) |
| `us-west-1/1-network/` | VPC, internet gateway, subnets, route table associations |
| `us-west-1/services/backend/` | Security group, ALB, target groups, listeners, launch template, Auto Scaling group |
| `us-west-1/services/frontend/ec2/` | Two standalone EC2 instances with inline Nginx user data (`save.txt` is an earlier 5-instance version) |

## How the Terraform is organized

Each folder is its **own Terraform root** with its own local state. The
layers don't share state. A later layer finds the resources from earlier
layers with `data` sources, by name or `Name` tag (default VPC, subnets
`us-west-1a`/`us-west-1b`, security group `AWS-PRAC-SEC`, ALB `PRAC-BALANCE`,
target groups `http-tg`/`https-tg`, launch template `default-template`).
That means the layers have to be applied in order:

```
us-west-1/1-network/
  1-vpc                     Adopt the default VPC (aws_default_vpc)
  2-internet-gateway        Internet gateway "default-gateway"; adopt the default route table
  3-subnets                 Public subnets 172.31.0.0/20 (us-west-1a) and 172.31.16.0/20 (us-west-1b); 0.0.0.0/0 → IGW
  4-explicit-associations   Associate both subnets with the route table

us-west-1/services/backend/
  1-security-group          AWS-PRAC-SEC: inbound 22, 80, 443; all outbound
  2-alb-init                Internet-facing ALB across both subnets (deletion protection on)
  3-alb-target-groups       http-tg (:80) and https-tg (:443) with health checks
  4-alb-listener            :443 HTTPS (ACM cert, TLS 1.3 policy) → https-tg; :80 → http-tg
  launch_templates          t2.micro, key pair AWS-REACT, 16 GB gp2, Nginx user data
  auto_scaling_group        min 1 / desired 1 / max 2, ELB health checks, instances replaced every 7 days
```

### How a request reaches the app

```
client ──▶ ALB :443 (ACM cert) ──▶ https-tg ──▶ EC2 :443 Nginx (Let's Encrypt cert) ──▶ Node app :8080
client ──▶ ALB :80 ──────────────▶ http-tg  ──▶ EC2 :80  Nginx ──▶ 301 redirect to HTTPS
```

The launch template's user data (base64 in `launch_templates/main.tf`;
readable versions are in `Nginx-config/`) rewrites the Nginx `default` site
when an instance boots:

- HTTPS server block for the domain, proxying to the instance's private IP
  on port 8080. It gets the IP from the instance metadata endpoint.
- A dedicated health-check location that returns `302`, which the HTTPS
  target group expects as healthy
- A port 80 block that redirects the domain to HTTPS and returns `404` for
  anything else. The HTTP target group's `/healthcheck` expects that `404`.

It then restarts Nginx and starts the app with `forever`. The script expects
an AMI that already has nvm/Node, Nginx, the Let's Encrypt certificates, and
the app checked out under `/root`.

## Usage

Prerequisites:

- AWS credentials for us-west-1 and Terraform (AWS provider 5.x)
- EC2 key pair `AWS-REACT`
- An ACM certificate for the domain, issued in us-west-1
- A prepared AMI as described above. The AMI id, subnet ids, and
  security-group ids in these files are specific to the original account.

Apply each folder in the order above:

```bash
cd us-west-1/1-network/1-vpc
terraform init
terraform apply
```

To tear down, destroy in reverse order. The ALB has deletion protection on,
so set `enable_deletion_protection = false` and apply that change before
destroying it.

State files (`*.tfstate`), lock files, `.terraform/` folders, and `.pem` keys
are git-ignored and stay local.
