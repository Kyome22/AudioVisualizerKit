import AudioVisualizerKit
import SwiftUI

struct MusicListView: View {
    let model = MusicListViewModel()

    var body: some View {
        VStack {
            Text("Title: \(model.playingMusicItem?.title ?? "unknown")")
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
                        if musicItem == model.playingMusicItem {
                            Button {
                                model.playingMusicItem = nil
                                model.stop()
                            } label: {
                                Image(systemName: "stop.fill")
                            }
                        } else {
                            Button {
                                model.playingMusicItem = musicItem
                                model.play(musicItem: musicItem)
                            } label: {
                                Image(systemName: "play.fill")
                            }
                            .disabled(model.playingMusicItem != nil)
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
