

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.51.0"
    }
  }
}

terraform { 

  backend "azurerm" { 

  } 
} 



provider "azurerm" {
  features {

  }
}

resource "azurerm_resource_group" "RG1" {
  name     = var.RgName
  location = var.RGlocation

tags = {
 project ="learning"
 env = "dev"

}

}

resource "azurerm_virtual_network" "myvnet" {
  name                = var.vnetName
  address_space       = var.vnetAddress
  location            = azurerm_resource_group.RG1.location
  resource_group_name = azurerm_resource_group.RG1.name

tags = {
 project ="learning"
 env = "dev"

}

}

resource "azurerm_subnet" "mysnet" {
  count                = length(var.subnet_address_prefixes)
  name                 = element(var.subnetnames, count.index)
  resource_group_name  = azurerm_resource_group.RG1.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes     = [var.subnet_address_prefixes[count.index]]
  service_endpoints    = ["Microsoft.Storage"]



}
resource "azurerm_network_interface" "nics" {
  count               = length(var.privateaddresses)
  name                = element(var.nicnames, count.index)
  resource_group_name = azurerm_resource_group.RG1.name
  location            = azurerm_resource_group.RG1.location
  ip_configuration {
    name                          = element(var.ipconfignames, count.index)
    subnet_id                     = azurerm_subnet.mysnet[count.index].id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.privateaddresses[count.index]
  }
tags = {
 project ="learning"
 env = "dev"
}

}

resource "azurerm_public_ip" "pip" {
  name                = var.pubip
  location            = azurerm_resource_group.RG1.location
  resource_group_name = azurerm_resource_group.RG1.name
  allocation_method   = "Static"
  sku                 = "Standard"

tags = {
 project ="learning"
 env = "dev"
}

}

resource "azurerm_bastion_host" "bhost" {
  name                = var.basthost
  location            = azurerm_resource_group.RG1.location
  resource_group_name = azurerm_resource_group.RG1.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.mysnet[2].id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
tags = {
 project ="learning"
 env = "dev"

}

}

resource "random_password" "password" {
  length           = 8
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_linux_virtual_machine" "vms" {
  count                           = length(var.vmnames)
  name                            = element(var.vmnames, count.index)
  resource_group_name             = azurerm_resource_group.RG1.name
  location                        = azurerm_resource_group.RG1.location
  size                            = "Standard_B2s"
  admin_username                  = element(var.vmunames, count.index)
  admin_password                  = azurerm_key_vault_secret.passwordsecret.value
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.nics[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }


  source_image_reference {
    publisher = element(var.vm_os, count.index) == "UbuntuServer" ? var.ubuntu_publisher : var.centos_publisher
    offer     = element(var.vm_os, count.index) == "UbuntuServer" ? var.ubuntu_offer : var.centos_offer
    sku       = element(var.vm_os, count.index) == "UbuntuServer" ? var.ubuntu_sku : var.centos_sku
    version   = element(var.vm_os, count.index) == "UbuntuServer" ? "latest" : "latest"
  }
tags = {
 project ="learning"
 env = "dev"

}

}
resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage
  resource_group_name      = azurerm_resource_group.RG1.name
  location                 = azurerm_resource_group.RG1.location
  account_tier             = "Standard"
  account_replication_type = var.replitype
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = azurerm_subnet.mysnet[*].id

  }

tags = {
 project ="learning"
 env = "dev"

}

}


resource "azurerm_key_vault" "myvault" {
  name                = var.keyvaults
  resource_group_name = azurerm_resource_group.RG1.name
  location            = azurerm_resource_group.RG1.location
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = true

  purge_protection_enabled = false
 
tags = {
 project ="learning"
 env = "dev"
}

}

locals {
objectIds = {
currentid = data.azurerm_client_config.current.object_id
myid= var.myObjectId
adoid= var.ADO_Service_Account_ObjectId
}
}

resource "azurerm_key_vault_access_policy" "koushikPolicy" {
for_each= local.objectIds
key_vault_id= azurerm_key_vault.myvault.id
tenant_id= data.azurerm_client_config.current.tenant_id
object_id= each.value
secret_permissions = ["Get", "Set", "List", "Delete", "Recover", "Restore", "Set", "Purge"]
depends_on=[azurerm_key_vault.myvault]

}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault_secret" "passwordsecret" {
  name         = var.secretkeys
  value        = random_password.password.result 
  key_vault_id = azurerm_key_vault.myvault.id
depends_on=[azurerm_key_vault_access_policy.koushikPolicy]
}