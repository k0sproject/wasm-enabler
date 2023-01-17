#!/bin/sh

IMPORTS_DIR="/etc/k0s/containerd_imports/"
BIN_DIR="/var/lib/k0s/bin/"

echo "Installing shim binaries to ${BIN_DIR}"
cp /artifacts/containerd-shim-* ${BIN_DIR}

echo "Installing containerd config to ${IMPORTS_DIR}"
cp /artifacts/containerd.toml ${IMPORTS_DIR}/wasm_runtime.toml

kubectl label nodes "${NODE_NAME}" plugin.k0sproject.io/wasm-enabled=true

# Very dirty hack to restart k0s service. The k0s must be started by the init system for this to work.
kill $(pidof k0s)