# swift-sgp4
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcsanfilippo%2Fswift-sgp4%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/csanfilippo/swift-sgp4)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcsanfilippo%2Fswift-sgp4%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/csanfilippo/swift-sgp4)

A Swift package to compute satellite positions from two-line elements (TLE), wrapping the [sgp4lib](https://www.danrw.com/sgp4/) library (by Daniel Warner)


## Usage

```swift
import SGPKit

let title = "ISS (ZARYA)"
let firstLine = "1 25544U 98067A   13165.59097222  .00004759  00000-0  88814-4 0    47"
let secondLine = "2 25544  51.6478 121.2152 0011003  68.5125 263.9959 15.50783143834295"

// Instantiate a new TLE descriptor
let tle = TLE(title: title, firstLine: firstLine, secondLine: secondLine)

// Instantiate the interpreter
let interpreter = TLEInterpreter()

// Obtain the data
let data: SatelliteData = interpreter.satelliteData(from: tle, date: .now)

print(data.latitude)
print(data.longitude)
print(data.altitude)
print(data.speed)
```

## Installation

### Swift Package Manager

If you want to use SGPKit in any other project that uses [SwiftPM](https://swift.org/package-manager/), add the package as a dependency in `Package.swift`:

```swift
dependencies: [
  .package(
    url: "https://github.com/csanfilippo/swift-sgp4",
    from: "1.2.0"
  ),
]
```
