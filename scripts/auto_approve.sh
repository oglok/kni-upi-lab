#!/bin/bash

for csr in $(oc get csr --no-headers |
  grep " system:serviceaccount:openshift-machine-config-operator:node-bootstrapper " |
  cut -d " " -f1); do
  oc adm certificate approve "${csr}"
done
