# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

SGPKit is a Swift package that wraps the [sgp4](https://github.com/dnwrnr/sgp4) C++ library (by
Daniel Warner) to compute satellite positions from Two-Line Element sets (TLE). Swift talks to the
vendored C++ code directly via C++ interop (`.interoperabilityMode(.Cxx)`), not through an
Objective-C shim.

## Commands

```bash
swift build                          # build all targets
swift test                           # run the full test suite (swift-testing, not XCTest)
swift test --filter TLEInterpreterTests           # run one suite
swift test --filter "TLEInterpreterTests/testItShouldReturnTheExpectedSatelliteData"  # run one test
swift package generate-documentation # build DocC docs (swift-docc-plugin)
```

There is no CI workflow in the repo; builds are done by Swift Package Index (`.spi.yml` adds
iOS, tvOS, watchOS and DocC for `SGPKit`; SPI builds Linux on Swift 6.1–6.4). The Makefile runs
Linux builds/tests locally in the official `swift:<version>` Docker images: it mirrors SPI's
6.1–6.4 and also builds on 5.10, the `swift-tools-version` floor SPI no longer checks. Tests don't
run on 5.10, since they use the error returned by `#expect(throws:)`, added in 6.1. Each version
builds into its own `.build/linux-<version>`:

```bash
make build-linux-64   # or build-linux-63 / -62 / -61 / -510 / build-linux-all
make test-linux-64    # or test-linux-63 / -62 / -61 / test-linux-all
make clean
```

Tests use Swift Testing (`import Testing`, `@Suite`/`@Test`, `#expect`), not XCTest.

## Architecture

Three layered targets, each a boundary you should not blur:

1. **`SGPKitCPP`** (`Sources/sgp4Lib`) — the vendored, unmodified upstream `sgp4` C++ library
   (`Tle`, `SGP4`, `Eci`, `DateTime`, etc.). Treat this as third-party code; don't hand-edit it,
   re-vendor with `scripts/update-sgp4.sh <tag-or-commit>`, which records the upstream commit
   in `Sources/sgp4Lib/UPSTREAM_REVISION`.
2. **`SGP4LibWrapper`** (`Sources/SGP4LibWrapper`) — a thin C++ bridging layer
   (`Wrapper.hpp`/`Wrapper.cpp`). Its sole job is to catch the C++ exceptions the sgp4 library
   throws (`TleException`, `SatelliteException`) at the boundary and convert them into
   `std::optional`, because C++ exceptions cannot propagate into Swift. Any new entry point into
   the C++ library must follow this same catch-and-return-optional pattern.
3. **`SGPKit`** (`Sources/SGPKit`) — the public Swift API. Also compiled with
   `.interoperabilityMode(.Cxx)` since it calls into the wrapper's C++ types directly (e.g.
   `libsgp4.SGP4`, `libsgp4.DateTime`) rather than being fully isolated from them.

### Domain model (`Sources/SGPKit`)

- **`TLE`** — the validated Two-Line Element value type. Enforces the format invariant (both data
  lines exactly 69 characters) in its designated initializers; construction throws
  `TLEError.linesMustBeSixNineCharactersLong` otherwise. Its `Codable` conformance is fully
  synthesized (keyed: `title`, `firstLine`, `secondLine`) and has nothing to do with the ASCII
  TLE format. Synthesized decoding bypasses the 69-character check, so build `TLE`s from
  untrusted input via the designated initializers or `TLEDecoder`.
- **`TLEInterpreter`** — stateless, `Sendable` propagator. `satelliteData(from:date:)` builds a
  C++ `libsgp4.Tle` and `libsgp4.SGP4` per call (no caching), converts `Date` to `libsgp4.DateTime`
  in UTC, and maps the resulting ECI position/velocity into geodetic degrees/km/km-h. Failures at
  the `std::optional` boundary become `TLEInterpreter.Error.tle` / `.satellite`.
- **`SatelliteData`** — plain output DTO (latitude/longitude in degrees, altitude in km, speed in
  km/h). No validation, no behavior.
- **`TLEDecoder` / `TLEEncoder`** — the supported way to convert between raw ASCII TLE text and
  `TLE`. These are *not* generic `Codable` adapters: they implement a bespoke line-based
  `Encoder`/`Decoder` pair where the "container" is literally the newline-separated text lines.
  The decoder side never calls `TLE.init(from:)`: `decode` pulls three strings from the unkeyed
  container itself, and `decodeCollection` goes through the container's generic `decode<T>`,
  which only accepts `TLE` and constructs it directly. The encoder side *does* rely on
  `TLE`'s synthesized `encode(to:)`: it appends every `String` written to its keyed container as
  a line, so the output line order is the **declaration order of `TLE`'s stored properties** —
  reordering them silently breaks encoding.
- **`TLEParser`** — deprecated; kept for source compatibility. New code should use `TLEDecoder`.

### Error handling pattern

Exceptions are only caught once, at the C++/Swift seam in `Wrapper.cpp`. Everything above that
(`TLEInterpreter`, `TLEDecoder`, `TLE`) works with Swift-native `Optional`/`throws` and never needs
to reason about C++ exceptions directly.

### Tests (`Tests/SGPKitTests`)

- One suite per type; `TLEInterpreterTests` lives in the misleadingly named `SPGKitTests.swift`.

- Fixture TLE text files live in `Tests/SGPKitTests/Fixtures/Mocks` and are loaded through
  `Bundle.module` (see `TLETestUtils`) — add new fixtures there and register them in
  `TLETestUtils` rather than inlining TLE strings in test bodies.
- Floating-point assertions on computed satellite data use swift-numerics'
  `isApproximatelyEqual(to:)` rather than exact equality, since SGP4 propagation is
  floating-point-sensitive.

## Changelog and releases

- `CHANGELOG.md` follows Keep a Changelog. Every user-visible change (public API, encoding or
  decoding behaviour, propagation results, platforms) adds an entry under `## Unreleased` in the
  same change, grouped as Added, Changed, Fixed or Removed. Breaking entries start with
  **Breaking:** and say how to migrate. Refactors, tests, CI, documentation and re-vendoring that
  changes no behaviour get no entry.
- Tags are bare semantic versions (`4.0.0`, no `v` prefix), annotated, on a commit that also
  updates the README installation snippet's `from:` version and renames the changelog's
  `## Unreleased` section to `## <version> – <date>`; that section's text is the GitHub release
  notes.

## Commit messages

Keep commits short: a one-line subject plus at most 1-2 short sentences of body. No multi-paragraph
explanations of the mechanism/root cause — that belongs in the PR description or conversation.
