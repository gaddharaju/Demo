# Configure the Azure provider
provider "azurerm" {
  features {}
}

# Create a resource group to contain the resources
resource "azurerm_resource_group" "example" {
  name     = "example-resource-group"      # Specify the name of the resource group
  location = "West US"                     # Set the location for the resource group
}

# Create a virtual network
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"                     # Specify the name of the virtual network
  address_space       = ["10.0.0.0/16"]                    # Define the IP address range for the VNet
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Create a subnet within the virtual network
resource "azurerm_subnet" "example" {
  name                 = "example-subnet"                  # Specify the name of the subnet
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]                   # Define the IP address range for the subnet
}

# Create a network interface within the resource group and virtual network
resource "azurerm_network_interface" "example" {
  name                = "example-nic"                      # Specify the name of the network interface
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "example-ipconfig"      # Specify the name of the IP configuration
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"              # Allocate IP address dynamically
  }
}

# Create a virtual machine within the resource group and attach the network interface
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
