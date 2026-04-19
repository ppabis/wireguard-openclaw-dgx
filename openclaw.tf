data "aws_ssm_parameter" "ubuntu_2404" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/arm64/hvm/ebs-gp3/ami-id"
}

resource "aws_security_group" "agent" {
  name   = "openclaw-agent-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.155.222.0/24"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "agent" {
  ami           = data.aws_ssm_parameter.ubuntu_2404.value
  instance_type = "t4g.medium"
  user_data     = file("openclaw.yaml")
  tags          = { Name = "openclaw-agent" }

  subnet_id                   = module.vpc.private_subnets[0]
  vpc_security_group_ids      = [aws_security_group.agent.id]
  associate_public_ip_address = false
  ipv6_address_count          = 1

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  lifecycle { ignore_changes = [ami] }
}

output "private_ip" {
  value = aws_instance.agent.private_ip
}