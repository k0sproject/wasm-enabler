FROM alpine as build
ARG WASM_SHIMS_VERSION=v0.3.3
ARG KUBE_VERSION=v1.26.0
WORKDIR /tmp
RUN apk --no-cache add curl
RUN echo ${VERSION}
RUN curl https://github.com/deislabs/containerd-wasm-shims/releases/download/${WASM_SHIMS_VERSION}/containerd-wasm-shims-v1-linux-x86_64.tar.gz  -L -o runtime.tar.gz
RUN tar xzvf runtime.tar.gz
RUN curl -Lo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$KUBE_VERSION/bin/linux/amd64/kubectl \
  && chmod +x /usr/local/bin/kubectl

FROM alpine
RUN mkdir /artifacts
COPY --from=build /tmp/containerd-shim-spin-v1 /artifacts/containerd-shim-spin-v1
COPY --from=build /tmp/containerd-shim-slight-v1 /artifacts/containerd-shim-slight-v1
COPY --from=build /usr/local/bin/kubectl /usr/local/bin/kubectl
COPY containerd.toml /artifacts/containerd.toml
COPY install.sh /bin/install.sh
RUN chmod +x /bin/install.sh

CMD ["/bin/install.sh"]
