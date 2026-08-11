# Trust policy allowing only the EC2 service to assume this role.
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    sid     = "AllowEC2AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM role assigned to private application instances.
resource "aws_iam_role" "application" {
  name               = "${var.name_prefix}-application-role"
  description        = "Least-privilege role used by application EC2 instances"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-application-role"
    }
  )
}

# Allows instances to register with AWS Systems Manager.
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.application.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Allows the CloudWatch agent to publish logs and metrics.
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.application.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Instance profile connects the IAM role to EC2 launch templates.
resource "aws_iam_instance_profile" "application" {
  name = "${var.name_prefix}-application-profile"
  role = aws_iam_role.application.name

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-application-profile"
    }
  )
}