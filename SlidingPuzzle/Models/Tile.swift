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
        self.location = screenQuad.data[4]
        
        let row = gridSize - Int(((1 + screenQuad.data[4].y) / 2 * Float(gridSize)).rounded())
        let col = Int(((1 + screenQuad.data[4].x) / 2 * Float(gridSize)).rounded())
        self.gridAddress = row * gridSize + col
        
        let correctRow = Int(textureQuad.data[4].y * Float(gridSize))
        let correctCol = Int(textureQuad.data[4].x * Float(gridSize))
        self.correctAddress = correctRow * gridSize + correctCol
    }
    
    func updateScreenQuad(location: simd_float2) {
        let delta = screenQuad.data[1].x - screenQuad.data[0].x
        screenQuad = Quad(topLeft: location,
                          topRight: location + simd_float2(x: delta, y: 0.0),
                          bottomLeft: location + simd_float2(x: 0.0, y: -delta ),
                          bottomRight: location + simd_float2(x: delta, y: -delta))
    }
}
