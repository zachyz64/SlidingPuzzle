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
    
    let gridSize: Int = 2
    
    var texture: MTLTexture?
    
    @Published var tilesToSlide: [Tile]
    @Published var freeSpaceAddress: Int
    @Published var cachedTileAddress: Int
    @Published var slideInProgress: Bool
    @Published var slideDistance: Float
    
    init(device: MTLDevice, filename: String, filenameExtension: String) {
        self.tilesToSlide = []
        self.freeSpaceAddress = 0
        self.cachedTileAddress = 0
        self.slideInProgress = false
        self.slideDistance = 0.0
        self.texture = loadTexture(device: device, filename, filenameExtension)
        createTiles(device)
    }
        
    func loadTexture(device: MTLDevice, _ filename: String, _ filenameExtension: String) -> MTLTexture {
        
        guard let textureURL = Bundle.main.url(forResource: filename, withExtension: filenameExtension) else {
            fatalError("Failed to find image \(filename).\(filenameExtension)")
        }
        
        let textureLoader = MTKTextureLoader(device: device)
        var newTexture: MTLTexture?
        do {
            newTexture = try textureLoader.newTexture(URL: textureURL,
                                                   options: [
                                                        .SRGB: false,
                                                        .generateMipmaps: false,
                                                        .origin: MTKTextureLoader.Origin.flippedVertically
                                                   ])
        } catch {
            fatalError("Couldn't load material \(filename)")
        }
        
        return newTexture!
    }
    
    func createTiles(_ device: MTLDevice) {
        
        for i in 1...gridSize {
            for j in 1...gridSize {
                // Tile Position
                let screenQuad: Quad = Quad(topLeft: simd_float2(x: -1 + 2 * Float(i-1) / Float(gridSize),
                                                                 y: -1 + 2 * Float(j) / Float(gridSize)),
                                            topRight: simd_float2(x: -1 + 2 * Float(i) / Float(gridSize),
                                                                  y: -1 + 2 * Float(j) / Float(gridSize)),
                                            bottomLeft: simd_float2(x: -1 + 2 * Float(i-1) / Float(gridSize),
                                                                    y: -1 + 2 * Float(j-1) / Float(gridSize)),
                                            bottomRight: simd_float2(x: -1 + 2 * Float(i) / Float(gridSize),
                                                                     y: -1 + 2 * Float(j-1) / Float(gridSize)))
                // Tile TexCoords
                let textureQuad: Quad = Quad(topLeft: simd_float2(x: Float(i-1) / Float(gridSize),
                                                                  y: Float(j) / Float(gridSize)),
                                             topRight: simd_float2(x: Float(i) / Float(gridSize),
                                                                   y: Float(j) / Float(gridSize)),
                                             bottomLeft: simd_float2(x: Float(i-1) / Float(gridSize),
                                                                     y: Float(j-1) / Float(gridSize)),
                                             bottomRight: simd_float2(x: Float(i) / Float(gridSize),
                                                                      y: Float(j-1) / Float(gridSize)))
                
                var tile = Tile(device: device, screenQuad: screenQuad, textureQuad: textureQuad)
            }
        }
    }
}
