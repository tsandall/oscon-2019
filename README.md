# Policy as Code (OSCON 2019)

This is a talk about policy as code.

Policy management is a hard problem. In many organizations, policies aren't
codified. Instead organizations rely on things like tribal knowlege and wikis
and spreadsheets to enforce important rules that govern how their systems
behave. In other organizations, policies get codified in an ad-hoc manner
through business logic, configuration, and bespoke domain-specific languages.

Policy as code is about decoupling policy decision-making from policy
enforcement. It's about taking those rules and codifying them so that both
humans and machines can understand them. Policy as code lets you apply software
engineering best practices to your policies. You can version them, you can audit
them, you can test them, and you can analyze them. You end up with systems that
are more secure and suffer less downtime.

The Open Policy Agent (OPA) project provides a general-purpose policy engine
that helps you treat policy as code. OPA is domain-agnostic. Whether you're
talking about HTTP APIs or Kubernetes resources or SSH and sudo access, OPA
gives you a tool that you can use to specify policies against them.

# Prerequisites

The steps below assume that OPA installed in your PATH. See the [Getting
Started](https://www.openpolicyagent.org/docs/latest/get-started#prerequisites)
section on the OPA website to download OPA.

# Examples

## Run OPA as a REPL

```bash
opa run
```

## Simple expressions

```ruby
> 1 == 1
true
```

```ruby
> 1 == 2
false
```

```ruby
> 1+2*3
7
```

```
> split("a.b.c", ".")
[
    "a",
    "b",
    "c"
]
```

## Simple rules

```ruby
> default allow = false
```

```ruby
> allow = true { input.method = "GET"; input.path = ["salary", id]; input.user = id }
```

## Querying rules

```ruby
> allow
false
```

```ruby
> allow with input as {"method": "GET", "path": ["salary", "bob"], "user": "bob"}
true
```

```ruby
> allow with input as {"method": "GET", "path": ["salary", "bob"], "user": "alice"}
false
```

## Showing rules

```ruby
> show
package repl

default allow = false

allow {
    some id
    input.method = "GET"
    input.path = ["salary", id]
    input.user = id
}
```

## Run OPA as a server (and load policies via command-line)

```bash
# Run this inside another terminal.
opa run -s example.rego
```

## Query OPA via HTTP

```bash
curl localhost:8181/v1/data/repl/allow?pretty
```

```bash
curl localhost:8181/v1/data/repl/allow?pretty -d @allowed.json
```

```bash
curl localhost:8181/v1/data/repl/allow?pretty -d @denied.json
```

## Define input document using YAML inside the REPL

```bash
opa run
```

```ruby
> input := yaml.unmarshal(`
apiVersion: v1
kind: Pod
metadata:
  name: acme-portal
  labels:
    app: acme-portal
    cost-center: marketing
spec:
  containers:
  - name: web
    image: acme/java
    ports:
    - containerPort: 8888
  - name: proxy
    image: acme/proxy
    ports:
    - port: 6443
`)
```

## Dotting into JSON values

```ruby
> input
```

```ruby
> input.metadata
```

```ruby
> input.metadata.labels
```

```ruby
> input.metadata.labels.app
```

```ruby
> input.metadata.labels.pizza  # expected to be undefined
```

## Expressing conditions

```ruby
> input.metadata.name == input.metadata.labels.app
```

```ruby
> re_match("^acme-.+", input.metadata.labels.app)
```

```ruby
> count(input.spec.containers) > 100
```

## Using variables

```ruby
> labels := input.metadata.labels; labels.app == "acme-portal"
```

```ruby
> labels := input.metadata.labels; labels.pizza == "cheese"  # expected to be undefined
```

## Logical OR

```ruby
valid_app_label {
    input.metadata.name == input.metadata.labels.app
    startswith(input.metadata.labels.app, "acme-")
}

valid_app_label {
    input.metadata.name == input.metadata.labels.app
    startswith(input.metadata.labels.app, "initech-")
}
```

## Defining helper rules

```ruby
valid_app_label {
    input.metadata.name == input.metadata.labels.app
    valid_app_prefix
}

valid_app_prefix {
    startswith(input.metadata.labels.app, "acme-")
}

valid_app_prefix {
    startswith(input.metadata.labels.app, "initech-")
}
```

## Defining functions (rules with arguments)

```ruby
valid_app_label {
    input.metadata.name == input.metadata.labels.app
    valid_org_prefix(input.metadata.labels.app)
}

valid_org_prefix(s) {
    startswith(s, "acme-")
}

valid_org_prefix(s) {
    startswith(s, "initech-")
}
```

## Iteration

```
invalid_images {
    some index
    image := input.spec.containers[index].image
    not startswith(image, "acme/")
}
```