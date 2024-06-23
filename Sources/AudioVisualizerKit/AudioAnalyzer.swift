import AVFoundation
import Observation

protocol AudioAnalyzerProtocol: AnyObject {
    init(fftSize: Int, windowType: WindowType)
    func play(url: URL) throws
    func stop()
}

@Observable
public final class AudioAnalyzer: AudioAnalyzerProtocol {
    private let fftSize: Int
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let fft: FFT

    public var magnitudes: [Magnitude]

    public init(fftSize: Int = 2048, windowType: WindowType = .hannWindow) {
        self.fftSize = fftSize
        fft = FFT(size: fftSize, windowType: windowType)
        magnitudes = .init(repeating: .zero, count: fftSize / 2)
    }

    public func play(url: URL) throws {
        let audioFile = try AVAudioFile(forReading: url)
        let sampleRate = Float(audioFile.processingFormat.sampleRate)
        audioEngine.attach(playerNode)
        audioEngine.connect(
            playerNode,
            to: audioEngine.mainMixerNode,
            format: audioFile.processingFormat
        )
        playerNode.installTap(
            onBus: .zero,
            bufferSize: AVAudioFrameCount(fftSize),
            format: nil
        ) { [weak self] buffer, _ in
            self?.calculate(sampleRate: sampleRate, buffer: buffer)
        }
        playerNode.scheduleFile(audioFile, at: nil)
        try audioEngine.start()
        playerNode.play()
    }

    public func stop() {
        if playerNode.isPlaying {
            playerNode.stop()
        }
        playerNode.removeTap(onBus: 0)
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.disconnectNodeOutput(playerNode)
        audioEngine.detach(playerNode)
    }

    func calculate(sampleRate: Float, buffer: AVAudioPCMBuffer) {
        if let data = buffer.floatChannelData {
            magnitudes = fft.compute(sampleRate: sampleRate, audioData: data.pointee)
        }
    }
}
