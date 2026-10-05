# A service registration loaded with the agent config: the "web" service, health-checked
# over HTTP, with a Connect sidecar so other mesh services can reach it.

service {
  name = "web"
  id   = "web-1"
  port = 8080
  tags = ["http", "v1"]

  meta {
    version = "0.1.0"
  }

  check {
    id       = "web-http"
    name     = "HTTP on 8080"
    http     = "http://localhost:8080/health"
    method   = "GET"
    interval = "10s"
    timeout  = "2s"
  }

  connect {
    sidecar_service {}
  }
}
