package repl

default allow = false

allow {
	input.method = "GET"
	input.path = ["salary", id]
	input.user = id
}
