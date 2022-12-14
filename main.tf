#Directory = /home/snowcpg_poc/terraform/VMware/VM1
#File1 = vmware_simple_vm_template.tf
#File2 = vmware_simple_vm_variable.tf

#File =vmware_simple_vm_template.tf
provider "vsphere" {
  user           = var.user
  password       = var.password
  vsphere_server = var.host

  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.region
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
# name          = var.cluster/Resources
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network_interface
  datacenter_id = data.vsphere_datacenter.dc.id
}
# Retrieve template information on vsphere
data "vsphere_virtual_machine" "template" {
  name          = var.templateName
  datacenter_id = data.vsphere_datacenter.dc.id
}


## resource "vsphere_virtual_disk" "myDisk" {
#  size         = 30
#  vmdk_path    = "${var.diskpath}"
#  datacenter = "${data.vsphere_datacenter.dc.name}"
#  datastore    = "${var.datastore}"
#  type         = "thin"
#}

#### VM CREATION ####
# Set vm parameters
resource "vsphere_virtual_machine" "vm-one" {
  name                 = var.vmname
  num_cpus             = 1
  memory               = 1024
  datastore_id         = data.vsphere_datastore.datastore.id
  #host_system_id      = data.vsphere_host.host.id
  resource_pool_id     = data.vsphere_resource_pool.pool.id
  guest_id             = data.vsphere_virtual_machine.template.guest_id
  scsi_type            = data.vsphere_virtual_machine.template.scsi_type
  #folder               = var.region/vm/var.foldername
  # Set network parameters
  network_interface {
    network_id         = data.vsphere_network.network.id
  }
  # Use a predefined vmware template has main disk
 # disk {
   #size ="${vsphere_virtual_disk.myDisk.size}"
   # label="demodisk1"
   # attach = true
   # datastore_id     = "${data.vsphere_datastore.datastore.id}"
   # path = "${vsphere_virtual_disk.myDisk.vmdk_path}"
   # unit_number = 1
  #  thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
 # }
disk {
    label="testdisk22.vmdk"
    size = "30"
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
   clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = var.hostname
        domain    = var.domain
      }
      network_interface {

      }
    }
  }
}
#File =vmware_simple_vm_variable.tf
variable "user" {
    type = string
}
variable "password" {
    type = string
}
variable "host" {
    type = string
}
variable "region" {
    type = string
}
variable "datastore" {
    type = string
}
variable "cluster" {
    type = string
}
variable "network_interface" {
    type = string
}
variable "domain" {
    type = string
}
variable "hostname" {
    type = string
}
variable "templateName" {
    type = string
}
variable "vmname" {
    type = string
}
#variable "foldername" {
#    type = string
#}
#variable "diskpath" {
#    type = string
#}

