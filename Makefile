VERSION ?= latest
IMAGE ?= wasm-enabler

build:
	docker build -t $(IMAGE):$(VERSION) .

run: build
	docker run -v `pwd`/artifacts:/mounted:rw $(IMAGE):$(VERSION) /mounted

push: build
	docker push $(IMAGE):$(VERSION)
