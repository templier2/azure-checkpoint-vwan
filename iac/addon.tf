locals {
  regex_second_frontend_subnet_prefix = regex(local.regex_valid_network_cidr, var.second_frontend_subnet_prefix) == var.second_frontend_subnet_prefix ? 0 : "Variable [second_frontend_subnet_prefix] must be a valid address in CIDR notation."
  // Will fail if var.second_frontend_subnet_prefix is invalid
}

variable "second_frontend_subnet_prefix" {
  description = "Address prefix to be used for network frontend subnet"
  type        = string
}

variable "delay" {
  description = "Time required to wait before configuration of Management server"
  type        = string
}

resource "time_sleep" "configuration_pause" {
  depends_on = [
    azurerm_managed_application.nva,
    azurerm_virtual_machine.single-gateway-vm-instance,
    azurerm_virtual_machine.mgmt-vm-instance
  ]

  create_duration = var.delay
}

resource "null_resource" "mgmt_import_gw" {
  depends_on = [time_sleep.configuration_pause]
  connection {
    type     = "ssh"
    host     = azurerm_public_ip.public-ip.ip_address
    user     = "admin"
    password = var.admin_password
    timeout  = "5m"
  }

  provisioner "remote-exec" {
    on_failure = fail
    inline = [
      "mgmt_cli -r true add simple-gateway name ${var.single_gateway_name} ipv4-address ${azurerm_public_ip.gw-public-ip1.ip_address} one-time-password ${var.sic_key} interfaces.0.name 'eth0' interfaces.0.anti-spoofing false interfaces.0.ip-address ${azurerm_network_interface.gw-nic.private_ip_address} interfaces.0.ipv4-mask-length ${var.gw_netmask_length} interfaces.0.topology 'EXTERNAL' interfaces.1.name 'eth1' interfaces.1.anti-spoofing false interfaces.1.ip-address ${azurerm_network_interface.gw-nic1.private_ip_address} interfaces.1.ipv4-mask-length ${var.gw_netmask_length} interfaces.2.name 'eth2' interfaces.2.anti-spoofing false interfaces.2.ip-address ${azurerm_network_interface.gw-nic2.private_ip_address} interfaces.2.ipv4-mask-length ${var.gw_netmask_length}",
      local.nva_cli
    ]
  }
}
