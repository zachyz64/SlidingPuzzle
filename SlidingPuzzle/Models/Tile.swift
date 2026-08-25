//
//  Tile.swift
//  SlidingPuzzle
//
//  Created by Zach Zaborowski on 8/25/26.
//

import MetalKit

struct Quad {
    let topLeft: simd_float2
    let topRight: simd_float2
    let bottomLeft: simd_float2
    let bottomRight: simd_float2
    
    let vertexBuffer: MTLBuffer?
    let vertexCount: Int
    
    init(device: MTLDevice, topLeft: simd_float2, topRight: simd_float2, bottomLeft: simd_float2, bottomRight: simd_float2) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
        
        let data: [simd_float2] = [
            bottomLeft, bottomRight, topRight,
            topRight, topLeft, bottomLeft
        ]
        
        self.vertexBuffer = device.makeBuffer(bytes: data, length: data.count * MemoryLayout<simd_float2>.stride)
        self.vertexCount = data.count
    }
}

class Tile {
    
    let screenQuad: Quad
    let textureQuad: Quad
    
    init(texture: MTLTexture, screenQuad: Quad, textureQuad: Quad) {
        self.screenQuad = screenQuad
        self.textureQuad = textureQuad
    }
}
