import Foundation
@testable import SGPKit

final class TLETestUtils {
    static func loadValidTLEData() -> (Data, TLE) {
        return (
            fixture("valid_tle"),
            try! TLE(
                title: "ISS (ZARYA)",
                firstLine: "1 11416U 79057A   80003.44366214  .00000727  00000-0  33454-3 0   878",
                secondLine: "2 11416  98.7309  35.7226 0013335  92.0280 268.2428 14.22474848 27074"
            )
        )
    }
    
    /// Same orbital elements as the ISS TLE in `TLEInterpreterTests`, with catalog number 100001
    /// written in Alpha-5 form (`A0001`).
    static func alpha5TLE() -> TLE {
        try! TLE(
            title: "",
            firstLine: "1 A0001U 98067A   13165.59097222  .00004759  00000-0  88814-4 0    47",
            secondLine: "2 A0001  51.6478 121.2152 0011003  68.5125 263.9959 15.50783143834295"
        )
    }

    static func mismatchedCatalogNumbersTLE() -> TLE {
        try! TLE(
            title: "",
            firstLine: "1 25544U 98067A   13165.59097222  .00004759  00000-0  88814-4 0    47",
            secondLine: "2 25545  51.6478 121.2152 0011003  68.5125 263.9959 15.50783143834295"
        )
    }

    static func outOfRangeEccentricityTLE() -> TLE {
        try! TLE(
            title: "",
            firstLine: "1 25544U 98067A   13165.59097222  .00004759  00000-0  88814-4 0    47",
            secondLine: "2 25544  51.6478 121.2152 9995000  68.5125 263.9959 15.50783143834295"
        )
    }

    static func getEmptyTLEData() -> Data { Data() }

    static func getBlankLinesTLEData() -> Data { Data("\n\n  \n".utf8) }

    static func loadOneLineTLEData() -> Data {
        fixture("one_line_invalid_tle")
    }
    
    static func loadLongerLineLengthTLEData() -> Data {
        fixture("invalid_longer_line_length_tle")
    }
    
    static func loadShorterLineLengthTLEData() -> Data {
        fixture("invalid_shorter_line_length_tle")
    }
    
    static func loadUTF8InvalidTLEData() -> Data {
        fixture("utf8_tle")
    }
    
    static func loadThreeValidTLEData() -> (Data, [TLE]) {
        
        return (
            fixture("three_valid_tle"),
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
        fixture("multiple_not_valid_tle")
    }

    static func loadFeedWithoutTitlesTLEData() -> (Data, [TLE]) {
        let (_, threeValidTLEs) = loadThreeValidTLEData()

        return (
            fixture("feed_without_titles_tle"),
            threeValidTLEs.map(withoutTitle)
        )
    }

    static func loadFeedWithShortLineTLEData() -> (Data, [TLE]) {
        let (_, threeValidTLEs) = loadThreeValidTLEData()

        return (fixture("feed_with_short_line_tle"), [threeValidTLEs[0], threeValidTLEs[2]])
    }

    static func loadFeedWithMissingSecondLineTLEData() -> (Data, [TLE]) {
        let (_, threeValidTLEs) = loadThreeValidTLEData()

        return (fixture("feed_with_missing_second_line_tle"), [threeValidTLEs[0], threeValidTLEs[2]])
    }

    static func loadFeedEndingWithMissingSecondLineTLEData() -> (Data, [TLE]) {
        let (_, threeValidTLEs) = loadThreeValidTLEData()

        return (fixture("feed_ending_with_missing_second_line_tle"), [threeValidTLEs[0], threeValidTLEs[1]])
    }

    static func loadFeedWithMissingFirstLineTLEData() -> (Data, [TLE]) {
        let (_, threeValidTLEs) = loadThreeValidTLEData()

        return (fixture("feed_with_missing_first_line_tle"), [threeValidTLEs[0], threeValidTLEs[2]])
    }

    static func loadFeedWithTitlelessSetTLEData() -> (Data, [TLE]) {
        let (_, threeValidTLEs) = loadThreeValidTLEData()

        return (
            fixture("feed_with_titleless_set_tle"),
            [threeValidTLEs[0], withoutTitle(threeValidTLEs[1]), threeValidTLEs[2]]
        )
    }

    static func loadFeedEndingWithTitlelessSetTLEData() -> (Data, [TLE]) {
        let (_, threeValidTLEs) = loadThreeValidTLEData()

        return (
            fixture("feed_ending_with_titleless_set_tle"),
            [threeValidTLEs[0], threeValidTLEs[1], withoutTitle(threeValidTLEs[2])]
        )
    }

    static func loadFeedWithTitlelessSetWithShortLineTLEData() -> (Data, [TLE]) {
        let (_, threeValidTLEs) = loadThreeValidTLEData()

        return (fixture("feed_with_titleless_set_with_short_line_tle"), [threeValidTLEs[0], threeValidTLEs[2]])
    }

    static func loadFeedWithTitlelessFirstLineWithoutSecondLineTLEData() -> (Data, [TLE]) {
        let (_, threeValidTLEs) = loadThreeValidTLEData()

        return (fixture("feed_with_titleless_first_line_without_second_line_tle"), [threeValidTLEs[0], threeValidTLEs[2]])
    }

    static func loadFeedWithTitlelessSetOutOfOrderTLEData() -> (Data, [TLE]) {
        let (_, threeValidTLEs) = loadThreeValidTLEData()

        return (fixture("feed_with_titleless_set_out_of_order_tle"), [threeValidTLEs[0], threeValidTLEs[2]])
    }

    static func loadFeedWith3LETitlesTLEData() -> (Data, [TLE]) {
        let (_, threeValidTLEs) = loadThreeValidTLEData()

        return (
            fixture("feed_with_3le_titles_tle"),
            threeValidTLEs.map { try! TLE(title: "0 \($0.title)", firstLine: $0.firstLine, secondLine: $0.secondLine) }
        )
    }

    static func loadValidTitlelessTLEData() -> (Data, TLE) {
        return (fixture("valid_titleless_tle"), titlelessTLE())
    }

    static func loadTwoLinesStartingWithTitleTLEData() -> Data {
        fixture("two_lines_starting_with_title_tle")
    }

    static func titlelessTLE() -> TLE {
        withoutTitle(loadValidTLEData().1)
    }

    private static func withoutTitle(_ tle: TLE) -> TLE {
        try! TLE(firstLine: tle.firstLine, secondLine: tle.secondLine)
    }

    static func loadFeedWithDataLinesOutOfOrderTLEData() -> (Data, [TLE]) {
        let (_, threeValidTLEs) = loadThreeValidTLEData()

        return (fixture("feed_with_data_lines_out_of_order_tle"), [threeValidTLEs[0], threeValidTLEs[2]])
    }

    static func loadFeedWithLoneTitleTLEData() -> (Data, [TLE]) {
        let (_, threeValidTLEs) = loadThreeValidTLEData()

        return (fixture("feed_with_lone_title_tle"), [threeValidTLEs[0], threeValidTLEs[2]])
    }

    static func loadFeedWithBlankLinesAndMissingSecondLineTLEData() -> Data {
        fixture("feed_with_blank_lines_and_missing_second_line_tle")
    }

    static func loadFeedWithShortFirstLineAndMissingSecondLineTLEData() -> (Data, [TLE]) {
        let (_, threeValidTLEs) = loadThreeValidTLEData()

        return (fixture("feed_with_short_first_line_and_missing_second_line_tle"), [threeValidTLEs[0], threeValidTLEs[2]])
    }

    static func loadIssue16FeedTLEData() -> (Data, [TLE]) {
        return (
            fixture("issue_16_feed_tle"),
            [
                try! TLE(
                    title: "ISS (ZARYA)",
                    firstLine: "1 25544U 98067A   98324.28472222 -.00003657  11563-4  00000+0 0    10",
                    secondLine: "2 25544  51.5908 168.3788 0125362  86.4185 359.7454 16.05064833    05"
                ),
                try! TLE(
                    title: "DELTA 2 R/B(1)",
                    firstLine: "1 20453U 90008B   26263.56914166  .00350177  49935-4  75989-3 0  9996",
                    secondLine: "2 20453  35.5934 307.3932 0022512 310.3690  49.5094 15.96788691956793"
                )
            ]
        )
    }

    private static func fixture(_ name: String) -> Data {
        let url = Bundle.module.url(forResource: name, withExtension: "txt", subdirectory: "Mocks")!

        return try! Data(contentsOf: url)
    }
}
