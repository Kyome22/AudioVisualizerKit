import SwiftUI

struct MusicListView: View {
    @Bindable var model = MusicListViewModel()

    var body: some View {
        NavigationStack {
            List(model.musicItems.filter({ item in
                item.title.lowercased().hasPrefix(model.searchText.lowercased())
            })) { item in
                NavigationLink(value: item) {
                    Text(item.title)
                }
            }
            .searchable(text: $model.searchText)
            .navigationTitle("Musics")
            .navigationDestination(for: MusicItem.self) { item in
                MusicView(musicItem: item)
            }
            .task {
                await model.requestAuthorization()
            }
        }
    }
}

#Preview {
    MusicListView()
}

