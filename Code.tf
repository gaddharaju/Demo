# Configure the Azure provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "app_rg" {
  name     = "myapp-resource-group"      # Specify the name of the resource group
  location = "West US"                   # Set the location for the resource group
}

# Create a public IP address
resource "azurerm_public_ip" "app_public_ip" {
  name                = "myapp-public-ip"    # Specify the name of the public IP
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name
  allocation_method   = "Static"             # Choose between "Static" or "Dynamic" allocation
}

# Create a network security group
resource "azurerm_network_security_group" "app_nsg" {
  name                = "myapp-nsg"           # Specify the name of the NSG
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name
}

# Create an inbound security rule to allow HTTP traffic
resource "azurerm_network_security_rule" "http_rule" {
  name                        = "http-rule"            # Specify the name of the rule
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.app_rg.name
  network_security_group_name = azurerm_network_security_group.app_nsg.name
}

# Create a virtual network
resource "azurerm_virtual_network" "app_vnet" {
  name                = "myapp-vnet"                 # Specify the name of the virtual network
  address_space       = ["10.0.0.0/16"]              # Define the IP address range for the VNet
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name
}

# Create a subnet within the virtual network
resource "azurerm_subnet" "app_subnet" {
  name                 = "myapp-subnet"              # Specify the name of the subnet
  resource_group_name  = azurerm_resource_group.app_rg.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = ["10.0.1.0/24"]             # Define the IP address range for the subnet
}

# Create a network interface and associate it with the subnet and NSG
resource "azurerm_network_interface" "app_nic" {
  name                = "myapp-nic"                  # Specify the name of the network interface
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name

  ip_configuration {
    name                          = "myapp-ipconfig"  # Specify the name of the IP configuration
    subnet_id                     = azurerm_subnet.app_subnet.id
    private_ip_address_allocation = "Dynamic"        # Allocate IP address dynamically
    public_ip_address_id          = azurerm_public_ip.app_public_ip.id
  }

  network_security_group_id = azurerm_network_security_group.app_nsg.id
}

# Create a virtual machine and associate it with the network interface
resource "azurerm_virtual_machine" "app_vm" {
  name                  = "myapp-vm"                   # Specify the name of the virtual machine
  location              = azurerm_resource_group.app_rg.location
  resource_group_name   = azurerm_resource_group.app_rg.name
  network_interface_ids = [azurerm_network_interface.app_nic.id]
  vm_size               = "Standard_DS1_v2"            # Specify the size of the virtual machine

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myapp-osdisk"                 # Specify the name of the OS disk
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "myapp-vm"                        # Specify the computer name of the VM
    admin_username = "adminuser"                       # Set the admin username for the VM
    admin_password = "Password1234!"                   # Set the admin password for the VM
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "echo 'Hello World' | sudo tee /var/www/html/index.html",
      "sudo systemctl start nginx"
    ]
  }
}

# Output the public IP address for accessing the deployed application
output "public_ip_address" {
  value = azurerm_public_ip.app_public_ip.ip_address
}
