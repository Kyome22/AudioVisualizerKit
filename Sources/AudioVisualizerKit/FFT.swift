import Accelerate

public enum WindowType {
    case hannWindow
    case hammingWindow
    case blackmanWindow
}

public final class FFT {
    private let fftFullLength: vDSP_Length
    private let fftHalfLength: vDSP_Length
    private let windowType: WindowType
    private let mLog2N: vDSP_Length
    private var fftSetup: FFTSetup?

    public init(length: Int, windowType: WindowType = .hannWindow) {
        fftFullLength = vDSP_Length(length)
        fftHalfLength = vDSP_Length(length / 2)
        self.windowType = windowType
        mLog2N = vDSP_Length(log2(Double(length)).rounded() + 1.0)
        fftSetup = vDSP_create_fftsetup(mLog2N, FFTRadix(kFFTRadix2))
    }

    deinit {
        vDSP_destroy_fftsetup(fftSetup)
    }

    public func compute(_ inAudioData: UnsafePointer<Float>) -> [Float] {
        guard let fftSetup else {
            return [Float](repeating: 0, count: Int(fftHalfLength))
        }
        // Applies the window function.
        let windowData = UnsafeMutablePointer<Float>.allocate(capacity: Int(fftFullLength))
        defer {
            windowData.deallocate()
        }
        // Creates the window data.
        switch windowType {
        case .hannWindow:
            vDSP_hann_window(windowData, fftFullLength, 0)
        case .hammingWindow:
            vDSP_hamm_window(windowData, fftFullLength, 0)
        case .blackmanWindow:
            vDSP_blkman_window(windowData, fftFullLength, 0)
        }
        // Computes the element-wise product of two vectors
        // [1, 2, 3, 4, 5] * [10, 20, 30, 40, 50] => [10, 40, 90, 160, 250]
        vDSP_vmul(inAudioData, 1, windowData, 1, windowData, 1, fftFullLength)

        // Put signal data into real part of complex vector.
        var dspSplitComplex = DSPSplitComplex(
            realp: windowData,
            imagp: UnsafeMutablePointer<Float>.allocate(capacity: Int(fftFullLength))
        )
        defer {
            dspSplitComplex.imagp.deallocate()
        }

        // Computes FFT.
        vDSP_fft_zrip(fftSetup, &dspSplitComplex, 1, mLog2N, FFTDirection(FFT_FORWARD))

        // Calculates the element-wise division of a vector and a scalar value.
        // Divide the FFT result by the number of elements.
        var fftNormFactor = Float(fftFullLength)
        vDSP_vsdiv(dspSplitComplex.realp, 1, &fftNormFactor, dspSplitComplex.realp, 1, fftHalfLength)
        vDSP_vsdiv(dspSplitComplex.imagp, 1, &fftNormFactor, dspSplitComplex.imagp, 1, fftHalfLength)

        // Computes the element-wise absolute value of a complex vector.
        // sqrt(real * real + imag * imag)
        var outFFTData = [Float](repeating: 0, count: Int(fftHalfLength))
        vDSP_zvabs(&dspSplitComplex, 1, &outFFTData, 1, fftHalfLength)

        // Multiply by 2 to get the correct amplitude.
        var fftHalfFactor = Float(2)
        vDSP_vsmul(outFFTData, 1, &fftHalfFactor, &outFFTData, 1, fftHalfLength)

        return outFFTData
    }
}
