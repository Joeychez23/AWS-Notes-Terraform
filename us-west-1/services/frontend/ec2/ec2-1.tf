resource "aws_instance" "vm-1" {
  ami           = "ami-075b24c34725edbe7"
  subnet_id     = "subnet-00f1d33f4e5c96f6a"
  instance_type = "t3.micro"
  count = 1
  tags = {
    Name = "terraform-testing"
  }
  security_groups = ["sg-0e2b9f86c2056b33f"]
  key_name = "AWS-REACT"

  user_data = <<-EOF
  #!/bin/bash
  apt-get update
  source ~/.nvm/nvm.sh
  cd /etc/nginx/sites-available
  echo server { > default
  echo listen 80\; >> default
  echo server_name _\; >> default
  echo location / { >> default
  echo proxy_pass http://$(curl http://169.254.169.254/latest/meta-data/local-ipv4):8080\; >> default
  echo proxy_http_version 1.1\; >> default
  echo proxy_set_header Upgrade \$http_upgrade\; >> default
  echo proxy_set_header Connection \’upgrade’\; >> default
  echo proxy_set_header Host \$host\; >> default
  echo proxy_cache_bypass \$http_upgrade\; >> default
  echo } } >> default
  systemctl restart nginx
  cd ..
  cd ..
  cd ..
  cd root
  npm install forever -g
  npm install forever-monitor
  cd bookstore
  npm install
  forever start -c "npm start" ./
  EOF
}