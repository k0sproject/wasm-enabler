FROM alpine as build
ARG VERSION=v0.3.3
ENV URL=https://github.com/deislabs/containerd-wasm-shims/releases/download/${VERSION}
WORKDIR /tmp
RUN apk --no-cache add curl

RUN case $(uname -m) in amd64|x86_64) ARCH="amd64" ;; arm64|aarch64) ARCH="arm64" ;; esac && \
    curl -Lo /tmp/kubectl https://storage.googleapis.com/kubernetes-release/release/$KUBE_VERSION/bin/linux/$ARCH/kubectl

RUN case $(uname -m) in amd64|x86_64) ARCH="x86_64" ;; arm64|aarch64) ARCH="aarch64" ;; esac  && \
    curl ${URL}/containerd-wasm-shims-v1-linux-${ARCH}.tar.gz -L -o runtime.tar.gz

RUN tar xzvf runtime.tar.gz

FROM alpine
RUN mkdir /artifacts
COPY --from=build /tmp/containerd-shim-spin-v1 /artifacts/containerd-shim-spin-v1
COPY --from=build /tmp/containerd-shim-slight-v1 /artifacts/containerd-shim-slight-v1
COPY --from=build /tmp/kubectl /usr/local/bin/kubectl
COPY containerd.toml /artifacts/containerd.toml
COPY install.sh /bin/install.sh
RUN chmod +x /bin/install.sh && chmod +x /usr/local/bin/kubectl


CMD ["/bin/install.sh"]
