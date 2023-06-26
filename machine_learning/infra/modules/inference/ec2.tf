resource "aws_instance" "inference_vm" {
  ami           = "ami-01e8572ea33b21308"
  instance_type = "m5d.2xlarge"
  key_name      = "editor-ai-platform-key"
  user_data     = <<-EOF
                #!/bin/bash
                sudo apt-get update
                sudo apt-get install -y git
                git clone https://github.com/reda-maizate/moment_detr.git
                cd /moment_detr
                aws ecr-public get-login-password --region ${var.region} | docker login --username AWS --password-stdin public.ecr.aws/${local.account_id}
                echo "export REDIS_HOST=${var.redis_host}" >> ~/.bashrc
                echo "export REDIS_USERNAME=${var.redis_username} >> ~/.bashrc
                echo "export REDIS_PASSWORD=${var.redis_password} >> ~/.bashrc
                echo "export AWS_REGION=${var.region} >> ~/.bashrc
                echo "export SQS_QUEUE_NAME=${var.sqs_queue_name} >> ~/.bashrc
                source ~/.bashrc
                EOF

  #    vpc_security_group_ids = [aws_security_group.service_security_group.id]
  subnet_id = aws_subnet.public.1.id # D'abord lancer celui là puis mettre à jour avec le vpc (voir ligne au dessus)
  root_block_device {
    volume_size           = 100
    volume_type           = "gp2"
    delete_on_termination = true
  }
}
