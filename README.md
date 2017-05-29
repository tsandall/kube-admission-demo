# Fine-grained Declarative Admission Control using webhooks and OPA

This repo shows how you can enforce admission control policies in Kubernetes using OPA.

The examples in this repo rely on upcoming webhook support in Kubernetes. Check out [PR #46316](https://github.com/kubernetes/kubernetes/pull/46316) for details on the status of webhook support.

The slides for this demo are available [here](https://docs.google.com/presentation/d/1ADiOIZn5Hl4TGgI900Urc-ktHJGSwWnUfOEuBKxWMQs/edit#slide=id.g22aaf35733_0_31).

## Overview

This repo contains the following policies:

- ``image_tags.rego`` : Example policy that enforces image tagging conventions.
- ``privileged_exec.rego`` : Example policy that enforces exec security but supports rights elevation.
- ``admission.rego`` : Boilerplate required for Kubernetes to talk to OPA.

The `demo.sh` script in this repo contains steps to bootstrap th demo.

The `sync_pods.py` script replicates Pod objects from Kubernetes into OPA. This is required for the exec security example.

The `nginx*.yaml` manifests are used for demo purposes.
