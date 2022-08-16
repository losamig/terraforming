
output "speedy1_public_ip_address" {
  value = azurerm_linux_virtual_machine.speedy1.public_ip_address
}

output "speedy1_tls_private_key" {
  value     = local_file.speedy1_key.filename
}