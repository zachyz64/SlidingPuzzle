//
//  SlidingPuzzleApp.swift
//  SlidingPuzzle
//
//  Created by Zach Zaborowski on 8/22/26.
//

import SwiftUI

@main
struct SlidingPuzzleApp: App {
    
    @StateObject private var grid = Grid()
    @StateObject private var images = ImageList()
    
    var body: some Scene {
        WindowGroup {
            GameView()
                .environmentObject(grid)
                .environmentObject(images)
        }
    }
}
