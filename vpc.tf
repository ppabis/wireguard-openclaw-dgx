data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.6.0"

  name = "my-vpc"
  cidr = "10.189.80.0/21"

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets  = ["10.189.80.0/24", "10.189.81.0/24", "10.189.82.0/24"]
  private_subnets = ["10.189.83.0/24", "10.189.84.0/24", "10.189.85.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = false

  enable_ipv6                                    = true
  public_subnet_assign_ipv6_address_on_creation  = true
  private_subnet_assign_ipv6_address_on_creation = true
  public_subnet_ipv6_prefixes                    = [0, 1, 2]
  private_subnet_ipv6_prefixes                   = [3, 4, 5]

  private_subnet_tags = { type = "private" }
  public_subnet_tags  = { type = "public" }
}

resource "aws_route" "wireguard_tunnel_prefix" {
  for_each = toset(
    concat(
      module.vpc.private_route_table_ids,
      module.vpc.public_route_table_ids
    )
  )

  route_table_id         = each.value
  destination_cidr_block = "10.155.222.0/24"
  network_interface_id   = aws_instance.wireguard.primary_network_interface_id
}
