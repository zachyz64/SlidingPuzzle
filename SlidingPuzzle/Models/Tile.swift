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
    let vertexBuffer: MTLBuffer?
    let vertexCount: Int
    
    init(device: MTLDevice, screenQuad: Quad, textureQuad: Quad) {
        self.screenQuad = screenQuad
        self.textureQuad = textureQuad
        
        let data = textureQuad.data
        self.vertexBuffer = device.makeBuffer(bytes: data,
                                              length: data.count * MemoryLayout<simd_float2>.stride)
        self.vertexCount = data.count
    }
}
