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

Linux builds/tests run in Docker via the Makefile (mirrors CI matrix across Swift 5.10, 6.0, 6.1, 6.2):

```bash
make build-linux-62   # or build-linux-61 / build-linux-60 / build-linux-510 / build-linux-all
make test-linux-62    # or test-linux-61 / test-linux-60 / test-linux-all
make clean
```

Tests use Swift Testing (`import Testing`, `@Suite`/`@Test`, `#expect`), not XCTest.

## Architecture

Three layered targets, each a boundary you should not blur:

1. **`SGPKitCPP`** (`Sources/sgp4Lib`) — the vendored, unmodified upstream `sgp4` C++ library
   (`Tle`, `SGP4`, `Eci`, `DateTime`, etc.). Treat this as third-party code; don't hand-edit it,
   re-vendor from upstream instead.
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
  `TLEError.linesMustBeSixNineCharactersLong` otherwise. `Codable` is custom, not
  JSON-shaped — see below.
- **`TLEInterpreter`** — stateless, `Sendable` propagator. `satelliteData(from:date:)` builds a
  C++ `libsgp4.Tle` and `libsgp4.SGP4` per call (no caching), converts `Date` to `libsgp4.DateTime`
  in UTC, and maps the resulting ECI position/velocity into geodetic degrees/km/km-h. Failures at
  the `std::optional` boundary become `TLEInterpreter.Error.tle` / `.satellite`.
- **`SatelliteData`** — plain output DTO (latitude/longitude in degrees, altitude in km, speed in
  km/h). No validation, no behavior.
- **`TLEDecoder` / `TLEEncoder`** — the supported way to convert between raw ASCII TLE text and
  `TLE`. These are *not* generic `Codable` adapters: they implement a bespoke line-based
  `Encoder`/`Decoder` pair where the "container" is literally the newline-separated text lines.
  `TLE.init(from:)` expects an **unkeyed** container of exactly three strings
  (`[title, firstLine, secondLine]`); `TLEEncoder` requires a **keyed** container that emits
  strings as lines. Because of this asymmetry, encode/decode are not mirror images of each other —
  don't assume round-tripping through `Codable` conformances elsewhere will work the same way.
  `TLEDecoder.decode` handles a single TLE; `decodeCollection` handles a buffer of N TLE triplets.
- **`TLEParser`** — deprecated; kept for source compatibility. New code should use `TLEDecoder`.

### Error handling pattern

Exceptions are only caught once, at the C++/Swift seam in `Wrapper.cpp`. Everything above that
(`TLEInterpreter`, `TLEDecoder`, `TLE`) works with Swift-native `Optional`/`throws` and never needs
to reason about C++ exceptions directly.

### Tests (`Tests/SGPKitTests`)

- Fixture TLE text files live in `Tests/SGPKitTests/Fixtures/Mocks` and are loaded through
  `Bundle.module` (see `TLETestUtils`) — add new fixtures there and register them in
  `TLETestUtils` rather than inlining TLE strings in test bodies.
- Floating-point assertions on computed satellite data use swift-numerics'
  `isApproximatelyEqual(to:)` rather than exact equality, since SGP4 propagation is
  floating-point-sensitive.
