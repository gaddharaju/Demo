variable "RgName" {

  type        = string
  description = "name of the resource"
  default     = "BabuRG"
}

variable "RGlocation" {
  type        = string
  description = "location of the resource "
  default     = "eastus"
}
variable "vnetName" {
  type        = string
  description = "name of the resource "
  default     = "babu-network"
}
variable "vnetAddress" {
  type        = list(string)
  description = " vnet address"
  default     = ["192.168.0.0/16"]
}

variable "subnet_address_prefixes" {
  type    = list(string)
  default = ["192.168.0.0/26", "192.168.0.64/26", "192.168.0.128/26"]
}

variable "subnetnames" {
  type    = list(string)
  default = ["babusubnet1", "babusubnet2", "AzureBastionSubnet"]
}

variable "nicnames" {
  type    = list(string)
  default = ["babunic1", "babunic2"]
}

variable "privateaddresses" {
  type    = list(string)
  default = ["192.168.0.42", "192.168.0.100"]
}

variable "pubip" {
  type    = string
  default = "babupublicip"
}
variable "basthost" {
  type    = string
  default = "babubastion"
}

variable "vm_os" {
  description = "Operating System for the VMs"
  type        = list(string)
  default     = ["UbuntuServer", "CentOs"]
}

variable "vmnames" {
  type    = list(string)
  default = ["babuvm1", "babuvm2"]
}

variable "vmunames" {
  type    = list(string)
  default = ["babu", "babudp"]
}


variable "ipconfignames" {
  type    = list(string)
  default = ["nic1-ipconfig1", "nic2-ipconfig2"]

}
variable "storage" {
  type    = string
  default = "babustorageaccount123"

}

variable "replitype" {
  type    = string
  default = "LRS"
}

variable "ubuntu_publisher" {
  description = "Publisher for Ubuntu Server image"
  type        = string
  default     = "Canonical"
}

variable "ubuntu_offer" {
  description = "Offer for Ubuntu Server image"
  type        = string
  default     = "UbuntuServer"
}

variable "ubuntu_sku" {
  description = "SKU for Ubuntu Server image"
  type        = string
  default     = "18.04-LTS"
}

variable "centos_publisher" {
  description = "Publisher for CentOS image"
  type        = string
  default     = "OpenLogic"
}

variable "centos_offer" {
  description = "Offer for CentOS image"
  type        = string
  default     = "CentOS"
}

variable "centos_sku" {
  description = "SKU for CentOS image"
  type        = string
  default     = "7.7"
}

variable "container"{
type=string
default="babu-container"

}

variable "keyvaults"{
type= string
default="babu-vaultf"

}

variable "secretkeys" {
type=string
default="babu-secret"
}


variable "myObjectId" {
type=string
default="439b602a-a78d-47b5-93d2-adc7c0b96814"

}

variable "ADO_Service_Account_ObjectId"{
type=string
default= "7991a281-33bb-455a-9eb8-fe8ece4f0857"

}
