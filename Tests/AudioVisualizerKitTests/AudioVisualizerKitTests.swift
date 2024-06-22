import XCTest
import Foundation
@testable import AudioVisualizerKit

final class AudioVisualizerKitTests: XCTestCase {
    func testExample() throws {
        var data: [Float] = (0 ..< 512).map { i in
            sinf(30 / 512 * 2 * Float.pi * Float(i))
        }
        let fft = FFT(length: 512)
        let actual = fft.compute(&data)
        XCTAssertEqual(actual.count, 256)
        let peak = actual.enumerated().max { $0.element < $1.element }?.offset
        XCTAssertEqual(peak, 30)
    }
}
