package admission.blacklist

reason["must pin image(s) to specific version in production namespace"] {
    input.spec.namespace = "production"
    unpinned_tag
}

unpinned_tag = true {
    image_names[name]
    not re_match(pinned_version_pattern, name)
}

unpinned_tag = true {
    image_names[name]
    endswith(name, ":latest")
}

image_names[name] {
    name = input.spec.object.Spec.Template.Spec.Containers[_].Image
}

image_names[name] {
    name = input.spec.object.Spec.Containers[_].Image
}

pinned_version_pattern = ".+:.+"
