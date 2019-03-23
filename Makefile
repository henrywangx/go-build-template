# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
# App name
BINARY_NAME=mybinary
BINARY_UNIX=$(BINARY_NAME)_unix
BUILD_IMAGE ?= golang:1.12-alpine

# Used internally.  Users should pass GOOS and/or GOARCH.
#OS := $(if $(GOOS),$(GOOS),$(shell go env GOOS))
#ARCH := $(if $(GOARCH),$(GOARCH),$(shell go env GOARCH))
OS := linux
ARCH := amd64

all: test build
build: 
	$(GOBUILD) -o $(BINARY_NAME) -v
test: 
	$(GOTEST) -v ./...
clean: 
	$(GOCLEAN)
	rm -f $(BINARY_NAME)
	rm -f $(BINARY_UNIX)
run:
	$(GOBUILD) -o $(BINARY_NAME) -v ./...
	./$(BINARY_NAME)
docker-shell:
	@echo "launching a shell in the containerized build environment"
	@docker run                                                 \
	    -ti                                                     \
	    --rm                                                    \
	    -u $$(id -u):$$(id -g)                                  \
	    -v $$(pwd):/go                                         \
	    -w /go                                                 \
	    -v $$(pwd)/.go/bin/$(OS)_$(ARCH):/go/bin                \
	    -v $$(pwd)/.go/bin/$(OS)_$(ARCH):/go/bin/$(OS)_$(ARCH)  \
	    -v $$(pwd)/.go/cache:/.cache                            \
	    --env HTTP_PROXY=$(HTTP_PROXY)                          \
	    --env HTTPS_PROXY=$(HTTPS_PROXY)                        \
	    $(BUILD_IMAGE)                                          \
	    /bin/sh
docker-build:
		@docker run                                             \
	    -i                                                      \
	    --rm                                                    \
	    -u $$(id -u):$$(id -g)                                  \
	    -v $$(pwd):/go                                         \
	    -w /go                                                 \
	    -v $$(pwd)/.go/bin/$(OS)_$(ARCH):/go/bin                \
	    -v $$(pwd)/.go/bin/$(OS)_$(ARCH):/go/bin/$(OS)_$(ARCH)  \
	    -v $$(pwd)/.go/cache:/.cache                            \
	    --env HTTP_PROXY=$(HTTP_PROXY)                          \
	    --env HTTPS_PROXY=$(HTTPS_PROXY)                        \
		--env CGO_ENABLED=0										\
		--env GOARCH=$(ARCH)									\
		--env GOOS=$(OS)										\
	    $(BUILD_IMAGE)                                          \
	    /bin/sh -c "                                            \
			$(GOBUILD) -o $(BINARY_NAME) -v                     \
	    "
docker-test:
		@docker run                                             \
	    -i                                                      \
	    --rm                                                    \
	    -u $$(id -u):$$(id -g)                                  \
	    -v $$(pwd):/go                                         \
	    -w /go                                                 \
	    -v $$(pwd)/.go/bin/$(OS)_$(ARCH):/go/bin                \
	    -v $$(pwd)/.go/bin/$(OS)_$(ARCH):/go/bin/$(OS)_$(ARCH)  \
	    -v $$(pwd)/.go/cache:/.cache                            \
	    --env HTTP_PROXY=$(HTTP_PROXY)                          \
	    --env HTTPS_PROXY=$(HTTPS_PROXY)                        \
		--env CGO_ENABLED=0										\
		--env GOARCH=$(ARCH)									\
		--env GOOS=$(OS)										\
	    $(BUILD_IMAGE)                                          \
	    /bin/sh -c "                                            \
	        $(GOTEST) -v ./... 				                    \
	    "