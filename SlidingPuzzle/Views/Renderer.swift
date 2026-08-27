//
//  Renderer.swift
//  SlidingPuzzle
//
//  Created by Zach Zaborowski on 8/25/26.
//

import Foundation
import MetalKit

struct Vertex {
    let position: simd_float3
    let texCoord: simd_float2
}

class Renderer: NSObject, MTKViewDelegate{
    var parent: PuzzleView
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    
    let materialLoader: MTKTextureLoader
    let meshAllocator: MTKMeshBufferAllocator
    
    var pipeline: MTLRenderPipelineState
    
    let depthStencilState: MTLDepthStencilState
    
    let sampler: MTLSamplerState

    let puzzle: Grid
    
    init (_ parent: PuzzleView, _ grid: Grid) {
        self.parent = parent
        
        if let mtkDevice = MTLCreateSystemDefaultDevice() {
            self.device = mtkDevice
        }
        
        self.commandQueue = device.makeCommandQueue()
        self.materialLoader = MTKTextureLoader(device: device)
        self.meshAllocator = MTKMeshBufferAllocator(device: device)
        
        let bufferIndex = 0
        let vertexDescriptor = MTLVertexDescriptor()
        // Position 2D
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = bufferIndex
        // Texture Coordinate
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].offset = MemoryLayout.offset(of: \Vertex.texCoord)!
        vertexDescriptor.attributes[1].bufferIndex = bufferIndex
        
        vertexDescriptor.layouts[bufferIndex].stride = MemoryLayout<Vertex>.stride
        
        self.puzzle = grid
        self.puzzle.update(device: device, filename: "Exusiai", filenameExtension: "jpg")
        
        let library = device.makeDefaultLibrary()!
        
        pipeline = PipelineBuilder.BuildPipeline(device: device,
                                                 library: library,
                                                 vs: "vertexShader",
                                                 fs: "fragmentShader",
                                                 vertexDescriptor: vertexDescriptor,
                                                 depthEnabled: true)
        
        // Set up depthStencilDescriptor
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        self.depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
        
        // Set up sampler
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.minFilter = .nearest
        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.maxAnisotropy = 8
        self.sampler = device.makeSamplerState(descriptor: samplerDescriptor)!
        
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        let renderPassDescriptor = view.currentRenderPassDescriptor
        renderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColorMake(0.8, 0.4, 0.1, 1.0)
        renderPassDescriptor?.colorAttachments[0].loadAction = .clear
        renderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
        
        renderEncoder?.setRenderPipelineState(pipeline)
        renderEncoder?.setCullMode(.none)
        renderEncoder?.setFragmentSamplerState(sampler, index: 0)
        renderEncoder?.setFragmentTexture(puzzle.texture, index: 0)
        
        drawBackground(renderEncoder: renderEncoder)
        if puzzle.showTiles {
            drawTiles(renderEncoder: renderEncoder)
        }
        
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    func drawBackground(renderEncoder: MTLRenderCommandEncoder?) {
        
        let vertices: [Vertex] = [
            Vertex(position: [-1.0, -1.0, 0.5], texCoord: [0.0, 1.0]), // Bottom Left
            Vertex(position: [ 1.0, -1.0, 0.5], texCoord: [1.0, 1.0]), // Bottom Right
            Vertex(position: [ 1.0,  1.0, 0.5], texCoord: [1.0, 0.0]), // Top Right
            Vertex(position: [ 1.0,  1.0, 0.5], texCoord: [1.0, 0.0]), // Top Right
            Vertex(position: [-1.0,  1.0, 0.5], texCoord: [0.0, 0.0]), // Top Left
            Vertex(position: [-1.0, -1.0, 0.5], texCoord: [0.0, 1.0])  // Bottom Left
        ]
        let vertexBuffer = device.makeBuffer(bytes: vertices,
                                             length: vertices.count * MemoryLayout<Vertex>.stride)
        renderEncoder?.setVertexBuffer(vertexBuffer,
                                       offset: 0,
                                       index: 0)
        
        var tint: simd_float3 = simd_float3(repeating: 0.25)
        renderEncoder?.setFragmentBytes(&tint,
                                        length: MemoryLayout<simd_float3>.stride,
                                        index: 0)
        
        renderEncoder?.drawPrimitives(type: .triangle,
                                      vertexStart: 0,
                                      vertexCount: vertices.count)
    }
    
    func drawTiles(renderEncoder: MTLRenderCommandEncoder?) {
        
        var tint: simd_float3 = simd_float3(repeating: 1.0)
        renderEncoder?.setFragmentBytes(&tint,
                                        length: MemoryLayout<simd_float3>.stride,
                                        index: 0)
        
        for tile in puzzle.tiles {
            if tile.isActive == false {
                continue
            }
            
            let offset = simd_float2(0.0, 0.0)
            let vertices: [Vertex] = [
                Vertex(position: simd_float3(tile.screenQuad.data[0], 0), // Bottom Left
                       texCoord: tile.textureQuad.data[0] + offset),
                Vertex(position: simd_float3(tile.screenQuad.data[1], 0), // Bottom Right
                       texCoord: tile.textureQuad.data[1] + offset),
                Vertex(position: simd_float3(tile.screenQuad.data[2], 0), // Top Right
                       texCoord: tile.textureQuad.data[2] + offset),
                Vertex(position: simd_float3(tile.screenQuad.data[3], 0), // Top Right
                       texCoord: tile.textureQuad.data[3] + offset),
                Vertex(position: simd_float3(tile.screenQuad.data[4], 0), // Top Left
                       texCoord: tile.textureQuad.data[4] + offset),
                Vertex(position: simd_float3(tile.screenQuad.data[5], 0), // Bottom Left
                       texCoord: tile.textureQuad.data[5] + offset)
            ]
            
            let vertexBuffer = device.makeBuffer(bytes: vertices,
                                                 length: vertices.count * MemoryLayout<Vertex>.stride)
            renderEncoder?.setVertexBuffer(vertexBuffer,
                                           offset: 0,
                                           index: 0)
            
            renderEncoder?.drawPrimitives(type: .triangle,
                                          vertexStart: 0,
                                          vertexCount: 6)
            
        }
    }
}
