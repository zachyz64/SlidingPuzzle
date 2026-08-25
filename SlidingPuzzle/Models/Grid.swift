//
//  Grid.swift
//  SlidingPuzzle
//
//  Created by Zach Zaborowski on 8/22/26.
//

import Foundation
internal import Combine

class Grid: ObservableObject {
    
    @Published var tilesToSlide: [Tile]
    @Published var freeSpaceAddress: Int
    @Published var cachedTileAddress: Int
    @Published var slideInProgress: Bool
    @Published var slideDistance: Float
    
    init() {
        createTiles()
        self.tilesToSlide = []
        self.freeSpaceAddress = 0
        self.cachedTileAddress = 0
        self.slideInProgress = false
        self.slideDistance = 0.0
    }
        
    func createTiles() {
        
    }
}
