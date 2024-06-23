import AudioVisualizerKit
import iTunesLibrary
import Observation
import SwiftUI

@Observable 
final class MusicListViewModel {
    var musicItems = [MusicItem]()
    var playingMusicItem: MusicItem?
    let audioAnalyzer = AudioAnalyzer(fftSize: 2048, windowType: .hammingWindow)

    func loadMusicItems() {
        do {
            let library = try ITLibrary(apiVersion: "1.0")
            musicItems = library.allMediaItems.compactMap { item in
                guard item.mediaKind == .kindSong,
                      item.locationType == .file,
                      let url = item.location else {
                    return nil
                }
                let id = item.persistentID.description
                return MusicItem(id: id, url: url, title: item.title)
            }
        } catch {
            return
        }
    }

    func play(musicItem: MusicItem) {
        let url = musicItem.url
        if url.startAccessingSecurityScopedResource() {
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            do {
                try audioAnalyzer.play(url: url)
            } catch {
                Swift.print(error.localizedDescription)
            }
        }
    }

    func stop() {
        audioAnalyzer.stop()
    }
}
