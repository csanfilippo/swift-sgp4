# swift-sgp4
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcsanfilippo%2Fswift-sgp4%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/csanfilippo/swift-sgp4)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcsanfilippo%2Fswift-sgp4%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/csanfilippo/swift-sgp4)

A Swift package to compute satellite positions from two‑line elements (TLE), wrapping the [sgp4](https://github.com/dnwrnr/sgp4) library (by Daniel Warner).

## Usage

```swift
import SGPKit

let title = "ISS (ZARYA)"
let firstLine = "1 25544U 98067A   13165.59097222  .00004759  00000-0  88814-4 0    47"
let secondLine = "2 25544  51.6478 121.2152 0011003  68.5125 263.9959 15.50783143834295"

// Parse or construct a TLE
let parser = TLEParser()
let tle = try parser.parse(lines: [firstLine, secondLine], title: title)

// Instantiate the interpreter (stateless and Sendable)
let interpreter = TLEInterpreter()

// Compute the satellite state at a given date
let now: Date = .now
let data = try interpreter.satelliteData(from: tle, date: now)

print(data.latitude)   // degrees
print(data.longitude)  // degrees
print(data.altitude)   // kilometers
print(data.speed)      // km/h

### Swift Package Manager

If you want to use SGPKit in any other project that uses [SwiftPM](https://swift.org/package-manager/), add the package as a dependency in `Package.swift`:

```swift
dependencies: [
  .package(
    url: "https://github.com/csanfilippo/swift-sgp4",
    from: "3.0.0"
  ),
]
```

