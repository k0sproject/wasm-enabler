#!/bin/sh

IMPORTS_DIR="/etc/k0s/containerd.d/"
BIN_DIR="/var/lib/k0s/bin/"

echo "Installing WASM/spin shim binaries to ${BIN_DIR}"
cp /artifacts/containerd-shim-* ${BIN_DIR}

echo "Installing WASM/spin containerd config to ${IMPORTS_DIR}"
cp /artifacts/containerd.toml ${IMPORTS_DIR}/wasm_spin_runtime.toml

kubectl label nodes "${NODE_NAME}" plugin.k0sproject.io/wasm-enabled=true --overwrite
