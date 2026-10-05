# Consul agent configuration: a single-node server with the UI, ACLs on (default deny)
# and service mesh enabled. Check it with `consul validate config/`.
#
# For a real cluster: set bootstrap_expect to the server count (3 or 5), list the other
# servers in retry_join, and supply encrypt / TLS material from your secret store.

datacenter = "dc1"
data_dir   = "/consul/data"
log_level  = "INFO"
node_name  = "consul-server-1"

server           = true
bootstrap_expect = 1

# Bind cluster traffic to the first private IPv4 address (a go-sockaddr template, resolved
# when the agent starts), so the config works unchanged on hosts with several interfaces.
# Pin an address or an interface (e.g. {{ GetInterfaceIP "eth0" }}) if you need a specific one.
bind_addr   = "{{ GetPrivateInterfaces | include \"type\" \"IPv4\" | limit 1 | attr \"address\" }}"
client_addr = "0.0.0.0"

retry_join = ["127.0.0.1"]

ui_config {
  enabled = true
}

addresses {
  http = "0.0.0.0"
}

ports {
  http     = 8500
  grpc     = 8502
  grpc_tls = 8503
  dns      = 8600
}

acl {
  enabled                  = true
  default_policy           = "deny"
  enable_token_persistence = true
}

connect {
  enabled = true
}

performance {
  raft_multiplier = 1
}

telemetry {
  prometheus_retention_time = "60s"
  disable_hostname          = true
}
