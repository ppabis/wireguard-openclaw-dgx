data "aws_ssm_parameter" "al2023_arm64" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

resource "aws_security_group" "wireguard" {
  name_prefix = "wireguard-sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port        = 51280
    to_port          = 51280
    protocol         = "udp"
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  } 
}

locals {
  user_data = templatefile("user-data.yaml", {peers = []})
}

resource "aws_instance" "wireguard" {
  ami                         = data.aws_ssm_parameter.al2023_arm64.value
  instance_type               = "t4g.nano"
  iam_instance_profile        = aws_iam_instance_profile.wireguard.name
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.wireguard.id]
  associate_public_ip_address = false
  ipv6_address_count          = 1
  source_dest_check           = false

  user_data = local.user_data

  tags = { Name = "Wireguard" }
  lifecycle { ignore_changes = [ami] }
}

output "ipv6" {
  value = aws_instance.wireguard.ipv6_addresses[0]
}