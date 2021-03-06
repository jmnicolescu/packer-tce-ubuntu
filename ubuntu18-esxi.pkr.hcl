#----------------------------------------------------------------------------------
# Packer template to build anUbuntu Server 18.04 LTS image on VMware ESXi
# juliusn - Sun Dec  5 08:48:39 EST 2021
#----------------------------------------------------------------------------------

source "vmware-iso" "ubuntu" {

  # VM settings
  vm_name              = var.vm_name
  display_name         = var.vm_name
  guest_os_type        = "ubuntu-64"
  shutdown_command     = "shutdown -P now"
  version              = var.vm_guest_version
  iso_url              = var.vm_iso_url
  iso_checksum         = var.vm_iso_checksum

  ssh_username         = var.vm_access_username
  ssh_password         = var.vm_access_password
  ssh_timeout          = var.vm_ssh_timeout
  
  cpus                 = var.cpu_count
  memory               = var.ram_gb * 1024
  cdrom_adapter_type   = "sata"
  disk_size            = var.vm_disk_size
  disk_adapter_type    = "pvscsi"
  vmdk_name            = "${var.vm_name}_disk"
  usb                  = "true"
  network_adapter_type = "vmxnet3"
  
  # ESXi settings
  disk_type_id         = "thin"
  remote_type          = var.esx_remote_type
  remote_host          = var.esx_remote_hostname
  remote_datastore     = var.esx_remote_datastore
  remote_username      = var.esx_remote_username
  remote_password      = var.esx_remote_password
  keep_registered      = true
  skip_export          = true
  skip_compaction      = true
  headless             = true
  vnc_over_websocket   = true
  insecure_connection  = true

  vmx_data = {
    "ethernet0.present"     = "TRUE"
    "ethernet0.virtualdev"  = "vmxnet3"
    "ethernet0.networkName" = "${var.esx_port_group}"
    "scsi0.virtualdev"      = "pvscsi"
    "annotation"            = "${var.vm_name}"
    "vhv.enable"            = "TRUE"
    "nestedHVEnabled"       = "TRUE"
  }

  boot_wait              = var.boot_wait_iso
  boot_key_interval      = var.boot_key_interval_iso
  boot_keygroup_interval = var.boot_keygroup_interval_iso
  
  http_directory         = "http_directory/ubuntu-18.04"

  boot_command = [
    "<enter><wait><f6><wait><esc><wait>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs>",
    "/install/vmlinuz",
    " initrd=/install/initrd.gz",
    " priority=critical",
    " locale=en_US",
    " url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg",
    "<enter>"
  ]
}

build {

  sources = [
    "sources.vmware-iso.ubuntu"
  ]
  
  provisioner "file" {
    sources     = ["scripts"]
    destination = "/root/scripts"
  }

  provisioner "file" {
    sources     = ["certs"]
    destination = "/root/certs"
  }
  
  provisioner "shell" {
    scripts = [
      "scripts/10-update-certificates.sh",
      "scripts/11-ubuntu-settings.sh",
      "scripts/12-ubuntu-docker.sh",
      "scripts/14-install-hashicorp.sh",
      "scripts/15-install-govc.sh",
      "scripts/17-install-password-store.sh",
      "scripts/19-user-settings.sh",
      "scripts/20-ubuntu-cleanup.sh",
      "scripts/21-install-ntp-client.sh",
      ##
      ## Uncomment the following 3 scripts to enable GNOME (GUI) and install MS Code and VNC server.      
      ##
      ## "scripts/23-install-gnome.sh",
      ## "scripts/25-install-mscode.sh",
      ## "scripts/28-install-vnc.sh",
      "scripts/30-download-tanzu-tce.sh"
    ]
  }
  
  provisioner "file" {
    sources     = ["ova"]
    destination = "/home/tce/ova"
  }

  provisioner "file" {
    sources     = ["ova"]
    destination = "/home/tkg/ova"
  }

  provisioner "file" {
    sources     = ["tkg"]
    destination = "/home/tkg/tkg"
  }

  provisioner "shell" {
    inline = [
      "chown -R tce:tce /home/tce/ova",
      "chown -R tkg:tkg /home/tkg/ova",
      "chown -R tkg:tkg /home/tkg/tkg",
      "su - tce -c /home/tce/scripts/33-install-tce.sh",
    ]
  }

  post-processor "manifest" {
    output = "ubuntu.manifest.json"
    strip_path = true
  }
}

variable "vm_name" {
  type    = string
}

variable "vm_guest_os_type" {
  type    = string
}

variable "vm_guest_version" {
  type    = string
}

variable "vm_access_username" {
  type    = string
}

variable "vm_access_password" {
  type    = string
}

variable "vm_ssh_timeout" {
  type    = string
}

variable "cpu_count" {
  type    = number
}

variable "ram_gb" {
  type    = number
}

variable "vm_disk_size" {
  type    = number
}

variable "boot_key_interval_iso" {
  type    = string
}

variable "boot_wait_iso" {
  type    = string
}

variable "boot_keygroup_interval_iso" {
  type    = string
}

variable "vm_iso_url" {
  type    = string
}

variable "vm_iso_checksum" {
  type    = string
}

variable "vcenter_hostname" {
  type    = string
}

variable "vcenter_username" {
  type    = string
}

variable "vcenter_password" {
  type    = string
}

variable "vcenter_cluster" {
  type    = string
}

variable "vcenter_datacenter" {
  type    = string
}

variable "vcenter_datastore" {
  type    = string
}

variable "vcenter_folder" {
  type    = string
}

variable "vcenter_port_group" {
  type    = string
}

variable "esx_remote_type" {
  type    = string
}

variable "esx_remote_hostname" {
  type    = string
}

variable "esx_remote_datastore" {
  type    = string
}

variable "esx_remote_username" {
  type    = string
}

variable "esx_remote_password" {
  type    = string
}

variable "esx_port_group" {
  type    = string
}

variable "fusion_app_directory" {
  type    = string
}
variable "fusion_output_directory" {
  type    = string
}
