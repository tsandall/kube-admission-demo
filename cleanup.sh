#!/usr/bin/env bash

set -x

export KUBECONFIG=/var/run/kubernetes/admin.kubeconfig

kubectl -n production delete -f nginx-pinned.yaml
kubectl delete -f init.yaml
curl localhost:8181/v1/data/break_glass -d '[{"op": "remove", "path": "/"}]' -H 'Content-Type: application/json-patch+json' -X PATCH

while [ 1 ]; do kubectl get ns; sleep 5; done
