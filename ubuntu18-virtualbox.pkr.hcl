#----------------------------------------------------------------------------------
# Packer template to build an Ubuntu Server 18.04 image on VirtualBox
# juliusn - Sun Dec  5 08:48:39 EST 2021
#----------------------------------------------------------------------------------

source "virtualbox-iso" "ubuntu" {

  # VM settings
  vm_name              = var.vm_name
  guest_os_type        = "Ubuntu_64"
  shutdown_command     = "shutdown -P now"
  iso_url              = var.vm_iso_url
  iso_checksum         = var.vm_iso_checksum

  ssh_username         = var.vm_access_username
  ssh_password         = var.vm_access_password
  ssh_timeout          = var.vm_ssh_timeout
  
  cpus                 = var.cpu_count
  memory               = var.ram_gb * 1024
  disk_size            = var.vm_disk_size
  usb                  = "true"
  
  ## Virtualbox settings
  output_directory         = "output_directory"
  hard_drive_nonrotational = "true"
  hard_drive_interface     = "sata"
  sata_port_count          = "5"
  guest_additions_path     = "iso/VBoxGuestAdditions_6.1.26.iso"
  

  vboxmanage = [
			["modifyvm", "{{.Name}}", "--memory", var.ram_gb * 1024],
			["modifyvm", "{{.Name}}", "--cpus", var.cpu_count],
      ["modifyvm", "{{.Name}}", "--vram", 128],
      ["modifyvm", "{{.Name}}", "--accelerate3d", "off"],
      ["modifyvm", "{{.Name}}", "--paravirtprovider", "kvm"],
      ["modifyvm", "{{.Name}}", "--firmware", "bios"],
      ["modifyvm", "{{.Name}}", "--nestedpaging", "on"],
      ["modifyvm", "{{.Name}}", "--apic", "on"],
      ["modifyvm", "{{.Name}}", "--pae", "on"]
	]
  
  boot_wait                 = var.boot_wait_iso
  boot_keygroup_interval    = var.boot_keygroup_interval_iso
  
  http_directory            = "http_directory/ubuntu-18.04"

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
    "sources.virtualbox-iso.ubuntu"
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
