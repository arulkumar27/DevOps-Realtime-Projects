output "instance_id" {
  value = aws_instance.controller.id
}

output "public_ip" {
  value = aws_instance.controller.public_ip
}

output "private_ip" {
  value = aws_instance.controller.private_ip
}

output "ubuntu_ami_id" {
  value = data.aws_ami.ubuntu.id
}