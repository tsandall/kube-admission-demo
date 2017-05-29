package admission.blacklist

reason["cannot exec into container in privileged pod"] {
    not is_emergency
    is_exec
    is_privileged
    is_production
}

is_emergency {
    data.break_glass = true
}

is_production {
    input.spec.namespace = "production"
}

is_exec {
    input.spec.operation = "CONNECT"
}

is_privileged {
    id = [input.spec.namespace, input.spec.name]
    privileged_pods[id]
}

privileged_pods[[namespace, name]] {
    pod = data.kubernetes.pods[namespace][name]
    container = pod.spec.containers[_]
    container.securityContext.privileged = true
}

