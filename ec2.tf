# Small EC2 instance in a private subnet: no public IP, no inbound access.

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# Instance role (no IAM users / access keys). SSM core lets Session Manager
# connect once the VPC has a route to SSM (VPC endpoints or NAT).
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance" {
  name               = "${var.instance_name}-role"
  description        = "Instance role for ${var.instance_name}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "instance_ssm" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "instance" {
  name = "${var.instance_name}-profile"
  role = aws_iam_role.instance.name
  tags = local.common_tags
}

resource "aws_security_group" "instance" {
  name        = "${var.instance_name}-sg"
  description = "Security group for ${var.instance_name}: no inbound, HTTPS out within the VPC only"
  vpc_id      = module.vpc.vpc_id
  tags        = local.common_tags
}

resource "aws_vpc_security_group_egress_rule" "instance_https_vpc" {
  security_group_id = aws_security_group.instance.id
  description       = "HTTPS to endpoints inside the VPC"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = var.vpc_cidr
  tags              = local.common_tags
}

resource "aws_instance" "this" {
  ami                         = data.aws_ssm_parameter.al2023_ami.value
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.private_subnets[0]
  vpc_security_group_ids      = [aws_security_group.instance.id]
  iam_instance_profile        = aws_iam_instance_profile.instance.name
  associate_public_ip_address = false
  monitoring                  = true
  ebs_optimized               = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    kms_key_id            = aws_kms_key.stack.arn
    delete_on_termination = true
    tags                  = local.common_tags
  }

  tags = merge(local.common_tags, { Name = var.instance_name })

  lifecycle {
    # Don't replace the instance every time AWS publishes a new AMI.
    ignore_changes = [ami]
  }
}
