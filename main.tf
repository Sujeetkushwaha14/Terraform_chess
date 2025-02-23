provider "aws" {
  region = "ap-south-1"
}
resource "aws_key_pair" "key_pair" {
  key_name   = "my-key-pair"             # Change this to your preferred key name
  public_key = file("~/.ssh/id_rsa.pub") # Path to your public key for SSH access
}

resource "aws_instance" "example" {
  ami             = "ami-00bb6a80f01f03502" # Use your preferred Ubuntu AMI
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.key_pair.key_name
  security_groups = ["default"]
  # Install Docker and Docker Compose, then create and start docker-compose.yml
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://get.docker.com -o get-docker.sh
              sudo sh get-docker.sh
              sudo usermod -aG docker ubuntu
              sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose

              # Create a docker-compose.yml file
              echo "version: '3'
              services:
                web:
                  image: nginx
                  ports:
                    - '80:80'
              " > /home/ubuntu/docker-compose.yml

              # Change ownership to the ubuntu user
              sudo chown ubuntu:ubuntu /home/ubuntu/docker-compose.yml

              # Run docker-compose up
             
              sudo apt install -y git
              git clone https://github.com/Sujeetkushwaha14/Chess-app.git /var/www/html
              cd /var/www/html/AI_chess
              sudo docker-compose up
 
 
              EOF

  tags = {
    Name = "Instance"
  }
}
output "instance_ip" {
  value = aws_instance.example.public_ip
}