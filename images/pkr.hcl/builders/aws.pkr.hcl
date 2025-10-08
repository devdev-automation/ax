variable "golang_version" {
  type = string
}

variable "variant" {
  type = string
}

variable "op_random_password" {
  type = string
}

variable "snapshot_name" {
  type = string
}

variable "default_disk_size" {
  type    = number
  default = 20
}

source "amazon-ebs" "packer" {
  #access_key = var.aws_access_key
  #secret_key = var.aws_secret_access_key
  region     = var.region
  ami_name   = var.snapshot_name
  instance_type = var.default_size
  security_group_id = var.security_group_id
  associate_public_ip_address = true
  ssh_interface = "private_ip"

  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
    http_put_response_hop_limit = 1
  }
  imds_support  = "v2.0" # enforces imdsv2 support on the resulting AMI

  subnet_filter {
    filters = {
      "tag:Name": "Assessment Operations"
    }
  }

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_type           = "gp2"
    volume_size           = var.default_disk_size
    encrypted             = true
    delete_on_termination = true
  }

  source_ami_filter {
    filters = {
      "virtualization-type" = "hvm"
      "name"                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      "root-device-type"     = "ebs"
    }
    owners      = ["099720109477"]
    most_recent = true
  }

  ssh_username           = "ubuntu"
  temporary_key_pair_type = "ed25519"
}

build {
  sources = ["source.amazon-ebs.packer"]

