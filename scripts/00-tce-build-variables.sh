#!/bin/bash -eu

#--------------------------------------------------------------------------------------
# Tanzu Community Edition - Build Variable Definition
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------------------

############################################################################
##
## Store vCenter secrets by using the pass insert command:
##
##     pass insert provider_vcenter_hostname
##     pass insert provider_vcenter_username
##     pass insert provider_vcenter_password
##
#############################################################################

if test -f "${HOME}/scripts/.index";
then
    export INDEX=`cat ${HOME}/scripts/.index`
else
    export INDEX=0
fi

export TCE_VERSION="0.10.0-rc.2"
export K8S_VERSION="1.22.4"
export KIND_VERSION="0.11.1"
export OCTANT_VERSION="0.25.0"

export MGMT_CLUSTER_NAME="tce-management"
export WKLD_CLUSTER_NAME="tce-workload"
export MGMT_VSPHERE_CONTROL_PLANE_ENDPOINT="192.168.130.130"
export WKLD_VSPHERE_CONTROL_PLANE_ENDPOINT="192.168.130.131"
export DEPLOY_TKG_ON_VSPHERE7="true" 

export VSPHERE_DATACENTER="west-dc"
export VSPHERE_CLUSTER="west-cluster"
export VSPHERE_DATASTORE="nfsdatastore01"
export VSPHERE_NETWORK_SWITCH="vds-west-02"
export VSPHERE_NETWORK_PG="tanzu-management"
export VSPHERE_TLS_THUMBPRINT="77:13:EE:0D:EB:C9:D1:7E:24:2F:AD:B7:FD:E7:5E:07:47:F9:34:C0"
export VSPHERE_SSH_KEY=`cat ${HOME}/.ssh/id_rsa.pub`
export VSPHERE_FOLDER="tanzu-community-edition-${INDEX}"
export VSPHERE_RESOURCE_POOL="tanzu-community-edition-${INDEX}"

# K8s node VM settings for Photon OS
# export OVA_VM_NAME="photon-3-kube-v1.21.2+vmware.1"
# export OVA_FILE="${HOME}/ova/photon-3-kube-v1.21.2+vmware.1-tkg.2-12816990095845873721.ova"
# export OVA_JSON_FILE="${HOME}/ova/kubernetes-node-ova-specs.json"
# export NODE_OS_NAME="photon"
# export NODE_OS_VERSION="3"

# Kubernetes node OS VM settings for Ubuntu OS
export OVA_VM_NAME="ubuntu-2004-kube-v1.21.2+vmware.1"
export OVA_FILE="${HOME}/ova/ubuntu-2004-kube-v1.21.2+vmware.1-tkg.1-7832907791984498322.ova"
export OVA_JSON_FILE="${HOME}/ova/kubernetes-node-ova-specs.json"
export NODE_OS_NAME="ubuntu"
export NODE_OS_VERSION="20.04"

export GOVC_URL="https://$(pass provider_vcenter_hostname)"
export GOVC_USERNAME=$(pass provider_vcenter_username)
export GOVC_PASSWORD=$(pass provider_vcenter_password)
export GOVC_INSECURE=true
export GOVC_DATASTORE="${VSPHERE_DATASTORE}"
export GOVC_NETWORK="${VSPHERE_NETWORK_PG}"

# Oracle Linux / Ubuntu
export MY_IP_ADDRESS=`ifconfig ens192 | grep '192.168.' | awk '{ print $2}'`
export MY_DOMAIN_NAME="flexlab.local"
# Photon OS
# export MY_IP_ADDRESS=`ifconfig eth0 | grep '192.168.' | awk '{print $2}' | cut -d ":" -f2`
# export MY_DOMAIN_NAME="flexlab.local"

export METALLB_VIP_RANGE="192.168.130.240-192.168.130.250"