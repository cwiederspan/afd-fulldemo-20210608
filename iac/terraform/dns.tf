locals {
  www_dns_prefix   = "www"
  afd_www_dns_name = "${local.www_dns_prefix}.${var.root_dns_name}"
  afd_fqdn         = "${local.afd_name}.azurefd.net"
}

resource "azurerm_dns_zone" "dns" {
  name                = var.root_dns_name
  resource_group_name = azurerm_resource_group.rg.name
}

# resource "azurerm_dns_a_record" "www" {
#   name                = local.www_dns_prefix
#   zone_name           = azurerm_dns_zone.dns.name
#   resource_group_name = azurerm_resource_group.rg.name
#   ttl                 = 300
#   records             = [ azurerm_public_ip.ip.ip_address ]
# }

resource "azurerm_dns_cname_record" "www" {
  name                = local.www_dns_prefix
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  record              = "${local.afd_name}.azurefd.net"
}

resource "azurerm_dns_cname_record" "afdverify" {
  name                = "afdverify"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  record              = "afdverify.${local.afd_fqdn}"
}