# Wasm enabler

k0s plugin to enable wasm runtime.

It leverages the new k0s containerd plugin "framework" to dynamically configure k0s managed containerd.

## Running the installer

Check the example manifest in [manifests/](manifests/) directory.

Essentially it runs as a `DaemonSet` and does the following:

- Drops WASM shim binaries into k0s bin dir at `/var/lib/k0s/bin`
- Drops WASM CRI plugin configuration into `/etc/k0s/containerd.d/`

Once k0s sees the drop-in configuration it will automatically reload the containerd configuration.

If you do not wish to install WASM runtime on all worker nodes you can customize the manifest with your own `nodeSelector`.

## Deploy sample WASM application

You can simply create a pod using the newly installed WASM runtime:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wasm-spin
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wasm-spin
  template:
    metadata:
      labels:
        app: wasm-spin
    spec:
      runtimeClassName: wasmtime-spin
      containers:
        - name: spin-hello
          image: ghcr.io/deislabs/containerd-wasm-shims/examples/spin-rust-hello:v0.5.1
          command: ["/"]
          resources: # limit the resources to 128Mi of memory and 100m of CPU
            limits:
              cpu: 100m
              memory: 128Mi
            requests:
              cpu: 100m
              memory: 128Mi
---
apiVersion: v1
kind: Service
metadata:
  name: wasm-spin
spec:
  type: NodePort
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  selector:
    app: wasm-spin
```

The key here is `runtimeClassName: wasmtime-spin` which instructs containerD to use wasmtime-spin runtime when it creates the container.

Once the Pod is running you can invoke the service via the exposed `NodePort` service:

```sh
# curl 172.17.0.3:32196/hello
Hello world from Spin!
```