#!/bin/sh
# The job: validate the agent configuration in config/ — every .hcl / .json file in it,
# merged the way `consul agent -config-dir config` loads them, service definitions
# included. Exits non-zero when anything is invalid.
set -eu
cd "$(dirname "$0")/.."
echo "==> consul version";          consul version
echo "==> consul validate config/"; consul validate config/
echo "consul: configuration valid"
