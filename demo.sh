#!/usr/bin/env bash

# Setup

# Terminal 1:
# export DEMO_DIR=$HOME/kube-admission-demo
# ./opa_linux_amd64 run --server $DEMO_DIR/admission.rego
#
# Terminal 2:
# export KUBE_DIR=$HOME/go/src/k8s.io/kubernetes
# cd $KUBE_DIR; ADMISSION_CONTROL_CONFIG_FILE=$HOME/admission-generic.yml ALLOW_PRIVILEGED=true ./hack/local-up-cluster.sh
#
# Terminal 3:
# export DEMO_DIR=$HOME/kube-admission-demo
# source env/bin/activate; python $DEMO_DIR/sync_pods.py
#
# Terminal 4:
# export DEMO_DIR=$HOME/kube-admission-demo
# export KUBECONFIG=/var/run/kubernetes/admin.kubeconfig
# kubectl create -f $DEMO_DIR/init.yaml
# cd $DEMO_DIR
# ./demo.sh

# Demo

export OPA=localhost:8181/v1
export KUBECONFIG=/var/run/kubernetes/admin.kubeconfig
source ./util.sh

set -ex
kubectl create -f init.yaml
set +ex
read -s

clear

desc "Requirement: all images deployed in the 'production' namespace must be tagged with a version."
read -s

run "view image_tags.rego"

run "curl $OPA/policies/image_tags --data-binary @image_tags.rego -X PUT -D - -o /dev/null -s"

run "kubectl -n production create -f nginx.yaml"

run "cat nginx.yaml"

run "cat nginx-pinned.yaml"

run "kubectl -n production create -f nginx-pinned.yaml"

desc "Requirement: Users cannot exec into privileged containers in the 'production' namespace unless there is an \"emergency\"."
read -s

run "kubectl -n production get pod nginx-privileged -o json | jq '.spec.containers[0]'"

run "view privileged_exec.rego"

run "curl $OPA/policies/privileged_exec --data-binary @privileged_exec.rego -X PUT -D - -o /dev/null -s"

run "kubectl -n production exec nginx-privileged hostname"

desc "Break the glass!"
run "curl $OPA/data/break_glass -d 'true' -H 'Content-Type: application/json' -X PUT -i"

run "kubectl -n production exec nginx-privileged hostname"

desc "Restore the calm..."
run "curl $OPA/data/break_glass -d 'false' -H 'Content-Type: application/json' -X PUT -i"

run "kubectl -n production exec nginx-privileged hostname"
