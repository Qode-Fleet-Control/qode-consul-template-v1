# Consul template

Provisioned from [`Qode-Fleet-Control/fleet-template-v1`](https://github.com/Qode-Fleet-Control/fleet-template-v1) — the fleet
lifecycle contract (`bin/`, `fleet.conf`, `compose.yaml`, deploy workflows) with a [Consul](https://developer.hashicorp.com/consul) agent configuration
laid on top.

**This repo is a job, not a service.** Its container runs `consul validate config/` and
exits 0 when the configuration is valid. It starts no agent and nothing listens on
`$PORT`.

## What is in it

| file | |
|---|---|
| `config/agent.hcl` | a single-node server: datacenter, raft data dir, bind address picked by a go-sockaddr template, UI, ports (HTTP, gRPC, gRPC-TLS, DNS), ACLs on with default deny, Connect (service mesh) on, Prometheus telemetry |
| `config/service-web.hcl` | a service registration: `web` on 8080, HTTP health check, Connect sidecar |
| `scripts/check.sh` | the job: `consul validate config/` (all files merged, as the agent loads them) |

Run an agent from it with `consul agent -config-dir=config`. For a real cluster set
`bootstrap_expect` to 3 or 5, fill `retry_join`, and supply `encrypt` and TLS material from a
secret store (never from git).

## Run it

**On the fleet:** `bin/run` builds the image (`docker compose build`) and stops there —
`DOCKER_START_CMD` is empty because there is no server. Run the job with
`docker compose run --rm app`.

**With docker:**

    docker compose build
    docker compose run --rm app        # exit 0 = "Configuration is valid!"

**Without docker** (needs `consul` on `PATH`):

    sh scripts/check.sh

`FLEET_RUNTIME=process bin/run` runs `BUILD_CMD` (`consul validate config/`) and then stops
at the start step, by design.

## Origin

    hand-written — Consul ships no project generator

Follows the agent configuration reference: HCL files in one config directory, loaded in
lexical order and merged; service definitions alongside.

## Deviations, and why

- `Dockerfile` is a job image on `hashicorp/consul:2.0.4`: its `ENTRYPOINT` (which starts an
  agent) is cleared and the default command is `scripts/check.sh`. Runs as non-root `app`
  (uid 10001).
- `bind_addr` is a go-sockaddr template (first private IPv4) rather than `0.0.0.0`:
  `consul validate` (and the agent) refuse `0.0.0.0` on any host with more than one
  private address, which made the config fail on ordinary dev machines.

## Verified

**The docker job has NOT been verified yet.** On 2026-10-05 the build host's docker disk
stayed below the 6 GB floor (0-3 GB free) for over three hours, so `docker compose build`
was never run for this repo. Build and run it once before trusting it:

    docker compose build && docker compose run --rm app; docker compose down --rmi local -v

What WAS checked, with the real CLIs outside docker (same `scripts/check.sh` the image runs):

    consul 2.0.4: sh scripts/check.sh       # "Configuration is valid!" -> exit 0
    (an unknown key added to agent.hcl makes it fail: "invalid config key", exit 1)

## Serving over HTTP

There is no HTTP surface. If you add one, listen on `0.0.0.0:$PORT`, serve at `/`, set
`PORT`, `HEALTH_PATH`, `START_CMD` and `DOCKER_START_CMD` in `fleet.conf`, and publish
`"${PORT}:${PORT}"` in `compose.yaml`. See `docs/fleet-lifecycle.md`.
