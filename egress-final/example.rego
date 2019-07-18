package kubernetes

allowed_ip_ranges = {
    "1.1.1.1/24",
    "2.2.2.2/24",
}

deny[msg] {
    input.apiVersion == "networking.k8s.io/v1"
    input.kind == "NetworkPolicy"
    cidr := input.spec.egress[_].to[_].ipBlock.cidr
    not cidr_set_contains(allowed_ip_ranges, cidr)
    msg := sprintf("egress cidr not allowed: %v", [cidr])
}

deny["egress allows all outgoing traffic"] {
    input.apiVersion == "networking.k8s.io/v1"
    input.kind == "NetworkPolicy"
    egress := input.spec.egress[_]
    not egress.to
}

cidr_set_contains(set, x) {
    net.cidr_contains(set[_], x)
}

