# swift-sgp4
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcsanfilippo%2Fswift-sgp4%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/csanfilippo/swift-sgp4)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcsanfilippo%2Fswift-sgp4%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/csanfilippo/swift-sgp4)

A Swift package to compute satellite positions from two‑line elements (TLE), wrapping the [sgp4](https://github.com/dnwrnr/sgp4) library (by Daniel Warner).

## Usage

```swift
import Foundation
import SGPKit

let tle = try TLE(
    title: "ISS (ZARYA)",
    firstLine: "1 25544U 98067A   24060.51736111  .00016717  00000-0  30270-3 0  9991",
    secondLine: "2 25544  51.6431  57.2546 0004487  58.7657  56.7570 15.49688911439444"
)

// Instantiate the interpreter (stateless and Sendable)
let interpreter = TLEInterpreter()

// SGP4 is accurate only near the TLE's epoch, here 2024-02-29 12:25 UTC.
// Use a recent TLE (from CelesTrak or Space-Track, for example) to compute current positions.
let epoch = Date(timeIntervalSince1970: 1_709_209_500)
let data = try interpreter.satelliteData(from: tle, date: epoch)

print(data.latitude)   // degrees
print(data.longitude)  // degrees
print(data.altitude)   // kilometers
print(data.speed)      // km/h, inertial frame
```

### Swift Package Manager

If you want to use SGPKit in any other project that uses [SwiftPM](https://swift.org/package-manager/), add the package as a dependency in `Package.swift`:

```swift
dependencies: [
  .package(
    url: "https://github.com/csanfilippo/swift-sgp4",
    from: "4.4.0"
  ),
]
```

Upgrading from 3.x? See the [changelog](CHANGELOG.md) for breaking changes and how to migrate.

