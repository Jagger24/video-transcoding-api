.PHONY: all testdeps lint runlint test gotest coverage gocoverage build run

HTTP_PORT ?= 8080
LOG_LEVEL ?= debug

all: test

testdeps:
	GO111MODULE=off go get github.com/golangci/golangci-lint/cmd/golangci-lint
	go mod download

lint: testdeps runlint

runlint:
	golangci-lint run \
		--enable-all \
		-D errcheck \
		-D lll \
		-D gochecknoglobals \
		-D goconst \
		-D gocyclo \
		-D dupl \
		-D gocritic \
		-D gochecknoinits \
		-D unparam \
		--deadline 5m ./...

gotest:
	go test -vet=all -mod=readonly $(GO_TEST_EXTRA_FLAGS) ./...

test: lint testdeps gotest

coverage: lint gocoverage

gocoverage:
	make gotest GO_TEST_EXTRA_FLAGS="-coverprofile=coverage.txt -covermode=atomic"

build:
	go build -mod=readonly

run: build
	HTTP_PORT=$(HTTP_PORT) APP_LOG_LEVEL=$(LOG_LEVEL) ./video-transcoding-api
