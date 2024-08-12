import AudioVisualizerKit
import SwiftUI

struct MusicListView: View {
    let model = MusicListViewModel()

    var body: some View {
        VStack {
            Text("Title: \(model.selectedMusicItem?.title ?? "-")")
            AmplitudeSpectrumView(
                shapeType: .straight,
                magnitudes: model.audioAnalyzer.magnitudes,
                range: 0 ..< 128,
                rms: nil
            )
            Text("Total: \(model.musicItems.count)")
            List {
                ForEach(model.musicItems) { musicItem in
                    HStack {
                        Text(musicItem.title)
                        Spacer()
                        if musicItem == model.selectedMusicItem, model.isPlaying {
                            Button {
                                model.pause()
                            } label: {
                                Image(systemName: "pause.fill")
                            }
                        } else {
                            Button {
                                model.play(musicItem: musicItem)
                            } label: {
                                Image(systemName: "play.fill")
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            model.loadMusicItems()
        }
    }
}

#Preview {
    MusicListView()
}
