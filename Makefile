# Versions are written without the dot (62 for Swift 6.2) to keep target names like build-linux-62.
# 6.1–6.4 mirror Swift Package Index's Linux builds; 5.10 guards the swift-tools-version floor,
# which SPI no longer checks.
BUILD_VERSIONS := 510 61 62 63 64
# The tests use the error returned by #expect(throws:), which Swift Testing added in Swift 6.1.
TEST_VERSIONS := 61 62 63 64

PROJECT_DIR ?= $(CURDIR)

swift_tag = $(shell echo $(1) | sed 's/^./&./')

# Each version gets its own scratch path so Linux builds never share artifacts with macOS
# builds or with each other.
docker_swift = docker run --rm -v "$(PROJECT_DIR)":/host -w /host swift:$(call swift_tag,$(1)) \
	swift $(2) --scratch-path .build/linux-$(call swift_tag,$(1))

.PHONY: build-linux-all test-linux-all clean \
	$(addprefix build-linux-,$(BUILD_VERSIONS)) $(addprefix test-linux-,$(TEST_VERSIONS))

build-linux-all: $(addprefix build-linux-,$(BUILD_VERSIONS))

test-linux-all: $(addprefix test-linux-,$(TEST_VERSIONS))

$(addprefix build-linux-,$(BUILD_VERSIONS)): build-linux-%:
	$(call docker_swift,$*,build)

$(addprefix test-linux-,$(TEST_VERSIONS)): test-linux-%:
	$(call docker_swift,$*,test)

clean:
	rm -rf $(PROJECT_DIR)/.build
