package kubernetes

test_deny_invalid_egress {
    count(deny) == 1 with input as network_policy_fixture([
            {
                "to": [
                    {
                        "ipBlock": {
                            "cidr": "10.1.1.1/24"
                        }
                    }
                ]
            }
        ])
}


test_deny_valid_egress {
    count(deny) == 0 with input as network_policy_fixture([
            {
                "to": [
                    {
                        "ipBlock": {
                            "cidr": "1.1.1.1/24"
                        }
                    }
                ]
            }
        ])
}

test_deny_allow_all_egress {
    deny["egress allows all outgoing traffic"] with input as network_policy_fixture([{}])
}

network_policy_fixture(egress) = {
    "apiVersion": "networking.k8s.io/v1",
    "kind": "NetworkPolicy",
    "metadata": {
        "name": "test-network-policy",
        "namespace": "default"
    },
    "spec": {
        "egress": egress,
        "podSelector": {
            "matchLabels": {
                "role": "app"
            }
        },
        "policyTypes": [
            "Egress"
        ]
    }
}