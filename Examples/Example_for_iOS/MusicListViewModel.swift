import AudioVisualizerKit
import MediaPlayer
import Observation
import SwiftUI

@Observable
final class MusicListViewModel {
    var searchText: String = ""
    var musicItems = [MusicItem]()

    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error.localizedDescription)
        }
    }

    func requestAuthorization() async {
        let status = await MPMediaLibrary.requestAuthorization()
        switch status {
        case .notDetermined:
            print("notDetermined")
        case .denied:
            print("denied")
        case .restricted:
            print("restricted")
        case .authorized:
            loadMusicItems()
        @unknown default:
            fatalError()
        }
    }

    private func loadMusicItems() {
        guard let mediaItems = MPMediaQuery.songs().items else { return }
        musicItems = mediaItems.compactMap { item in
            guard let url = item.assetURL, let title = item.title else { return nil }
            return MusicItem(id: item.persistentID.description, url: url, title: title)
        }
    }
}
