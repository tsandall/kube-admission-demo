package admission

import data.admission.blacklist

review = {
    "apiVersion": "admission.k8s.io/v1alpha1",
    "kind": "AdmissionReview",
    "status": status,
}

default status = {
    "allowed": true
}

status = {
    "allowed": false,
    "status": {
        "reason": reason,
    },
} {
    concat("; ", blacklist.reason, reason)
    reason != ""
}
