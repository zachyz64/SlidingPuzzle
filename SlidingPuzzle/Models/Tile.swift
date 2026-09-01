//
//  Tile.swift
//  SlidingPuzzle
//
//  Created by Zach Zaborowski on 8/25/26.
//

import MetalKit

struct Quad {
    
    let data: [simd_float2]
    
    init(topLeft: simd_float2, topRight: simd_float2, bottomLeft: simd_float2, bottomRight: simd_float2) {
        
        self.data = [
            bottomLeft, bottomRight, topRight,
            topRight, topLeft, bottomLeft
        ]
    }
}

class Tile {
    
    var screenQuad: Quad
    let textureQuad: Quad
    
    var isActive: Bool
    var gridAddress: Int = 0
    var correctAddress: Int = 0
    var location: simd_float2
    
    init(screenQuad: Quad, textureQuad: Quad, gridSize: Int) {
        self.screenQuad = screenQuad
        self.textureQuad = textureQuad
        self.isActive = true
        self.location = screenQuad.data[0]
        
        let row = Int(((1 + screenQuad.data[4].x) / 2 * Float(gridSize)).rounded())
        let col = gridSize - Int(((1 + screenQuad.data[4].y) / 2 * Float(gridSize)).rounded())
        self.gridAddress = row + col * gridSize
        
        let correctRow = Int(textureQuad.data[4].x * Float(gridSize))
        let correctCol = Int(textureQuad.data[4].y * Float(gridSize))
        self.correctAddress = correctRow + correctCol * gridSize
        
        print("Grid Address: \(self.gridAddress), Correct Address: \(self.correctAddress)")
    }
}
