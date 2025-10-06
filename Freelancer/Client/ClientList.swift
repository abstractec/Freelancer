//
//  ClientList.swift
//  Freelancer
//
//  Created by John Haselden on 01/07/2024.
//

import SwiftUI
import SwiftData

struct ClientList: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Client.name) private var clients: [Client]
    @State private var showFavoritesOnly = false

    var body: some View {
        NavigationSplitView {
            List {
                Toggle(isOn: $showFavoritesOnly) {
                    Text("Favorites only")
                }

                ForEach(clients) { client in
                    NavigationLink {
                        ClientDetail(client: client)
                    } label: {
                        ClientRow(client: client)
                    }
                }
            }
            .animation(.default, value: clients)
            .navigationTitle("Landmarks")
        } detail: {
            Text("Select a Landmark")
        }
    }
}

#Preview {
    ClientList()
        .modelContainer(ModelData.shared.modelContainer)
}
