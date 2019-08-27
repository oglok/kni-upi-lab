# Kickstart generation

Regular RHCOS nodes can be enrolled using ignition files directly. But for CentOS nodes, ignition on boot is not supported and an additional kickstart configuration is needed to embed it. The generated kickstart file can be added with **inst.ks** parameter on PXE kernel args.
Script to generate configurations for RHEL 7, 8 and CentOS are provided: ([https://github.com/redhat-nfvpe/upi-rt/blob/master/kickstart/add_kickstart_for_rhel7.sh](https://github.com/redhat-nfvpe/upi-rt/blob/master/kickstart/add_kickstart_for_rhel7.sh)), ([https://github.com/redhat-nfvpe/upi-rt/blob/master/kickstart/add_kickstart_for_rhel8.sh](https://github.com/redhat-nfvpe/upi-rt/blob/master/kickstart/add_kickstart_for_rhel8.sh)), ([https://github.com/redhat-nfvpe/upi-rt/blob/master/kickstart/add_kickstart_for_centos.sh](https://github.com/redhat-nfvpe/upi-rt/blob/master/kickstart/add_kickstart_for_centos.sh)) 
The procedure is as simple as to execute those scripts with a set of vars. This will generate a *kickstart\*.cfg file, that can be copied to matchbox assets directory, and used from pxe kernel args.

## Variables needed
Those scripts rely on a file *settings_upi.env* that needs to be placed at $HOME. It contains the following vars:

 - CLUSTER_NAME
 - BASE_DOMAIN
 - PULL_SECRET
 - KUBECONFIG_PATH (needs to point to the auth/kubeconfig generated by install-config)
 - ROOT_PASSWORD
 - OS_INSTALL_ENDPOINT

The OS_INSTALL_ENDPOINT for CentOS could be set to http://mirror.centos.org/centos/7.6.1810/os/x86_64/

Once the .cfg file has been generated, move it to the right matchbox assets directory and proceed to the next step.

## How to generate for RHEL

Extra settings are needed in settings_upi.env for RHEL: *RH_USERNAME*, *RH_PASSWORD*, *RH_POOL*. This needs to match
with the data of your RHEL subscription.
Also *OS_INSTALL_ENDPOINT* setting is needed. This needs to point to a public
URL that holds the extracted content of the RHEL DVD iso.

The latest ISO can be downloaded from:
[https://access.redhat.com/downloads/content/69/ver=/rhel---7/7.6/x86_64/product-software](https://access.redhat.com/downloads/content/69/ver=/rhel---7/7.6/x86_64/product-software)

This content needs to be mounted and extracted, following those commands:

    mkdir /mnt/iso
    mount -o loop /path/to/rhel-dvd.iso /mnt/iso
    mkdir /var/lib/matchbox/assets/rhel
    cp -ar /mnt/iso/* /var/lib/matchbox/assets/rhel/
    chmod -R 755 /var/lib/matchbox/assets/rhel

OS_INSTALL_ENDPOINT can be: http://${PROVISIONING_IP}:8080/assets/rhel/