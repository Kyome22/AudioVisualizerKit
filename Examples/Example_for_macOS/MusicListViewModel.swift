import AudioVisualizerKit
import iTunesLibrary
import Observation
import SwiftUI

@Observable
final class MusicListViewModel {
    var musicItems = [MusicItem]()
    var selectedMusicItem: MusicItem?
    var isPlaying = false
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
        do {
            if musicItem != selectedMusicItem {
                if selectedMusicItem != nil {
                    audioAnalyzer.stop()
                }
                let url = musicItem.url
                if url.startAccessingSecurityScopedResource() {
                    defer {
                        url.stopAccessingSecurityScopedResource()
                    }
                    try audioAnalyzer.prepare(url: url)
                    selectedMusicItem = musicItem
                }
            }
            try audioAnalyzer.play()
            isPlaying = true
        } catch {
            Swift.print(error.localizedDescription)
        }
    }

    func pause() {
        audioAnalyzer.pause()
        isPlaying = false
    }
}
