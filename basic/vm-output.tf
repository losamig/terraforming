
output "speedy1_public_ip_address" {
  value = azurerm_linux_virtual_machine.speedy1.public_ip_address
}

output "speedy1_tls_private_key" {
  value     = tls_private_key.speedy1.private_key_pem
  sensitive = true
}