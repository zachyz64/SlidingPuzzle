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
    var tiles: [Tile]
    
    @Published var tilesToSlide: [Tile]
    @Published var freeSpaceAddress: Int
    @Published var cachedTileAddress: Int
    @Published var slideInProgress: Bool
    @Published var slideDistance: Float
    
    init(device: MTLDevice, filename: String, filenameExtension: String) {
        self.tiles = []
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
                                                   ])
        } catch {
            fatalError("Couldn't load material \(filename)")
        }
        
        return newTexture!
    }
    
    func createTiles(_ device: MTLDevice) {
        
        for i in 1...gridSize {
            for j in 1...gridSize {
                
                let topLeft = simd_float2(Float(i-1), Float(j-1)) / Float(gridSize)
                let topRight = simd_float2(Float(i), Float(j-1)) / Float(gridSize)
                let bottomLeft = simd_float2(Float(i-1), Float(j)) / Float(gridSize)
                let bottomRight = simd_float2(Float(i), Float(j)) / Float(gridSize)
                
                // Tile Position
                let screenQuad: Quad = Quad(topLeft: simd_float2(x: -1 + 2 * topLeft.x,
                                                                 y:  1 - 2 * topLeft.y),
                                            topRight: simd_float2(x: -1 + 2 * topRight.x,
                                                                  y:  1 - 2 * topRight.y),
                                            bottomLeft: simd_float2(x: -1 + 2 * bottomLeft.x,
                                                                    y:  1 - 2 * bottomLeft.y),
                                            bottomRight: simd_float2(x: -1 + 2 * bottomRight.x,
                                                                     y:  1 - 2 * bottomRight.y))
                // Tile TexCoords
                let textureQuad: Quad = Quad(topLeft: topLeft,
                                             topRight: topRight,
                                             bottomLeft: bottomLeft,
                                             bottomRight: bottomRight)
                
                tiles.append(Tile(device: device, screenQuad: screenQuad, textureQuad: textureQuad))

                if (i == gridSize && j == gridSize) {
                    tiles.last?.isActive = false
                }

                print("------------------------")
                print("Screen Quad")
                print(" TopLeft: \(screenQuad.data[4])")
                print(" TopRight: \(screenQuad.data[3])")
                print(" BottomLeft: \(screenQuad.data[0])")
                print(" BottomRight: \(screenQuad.data[1])")
                print("")
                print("Texture Quad")
                print(" TopLeft: \(textureQuad.data[4])")
                print(" TopRight: \(textureQuad.data[3])")
                print(" BottomLeft: \(textureQuad.data[0])")
                print(" BottomRight: \(textureQuad.data[1])")
                print("------------------------")
                print("")
            }
            print("")
        }
    }
}
