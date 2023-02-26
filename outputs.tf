# output "public_ip" {
#   description = "Public IP"
#   value = aws_instance.my_server[*].public_ip
# }

output "public_ip_east_ssh" {
  description = "Public IP"
  value = aws_instance.my_east_ssh_server[*].public_ip
}

# output "public_ip_west" {
#   description = "Public IP"
#   value = aws_instance.my_west_server[*].public_ip
# }