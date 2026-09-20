//
//  CompanyLogo.swift
//  Freelancer
//
//  Created by John Haselden on 19/09/2026.
//

import SwiftUI
import SwiftData

#if os(macOS)
import AppKit
typealias PlatformImage = NSImage
#else
import UIKit
typealias PlatformImage = UIImage
#endif

enum CompanyLogoStore {
    static func save(from sourceURL: URL, into settings: UserSettings) throws {
        let accessed = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }
        
        let data = try Data(contentsOf: sourceURL)
        settings.logoData = data
        settings.logoFilename = sourceURL.lastPathComponent
    }
    
    static func remove(from settings: UserSettings) {
        settings.logoData = nil
        settings.logoFilename = nil
    }
    
    static func loadImage(from settings: UserSettings?) -> PlatformImage? {
        guard let data = settings?.logoData, !data.isEmpty else {
            return nil
        }
        
        #if os(macOS)
        return NSImage(data: data)
        #else
        return UIImage(data: data)
        #endif
    }
}

struct InvoiceLogoView: View {
    var size: CGFloat = 120
    var showsPlaceholder: Bool = false
    var settings: UserSettings?
    
    private var image: PlatformImage? {
        CompanyLogoStore.loadImage(from: settings)
    }
    
    var body: some View {
        Group {
            if let image {
                #if os(macOS)
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                #else
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                #endif
            } else if showsPlaceholder {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.secondary, style: StrokeStyle(lineWidth: 1, dash: [4]))
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(
            width: (image != nil || showsPlaceholder) ? size : 0,
            height: (image != nil || showsPlaceholder) ? size : 0
        )
        .accessibilityLabel(image == nil ? "No invoice logo" : "Invoice logo")
    }
}
