# Define the Azure provider
# TEST CODE
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "myResourceGroup"
  location = "East US"
}

# Create a virtual network
resource "azurerm_virtual_network" "example" {
  name                = "myVirtualNetwork"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Create a subnet within the virtual network
resource "azurerm_subnet" "example" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a virtual machine
resource "azurerm_windows_virtual_machine" "example" {
  name                  = "myVM"
  resource_group_name   = azurerm_resource_group.example.name
  location              = azurerm_resource_group.example.location
  size                  = "Standard_DS2_v2"
  admin_username        = "yourusername"
  admin_password        = "yourpassword"
  network_interface_ids = [azurerm_network_interface.example.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  computer_name = "myVM"
  admin_password = "yourpassword"
  admin_username = "yourusername"

  tags = {
    environment = "development"
  }
}

# Create a network interface for the virtual machine
resource "azurerm_network_interface" "example" {
  name                = "myVM-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Output the public IP address of the virtual machine
output "vm_public_ip" {
  value = azurerm_windows_virtual_machine.example.network_interface_ids[0]
}
