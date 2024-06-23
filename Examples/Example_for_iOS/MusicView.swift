import AudioVisualizerKit
import SwiftUI

struct MusicView: View {
    let musicItem: MusicItem
    let audioAnalyzer = AudioAnalyzer(fftSize: 2048, windowType: .hammingWindow)

    var body: some View {
        AmplitudeSpectrumView(
            shapeType: .ring,
            magnitudes: audioAnalyzer.magnitudes,
            range: 0 ..< 64,
            rms: audioAnalyzer.rms
        )
        .padding(16)
        .navigationTitle(musicItem.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            do {
                try audioAnalyzer.play(url: musicItem.url)
            } catch {
                print(error.localizedDescription)
            }
        }
        .onDisappear {
            audioAnalyzer.stop()
        }
    }
}
