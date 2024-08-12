import AVFoundation
import Observation

protocol AudioAnalyzerProtocol: AnyObject {
    init(fftSize: Int, windowType: WindowType)
    func prepare(url: URL) throws
    func play() throws
    func stop()
}

@Observable
public final class AudioAnalyzer: AudioAnalyzerProtocol {
    private let fftSize: Int
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let fft: FFT
    private var isPrepared = false

    public var magnitudes: [Magnitude]
    public var rms: Float = .zero

    public init(fftSize: Int = 2048, windowType: WindowType = .hannWindow) {
        self.fftSize = fftSize
        fft = FFT(size: fftSize, windowType: windowType)
        magnitudes = .init(repeating: .zero, count: fftSize / 2)
    }

    public func prepare(url: URL) throws {
        stop()
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
        isPrepared = true
    }

    public func play() throws {
        guard isPrepared else { return }
        if !audioEngine.isRunning {
            try audioEngine.start()
        }
        if !playerNode.isPlaying {
            playerNode.play()
        }
    }

    public func pause() {
        if playerNode.isPlaying {
            playerNode.pause()
        }
    }

    public func stop() {
        guard isPrepared else { return }
        if playerNode.isPlaying {
            playerNode.stop()
        }
        playerNode.removeTap(onBus: .zero)
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.disconnectNodeOutput(playerNode)
        audioEngine.detach(playerNode)
        isPrepared = false
    }

    func calculate(sampleRate: Float, buffer: AVAudioPCMBuffer) {
        if let data = buffer.floatChannelData, playerNode.isPlaying {
            magnitudes = fft.compute(sampleRate: sampleRate, audioData: data.pointee)
            rms = fft.rms(audioData: data.pointee)
        }
    }
}
