import XCTest
import Foundation
@testable import AudioVisualizerKit

final class FFTTests: XCTestCase {
    func test_compute_hannWindow() {
        let fftSize: Int = 512
        let sampleRate: Float = 512
        let frequency: Float = 30
        var data: [Float] = (0 ..< fftSize).map { i in
            sinf(frequency / sampleRate * 2 * Float.pi * Float(i))
        }
        let fft = FFT(size: fftSize, windowType: .hannWindow)
        let actual = fft.compute(sampleRate: sampleRate, audioData: &data)
        XCTAssertEqual(actual.count, 256)
        let peak = actual.max { $0.value < $1.value }?.hertz
        XCTAssertEqual(peak, frequency)
    }

    func test_compute_hammingWindow() {
        let fftSize: Int = 512
        let sampleRate: Float = 512
        let frequencyA: Float = 30
        let frequencyB: Float = 60
        var data: [Float] = (0 ..< fftSize).map { i in
            let a = sinf(frequencyA / sampleRate * 2 * Float.pi * Float(i))
            let b = 0.5 * sinf(frequencyB / sampleRate * 2 * Float.pi * Float(i))
            return a + b
        }
        let fft = FFT(size: fftSize, windowType: .hammingWindow)
        let actual = fft.compute(sampleRate: sampleRate, audioData: &data)
        XCTAssertEqual(actual.count, 256)
        let peaks = actual.sorted { $0.value > $1.value }
        XCTAssertEqual(peaks[0].hertz, frequencyA)
        XCTAssertEqual(peaks[1].hertz, frequencyB)
    }

    func test_compute_blackmanWindow() throws {
        let fftSize: Int = 2048
        let sampleRate: Float = 44100
        let frequency: Float = 440
        var data: [Float] = (0 ..< fftSize).map { i in
            sinf(frequency / sampleRate * 2 * Float.pi * Float(i))
        }
        let fft = FFT(size: fftSize, windowType: .blackmanWindow)
        let actual = fft.compute(sampleRate: sampleRate, audioData: &data)
        XCTAssertEqual(actual.count, 1024)
        let peak = try XCTUnwrap(actual.max { $0.value < $1.value }?.hertz)
        XCTAssertGreaterThan(peak, frequency - 10)
        XCTAssertLessThan(peak, frequency + 10)
    }
}
