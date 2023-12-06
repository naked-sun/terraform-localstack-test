stack_name = "testapp"

region             = "eu-west-1"
availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

vpc_cidr = "192.168.0.0/16"
# For the subnet CIDRs, I thought calculating them automatically with the `cidrsubnets` built-in function.
# See: https://developer.hashicorp.com/terraform/language/functions/cidrsubnets
# But the issue is that the logic to have 3 independent groups of subnets with independent sizes could increase the
# amount of code considerably and the complexity, adding more time to the delivery. I'll add as a nice to have.
# network_prefix = "172.16"
public_subnet_cidrs   = ["192.168.0.0/24", "192.168.1.0/24", "192.168.2.0/24"]
private_subnet_cidrs  = ["192.168.10.0/24", "192.168.11.0/24", "192.168.12.0/24"]
database_subnet_cidrs = ["192.168.20.0/24", "192.168.21.0/24", "192.168.22.0/24"]


# This is an Ubuntu image id, the ansible playbooks are prepared for ubuntu. To change distribution will require
# some refactoring in the ansible playbook and the user-data for the instance definition.
backend_ami_id = "ami-0694d931cee176e7d"

# Public IP allowed to SSH into the bastion instance.
# Could be checked with whatismyip or similar.
remote_admin_ip = ""
