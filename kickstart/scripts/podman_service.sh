#!/bin/bash
if [ -e /tmp/runonce ]; then
    # shellcheck disable=SC1091
    source /etc/profile.env

    rm /tmp/runonce

    # Make sure SDN interface supplies DNS
    con=$(nmcli d show "$SDN_INTERFACE" | sed -nre 's/^GENERAL.CONNECTION:\s+(.*)$/\1/p')
    sudo nmcli con mod "$con" ipv4.dns-priority -1
    sudo systemctl restart NetworkManager

    echo "unqualified-search-registries = ['registry.access.redhat.com', 'docker.io']" > /etc/containers/registries.conf
    systemctl restart cri-o

    # check cluster version to apply the right procedure
    VERSION_NUMBER=$(oc get clusterversion --config=/root/.kube/config  --output=jsonpath='{.items[0].status.desired.version}')
    if [[ $VERSION_NUMBER == "4.1"* ]]; then	    
        # run release image
        CLUSTER_VERSION=$(oc get clusterversion --config=/root/.kube/config --output=jsonpath='{.items[0].status.desired.image}')
        podman pull --tls-verify=false --authfile /tmp/pull.json $CLUSTER_VERSION
        RELEASE_IMAGE=$(podman run --rm $CLUSTER_VERSION image machine-config-daemon)

        # run MCD image
        podman pull --tls-verify=false --authfile /tmp/pull.json $RELEASE_IMAGE
        podman run -v /:/rootfs -v /var/run/dbus:/var/run/dbus -v /run/systemd:/run/systemd --privileged --rm -ti $RELEASE_IMAGE start --node-name $HOSTNAME --once-from /tmp/bootstrap.ign --skip-reboot
        reboot
    elif [[ $VERSION_NUMBER == "4.2"* ]]; then
        # run release image
	CLUSTER_VERSION=$(oc get clusterversion --config=/root/.kube/config --output=jsonpath='{.items[0].status.desired.image}')
	RELEASE_IMAGE=$(podman pull --tls-verify=false --authfile /tmp/pull.json $CLUSTER_VERSION)
	RELEASE_IMAGE_MCD=$(podman run --rm $RELEASE_IMAGE image machine-config-operator)

	# run MCD image
	MCD_IMAGE=$(podman pull --tls-verify=false --authfile /tmp/pull.json $RELEASE_IMAGE_MCD)
	podman run -v /:/rootfs -v /var/run/dbus:/var/run/dbus -v /run/systemd:/run/systemd --privileged --rm --entrypoint=/usr/bin/machine-config-daemon -ti $MCD_IMAGE start --node-name $HOSTNAME --once-from /tmp/bootstrap.ign --skip-reboot
    else
        echo "Openshift version not supported, exiting"
	exit 1
    fi
    reboot
fi
