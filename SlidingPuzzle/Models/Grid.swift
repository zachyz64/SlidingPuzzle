//
//  Grid.swift
//  SlidingPuzzle
//
//  Created by Zach Zaborowski on 8/22/26.
//

import Foundation
import MetalKit
internal import Combine

class Grid: ObservableObject {
    
    let gridSize: Int = 4
    
    @Published var tilesToSlide: [Tile]
    @Published var freeSpaceAddress: Int
    @Published var cachedTileAddress: Int
    @Published var slideInProgress: Bool
    @Published var slideDistance: Float
    
    init(texture: MTLTexture) {
        self.tilesToSlide = []
        self.freeSpaceAddress = 0
        self.cachedTileAddress = 0
        self.slideInProgress = false
        self.slideDistance = 0.0
        createTiles(texture: texture)
    }
        
    func createTiles(texture: MTLTexture) {
        
        for i in 1...gridSize {
            for j in 1...gridSize {
                let bottomLeft: simd_float2 = simd_float2(x: -1 + 2 * Float(i-1) / Float(gridSize),
                                                          y: -1 + 2 * Float(j-1) / Float(gridSize))
                let bottomRight: simd_float2 = simd_float2(x: -1 + 2 * Float(i) / Float(gridSize),
                                                           y: -1 + 2 * Float(j-1) / Float(gridSize))
                let topLeft: simd_float2 = simd_float2(x: -1 + 2 * Float(i-1) / Float(gridSize),
                                                       y: -1 + 2 * Float(j) / Float(gridSize))
                let topRight: simd_float2 = simd_float2(x: -1 + 2 * Float(i) / Float(gridSize),
                                                        y: -1 + 2 * Float(j) / Float(gridSize))
                
                let vertices: Dictionary<String, simd_float2> = ["Bottom Left" : bottomLeft,
                                                                 "Bottom Right" : bottomRight,
                                                                 "Top Left" : topLeft,
                                                                 "Top Right" : topRight]
                for item in vertices {
                    print(item.key + ": [" + String(item.value.x) + ", " + String(item.value.y) + "]")
                }
                print("")
            }
            print("---------------------------")
        }
    }
}
