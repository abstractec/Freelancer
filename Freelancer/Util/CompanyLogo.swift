//
//  CompanyLogo.swift
//  Freelancer
//
//  Created by John Haselden on 19/09/2026.
//

import SwiftUI

#if os(macOS)
import AppKit
typealias PlatformImage = NSImage
#else
import UIKit
typealias PlatformImage = UIImage
#endif

enum CompanyLogoStore {
    private static let filenameKey = "companyLogoFilename"
    
    static var directory: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Freelancer", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
    
    static var storedURL: URL? {
        guard let name = UserDefaults.standard.string(forKey: filenameKey) else {
            return nil
        }
        
        let url = directory.appendingPathComponent(name)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }
    
    static var hasLogo: Bool {
        storedURL != nil
    }
    
    static func save(from sourceURL: URL) throws {
        let accessed = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }
        
        let ext = sourceURL.pathExtension.isEmpty ? "png" : sourceURL.pathExtension.lowercased()
        let dest = directory.appendingPathComponent("company-logo.\(ext)")
        
        if FileManager.default.fileExists(atPath: dest.path) {
            try FileManager.default.removeItem(at: dest)
        }
        
        try FileManager.default.copyItem(at: sourceURL, to: dest)
        UserDefaults.standard.set(dest.lastPathComponent, forKey: filenameKey)
    }
    
    static func remove() {
        if let url = storedURL {
            try? FileManager.default.removeItem(at: url)
        }
        UserDefaults.standard.removeObject(forKey: filenameKey)
    }
    
    static func loadImage() -> PlatformImage? {
        guard let url = storedURL else {
            return nil
        }
        
        #if os(macOS)
        return NSImage(contentsOf: url)
        #else
        return UIImage(contentsOfFile: url.path)
        #endif
    }
}

struct InvoiceLogoView: View {
    var size: CGFloat = 120
    var showsPlaceholder: Bool = false
    
    private let image: PlatformImage?
    
    init(size: CGFloat = 120, showsPlaceholder: Bool = false) {
        self.size = size
        self.showsPlaceholder = showsPlaceholder
        self.image = CompanyLogoStore.loadImage()
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
        .frame(width: (image != nil || showsPlaceholder) ? size : 0, height: (image != nil || showsPlaceholder) ? size : 0)
        .accessibilityLabel(image == nil ? "No invoice logo" : "Invoice logo")
    }
}
