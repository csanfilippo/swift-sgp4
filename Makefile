DOCKER_IMAGE ?= registry.gitlab.com/finestructure/spi-images:basic

PROJECT_DIR ?= $(PWD)

DOCKER_RUN = docker run --pull=always --rm \
	-v "$(PROJECT_DIR)":/host \
	-w /host \
	-e JAVA_HOME="/root/.sdkman/candidates/java/current" \
	-e SPI_BUILD="1" \
	-e SPI_PROCESSING="1"

VERSION ?= 6.2

.PHONY: build-linux-all clean

build-linux:
	$(DOCKER_RUN) $(DOCKER_IMAGE)-$(VERSION)-latest \
		swift build --triple x86_64-unknown-linux-gnu
		
test-linux:
	$(DOCKER_RUN) $(DOCKER_IMAGE)-$(VERSION)-latest \
		swift test --triple x86_64-unknown-linux-gnu
		
build-linux-62:
	$(MAKE) build-linux VERSION=6.2
build-linux-61:
	$(MAKE) build-linux VERSION=6.1
build-linux-60:
	$(MAKE) build-linux VERSION=6.0
build-linux-510:
	$(MAKE) build-linux VERSION=5.10
		
build-linux-all: build-linux-62 build-linux-61 build-linux-60 build-linux-510

test-linux-62:
	$(MAKE) test-linux VERSION=6.2

test-linux-61:
	$(MAKE) test-linux VERSION=6.1

test-linux-60:
	$(MAKE) test-linux VERSION=6.0

test-linux-510:
	$(MAKE) test-linux VERSION=5.10

test-linux-all: test-linux-62 test-linux-61 test-linux-60 test-linux-510

clean:
	rm -rf $(PROJECT_DIR)/.build
