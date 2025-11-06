import Foundation
@testable import SGPKit

final class TLETestUtils {
    static func loadValidTLEData() -> (Data, TLE) {
        let url = Bundle.module.url(
            forResource: "valid_tle",
            withExtension: "txt",
            subdirectory: "Mocks"
        )!

        return (
            try! Data(contentsOf: url),
            try! TLE(
                title: "ISS (ZARYA)",
                firstLine: "1 11416U 79057A   80003.44366214  .00000727  00000-0  33454-3 0   878",
                secondLine: "2 11416  98.7309  35.7226 0013335  92.0280 268.2428 14.22474848 27074"
            )
        )
    }
    
    static func getEmptyTLEData() -> Data { Data() }

    static func loadOneLineTLEData() -> Data {
        let url = Bundle.module.url(
            forResource: "one_line_invalid_tle",
            withExtension: "txt",
            subdirectory: "Mocks"
        )!

        return try! Data(contentsOf: url)
    }
    
    static func loadLongerLineLengthTLEData() -> Data {
        let url = Bundle.module.url(
            forResource: "invalid_longer_line_length_tle",
            withExtension: "txt",
            subdirectory: "Mocks"
        )!

        return try! Data(contentsOf: url)
    }
    
    static func loadShorterLineLengthTLEData() -> Data {
        let url = Bundle.module.url(
            forResource: "invalid_shorter_line_length_tle",
            withExtension: "txt",
            subdirectory: "Mocks"
        )!

        return try! Data(contentsOf: url)
    }
    
    static func loadUTF8InvalidTLEData() -> Data {
        let url = Bundle.module.url(
            forResource: "utf8_tle",
            withExtension: "txt",
            subdirectory: "Mocks"
        )!
        
        return try! Data(contentsOf: url)
    }
    
    static func loadThreeValidTLEData() -> (Data, [TLE]) {
        let url = Bundle.module.url(
            forResource: "three_valid_tle",
            withExtension: "txt",
            subdirectory: "Mocks"
        )!
        
        return (
            try! Data(contentsOf: url),
            [
                try! TLE(
                    title: "ISS (ZARYA)",
                    firstLine: "1 25544U 98067A   25311.45303466  .00013372  00000+0  24333-3 0  9996",
                    secondLine: "2 25544  51.6332 317.1578 0005147  27.3119 332.8140 15.49822938537382"
                ),
                try! TLE(
                    title: "CSS (TIANHE)",
                    firstLine: "1 48274U 21035A   25311.80807516  .00039652  00000+0  46682-3 0  9996",
                    secondLine: "2 48274  41.4662 228.8136 0005483 340.8611  19.2021 15.60624711258578"
                ),
                try! TLE(
                    title: "ISS (NAUKA)",
                    firstLine: "1 49044U 21066A   25311.19511068  .00011482  00000+0  21019-3 0  9990",
                    secondLine: "2 49044  51.6334 318.4356 0005154  25.9626 334.1621 15.49813276230449"
                )
            ]
        )
    }
    
    static func loadMultipleNotValidTLEData() -> Data {
        let url = Bundle.module.url(
            forResource: "multiple_not_valid_tle",
            withExtension: "txt",
            subdirectory: "Mocks"
        )!
        
        return try! Data(contentsOf: url)
    }
}
