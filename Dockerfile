FROM alpine as build
ARG VERSION=v0.3.3
ENV URL=https://github.com/deislabs/containerd-wasm-shims/releases/download/${VERSION}
WORKDIR /tmp
RUN apk --no-cache add curl

RUN case $(uname -m) in amd64|x86_64) ARCH="x86_64" ;; arm64|aarch64) ARCH="aarch64" ;; esac  && \
    curl ${URL}/containerd-wasm-shims-v1-linux-${ARCH}.tar.gz -L -o runtime.tar.gz

RUN tar xzvf runtime.tar.gz

FROM alpine
RUN mkdir /artifacts
COPY --from=build /tmp/containerd-shim-spin-v1 /artifacts/containerd-shim-spin-v1
COPY --from=build /tmp/containerd-shim-slight-v1 /artifacts/containerd-shim-slight-v1
COPY containerd.toml /artifacts/containerd.toml
COPY install.sh /bin/install.sh
RUN chmod +x /bin/install.sh

CMD ["/bin/install.sh"]