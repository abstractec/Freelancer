//
//  ClientRow.swift
//  Freelancer
//
//  Created by John Haselden on 01/07/2024.
//

import SwiftUI

struct ClientRow: View {
    var client: Client
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(client.name)
                    .bold()
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    return Group {
        ClientRow(client: ModelData.shared.client)
    }
}

