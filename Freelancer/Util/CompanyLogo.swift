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
    /// Used by the PDF renderer, which does not have a model context to load the logo from.
    var image: PlatformImage?
    
    private var resolvedImage: PlatformImage? {
        image ?? CompanyLogoStore.loadImage(from: settings)
    }
    
    var body: some View {
        Group {
            if let resolvedImage {
                #if os(macOS)
                Image(nsImage: resolvedImage)
                    .resizable()
                    .scaledToFit()
                #else
                Image(uiImage: resolvedImage)
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
            width: (resolvedImage != nil || showsPlaceholder) ? size : 0,
            height: (resolvedImage != nil || showsPlaceholder) ? size : 0
        )
        .accessibilityLabel(resolvedImage == nil ? "No invoice logo" : "Invoice logo")
    }
}
