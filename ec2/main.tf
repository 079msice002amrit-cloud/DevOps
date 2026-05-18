provider "aws" {
  region = "us-east-1"
}

data "aws_security_group" "sg" {
  filter {
    name   = "group-name"
    values = ["launch-wizard-1"]
  }
}

resource "aws_instance" "ec2" {
  ami                    = "ami-0360c520857e3138f"
  instance_type          = "t2.medium"
  key_name               = "test"
  vpc_security_group_ids = [data.aws_security_group.sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y docker.io docker-compose
              
              # Create docker-compose file
              mkdir -p /home/ubuntu/app
              cat <<EOT >> /home/ubuntu/app/docker-compose.yml
              version: '3'
              services:
                bankapp:
                  image: amritjhamsice/bankapp:main
                  container_name: bankapp
                  ports:
                    - "8080:8080"
                  environment:
                    SPRING_DATASOURCE_URL: jdbc:mysql://database.cvk0yuukotjo.us-east-1.rds.amazonaws.com:3306/bankappdb?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
                    SPRING_DATASOURCE_USERNAME: root
                    SPRING_DATASOURCE_PASSWORD: root12345
                
                phpmyadmin:
                  image: phpmyadmin/phpmyadmin
                  container_name: phpmyadmin
                  restart: always
                  ports:
                    - "8081:80"
                  environment:
                    PMA_HOST: database.cvk0yuukotjo.us-east-1.rds.amazonaws.com
                    PMA_PORT: 3306
                    MYSQL_ROOT_PASSWORD: root12345
              EOT

              chown -R ubuntu:ubuntu /home/ubuntu/app
              EOF

  tags = {
    Name = "deployment-server"
  }
}