# Changelog

All notable changes to `SGPKit` are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/). Releases up to 3.1.0 are described in the [GitHub releases](https://github.com/csanfilippo/swift-sgp4/releases).

## Unreleased

### Changed

- Apps and packages that depend on SGPKit no longer need to enable C++ interoperability (`.interoperabilityMode(.Cxx)`, or Xcode's "C++ and Objective-C Interoperability" setting). SGPKit now reaches the sgp4 library through a plain C interface.

## 4.1.0 – 2026-10-11

### Added

- TLEs whose satellite catalog number uses the Alpha-5 format, a letter followed by four digits (such as `A0001` for 100001), now propagate. Previously `TLEInterpreter.satelliteData(from:date:)` threw `TLEInterpreter.Error.tle` for them.

## 4.0.0 – 2026-10-11

### Changed

- **Breaking:** `TLE` now decodes from the same keyed form it encodes, `{"title": …, "firstLine": …, "secondLine": …}`, so a `TLE` survives an encode and decode round trip through `JSONEncoder` and `JSONDecoder`. In 3.1.0 it decoded only from an array `[title, firstLine, secondLine]`, which no longer decodes. To migrate stored arrays, decode them as `[String]` and pass the three values to `TLE(title:firstLine:secondLine:)`. `TLEDecoder` and `TLEEncoder`, which read and write raw TLE text, are unchanged.

### Fixed

- `TLEInterpreter.satelliteData(from:date:)` throws `TLEInterpreter.Error.satellite` for a TLE whose orbital elements are out of range, such as an invalid eccentricity or inclination, instead of crashing the process.
- Satellite positions are correct on devices set to a non-Gregorian calendar, such as the Buddhist or Japanese calendar. The date was split into year, month and day using the device's calendar, which shifted the propagation date.
