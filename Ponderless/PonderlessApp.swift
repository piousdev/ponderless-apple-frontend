//
//  PonderlessApp.swift
//  Ponderless
//
//  Created by Pious Alpha on 11/11/2025.
//

import SwiftUI
import UIKit

@main
struct PonderlessApp: App {
    init() {
        // Debug: Print all available fonts
        #if DEBUG
        print("📝 Available Font Families:")
        for family in UIFont.familyNames.sorted() {
            print("  Family: \(family)")
            for font in UIFont.fontNames(forFamilyName: family) {
                print("    - \(font)")
            }
        }

        // Test IBM Plex Sans specifically
        print("\n🔍 Testing IBM Plex Sans fonts:")
        let testFonts = ["IBMPlexSans-Regular", "IBMPlexSans-Bold", "IBMPlexSans-SemiBold", "IBMPlexSans-Medium"]
        for fontName in testFonts {
            if let font = UIFont(name: fontName, size: 16) {
                print("  ✅ \(fontName) loaded successfully")
            } else {
                print("  ❌ \(fontName) FAILED to load")
            }
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
