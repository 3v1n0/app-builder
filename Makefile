# go get -u github.com/go-bindata/go-bindata/go-bindata (pack not used because cannot properly select dir to generate and no way to specify explicitly)

.PHONY: lint build publish assets

OS_ARCH = ""
ifeq ($(OS),Windows_NT)
	ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
		OS_ARCH := windows_amd64
	else
		OS_ARCH := windows_386
	endif
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		OS_ARCH := linux_arm64
	endif
	ifeq ($(UNAME_S),Darwin)
		OS_ARCH := darwin_amd64
	endif
endif

# ln -sf ~/Documents/app-builder/dist/darwin_amd64/app-builder ~/Documents/electron-builder/node_modules/app-builder-bin/mac/app-builder
build:
	go build -ldflags='-s -w' -o dist/$(OS_ARCH)/app-builder

# see https://goreleaser.com/#installing-goreleaser
# mac: brew install goreleaser
# linux: snap install goreleaser
build-all:
	goreleaser --skip-validate --skip-sign --skip-publish --rm-dist --snapshot

# brew install golangci/tap/golangci-lint && brew upgrade golangci/tap/golangci-lint
lint:
	golangci-lint run

test:
	go test -v ./pkg/...

assets:
	go-bindata -o ./pkg/package-format/bindata.go -pkg package_format -prefix ./pkg/package-format ./pkg/package-format/appimage/templates

publish: build
	./scripts/publish-npm.sh

update-deps:
	go get -u
	go mod tidy