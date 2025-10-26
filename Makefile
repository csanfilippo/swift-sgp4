DOCKER_IMAGE ?= registry.gitlab.com/finestructure/spi-images:basic

PROJECT_DIR ?= $(PWD)

DOCKER_RUN = docker run --pull=always --rm \
	-v "$(PROJECT_DIR)":/host \
	-w /host \
	-e JAVA_HOME="/root/.sdkman/candidates/java/current" \
	-e SPI_BUILD="1" \
	-e SPI_PROCESSING="1"

VERSION ?= 6.2

.PHONY: all clean

build-linux:
	$(DOCKER_RUN) $(DOCKER_IMAGE)-$(VERSION)-latest \
		swift build --triple x86_64-unknown-linux-gnu
		
test-linux:
	$(DOCKER_RUN) $(DOCKER_IMAGE)-$(VERSION)-latest \
		swift test --triple x86_64-unknown-linux-gnu
		
build-62:
	$(MAKE) build-linux VERSION=6.2
		
		
all:
	build-62
	$(MAKE) build-linux VERSION=6.2
	$(MAKE) build-linux VERSION=6.1
	$(MAKE) build-linux VERSION=6.0
	$(MAKE) build-linux VERSION=5.1


clean:
	rm -rf $(PROJECT_DIR)/.build