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
    
    let screenQuad: Quad
    let textureQuad: Quad
    
    var isActive: Bool
    
    init(device: MTLDevice, screenQuad: Quad, textureQuad: Quad) {
        self.screenQuad = screenQuad
        self.textureQuad = textureQuad
        self.isActive = true
        
        let data = textureQuad.data
    }
}
