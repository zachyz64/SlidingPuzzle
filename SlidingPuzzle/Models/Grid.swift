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
    
    private let gridSize: Int = 5
    private let timerRate: Float = 0.02
    private let moveSpeed: Float = 2.0
    private let tileSize: Float
    
    private var slideTimer: Timer
    
    var texture: MTLTexture?
    var tiles: [Tile]
    
    @Published var moves: Int
    @Published var tilesToSlide: [Tile]
    var freeSpaceAddress: Int
    @Published var cachedTileAddress: Int
    @Published var slideInProgress: Bool
    @Published var slideDistance: Float
    
    @Published var showTiles: Bool
    
    init() {
        self.tileSize = 2.0 / Float(gridSize)
        self.slideTimer = Timer()
        
        self.tiles = []
        
        self.moves = 0
        self.tilesToSlide = []
        self.freeSpaceAddress = gridSize * gridSize - 2
        self.cachedTileAddress = 0
        self.slideInProgress = false
        self.slideDistance = 0.0
        self.showTiles = true
    }
    
    init(device: MTLDevice, filename: String, filenameExtension: String) {
        self.tileSize = 2.0 / Float(gridSize)
        self.slideTimer = Timer()

        self.tiles = []
        
        self.moves = 0
        self.tilesToSlide = []
        self.freeSpaceAddress = gridSize * gridSize - 1
        self.cachedTileAddress = 0
        self.slideInProgress = false
        self.slideDistance = 0.0
        self.showTiles = true
        self.texture = loadTexture(device: device, filename, filenameExtension)
        createTiles()
    }
    
    func update(device: MTLDevice, filename: String, filenameExtension: String) {
        self.texture = loadTexture(device: device, filename, filenameExtension)
        createTiles()
    }
    
    private func loadTexture(device: MTLDevice, _ filename: String, _ filenameExtension: String) -> MTLTexture {
        
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
    
    private func createTiles() {
        
        for i in 1...gridSize {
            for j in 1...gridSize {
                
                let topLeft = simd_float2(Float(j-1), Float(i-1)) / Float(gridSize)
                let topRight = simd_float2(Float(j), Float(i-1)) / Float(gridSize)
                let bottomLeft = simd_float2(Float(j-1), Float(i)) / Float(gridSize)
                let bottomRight = simd_float2(Float(j), Float(i)) / Float(gridSize)
                
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
                
                tiles.append(Tile(screenQuad: screenQuad, textureQuad: textureQuad, gridSize: gridSize))

                if (i == gridSize && j == gridSize) {
                    tiles.last?.isActive = false
                    freeSpaceAddress = i*j-1
                }
                /*
                if (i + j) % 2 == 0 {
                    tiles.last?.isActive = false
                    //freeSpaceAddress = i*j-1
                }
                 */
                
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
    
    func onTileWasSelected(location: CGPoint, dimension: CGFloat) {
        
        if slideInProgress || (dimension < 0 && dimension > 600) { return }
        
        let location = simd_float2(Float(location.x), Float(location.y)) / Float(dimension)
        
        let selectedTileAddress: Int = getGridAddress(location: location)
        if canTileSlide(selectedTileAddress) {
            getTilesToSlide(selectedTileAddress)
            slideTiles()
        }
        
    }
    
    private func canTileSlide(_ address: Int) -> Bool {
        
        if address == freeSpaceAddress { return false }
        
        if address >= 0 && address < gridSize * gridSize {
            let freeSpaceRow = freeSpaceAddress / gridSize
            let freeSpaceCol = freeSpaceAddress % gridSize
            let tileRow = address / gridSize
            let tileCol = address % gridSize
            
            if tileRow == freeSpaceRow || tileCol == freeSpaceCol {
                return true
            }
        }
        return false
    }
    
    private func getTilesToSlide(_ address: Int) {
        let freeSpaceRow = freeSpaceAddress / gridSize
        let freeSpaceCol = freeSpaceAddress % gridSize
        let tileRow = address / gridSize
        let tileCol = address % gridSize
        
        if tileRow == freeSpaceRow {
            
            let distance = freeSpaceCol - tileCol
            for i in 0..<abs(distance) {
                let oldAddress = address + distance / abs(distance) * i
                tiles[oldAddress].gridAddress = oldAddress + distance / abs(distance)
                tilesToSlide.append(tiles[oldAddress])
            }
        } else if tileCol == freeSpaceCol {
            
            let distance = freeSpaceRow - tileRow
            for i in 0..<abs(distance) {
                let oldAddress = address + distance / abs(distance) * gridSize * i
                tiles[oldAddress].gridAddress = oldAddress + distance / abs(distance) * gridSize
                tilesToSlide.append(tiles[oldAddress])
            }
        } else {
            fatalError()
        }
        tiles[freeSpaceAddress].gridAddress = address
        cachedTileAddress = address
    }
    
    private func slideTiles() {
        print("Slide started\n")
        slideInProgress = true
        var directionVector = simd_normalize(getLocationFromGridAddress(freeSpaceAddress) - tilesToSlide[0].location)
        directionVector.x = directionVector.x.rounded()
        directionVector.y = directionVector.y.rounded()
        slideTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.doSlide(directionVector)
        }
    }
    
    private func doSlide(_ directionVector: simd_float2) {
        slideDistance += moveSpeed * timerRate
        let reachedDestination = slideDistance >= tileSize
        
        for i in 0..<tilesToSlide.count {
            let addressDiff = freeSpaceAddress - tilesToSlide[i].gridAddress
            let sign = abs(addressDiff) != 0 ? addressDiff / abs(addressDiff) : 0
            let offset = (addressDiff % gridSize == 0) ? gridSize * sign * (i + 1 - tilesToSlide.count)
                                                : sign * (i + 1 - tilesToSlide.count)
            let newLocation = reachedDestination ?
                getLocationFromGridAddress(freeSpaceAddress + offset) :
                tilesToSlide[i].location + moveSpeed * timerRate * directionVector
            
            tilesToSlide[i].location = newLocation
            tilesToSlide[i].updateScreenQuad(location: newLocation)
        }
        print("Slide Distance: \(slideDistance)\n")
        if reachedDestination {
            slideTimer.invalidate()
            onSlideFinished()
        }
    }
    
    private func onSlideFinished() {
        slideInProgress = false
        slideDistance = 0.0
        freeSpaceAddress = cachedTileAddress
        tilesToSlide.removeAll()
        
        updateTiles()
        
        if isSolved() {
            print("Puzzle is solved!\n")
        }
        print("Slide finished\n")
        moves += 1
    }
    
    private func updateTiles() {
        var tempArray: [Tile] = []
        tempArray.reserveCapacity(tiles.count)
        
        for i in 0..<tiles.count {
            for tile in tiles {
                if tile.gridAddress == i {
                    tempArray.append(tile)
                    break
                }
            }
        }
        tiles = tempArray
        
        print("Tiles updated\n")
    }
    
    private func getGridAddress(location: simd_float2) -> Int {
        let row = Int(location.y * Float(gridSize))
        let col = Int(location.x * Float(gridSize))
        return row * gridSize + col
    }
    
    private func getLocationFromGridAddress(_ address: Int) -> simd_float2 {
        var outLocation = simd_float2(x: -1, y: 1)
        outLocation.x += tileSize * Float(address % gridSize)
        outLocation.y -= tileSize * Float(address / gridSize)
        return outLocation
    }
    
    private func isSolved() -> Bool {
        
        for tile in tiles {
            if tile.isActive && tile.gridAddress != tile.correctAddress { return false }
        }
        return true
    }
    
    func reset() {
        print("Reset puzzle\n")
        moves = 0
    }
}
