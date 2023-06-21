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

# Configure the Azure provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "example1" {
  name     = "resource-group"      # Specify the name of the resource group
  location = "West US"                     # Set the location for the resource group
}

# Create a virtual network
resource "azurerm_virtual_network" "example2" {
  name                = "example-vnet"                     # Specify the name of the virtual network
  address_space       = ["10.0.0.0/16"]                    # Define the IP address range for the VNet
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Create a subnet within the virtual network
resource "azurerm_subnet" "example3" {
  name                 = "example-subnet"                  # Specify the name of the subnet
  resource_group_name  = azurerm_resource_group.example1.name
  virtual_network_name = azurerm_virtual_network.example2.name
  address_prefixes     = ["10.0.1.0/24"]                   # Define the IP address range for the subnet
}

# Create a public IP address
resource "azurerm_public_ip" "example3" {
  name                = "example-public-ip"                # Specify the name of the public IP
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example1.name
  allocation_method   = "Static"                           # Choose between "Static" or "Dynamic" allocation

  tags = {
    environment = "dev"
  }
}

# Create a network interface and associate it with the subnet and public IP
resource "azurerm_network_interface" "example4" {
  name                = "example-nic"                      # Specify the name of the network interface
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example1.name

  ip_configuration {
    name                          = "example-ipconfig"      # Specify the name of the IP configuration
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"              # Allocate IP address dynamically
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

# Create a virtual machine and associate it with the network interface
resource "azurerm_virtual_machine" "example" {
  name                  = "example-vm"                      # Specify the name of the virtual machine
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = "Standard_DS1_v2"                 # Specify the size of the virtual machine

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "example-osdisk"                    # Specify the name of the OS disk
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "examplevm"                            # Specify the computer name of the VM
    admin_username = "adminuser"                            # Set the admin username for the VM
    admin_password = "Password1234!"                        # Set the admin password for the VM
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# Output the public IP address for accessing the VM
output "public_ip_address" {
  value = azurerm_public_ip.example.ip_address
}
