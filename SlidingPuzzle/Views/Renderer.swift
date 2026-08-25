//
//  Renderer.swift
//  SlidingPuzzle
//
//  Created by Zach Zaborowski on 8/25/26.
//

import Foundation
import MetalKit

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
    
    init (_ parent: PuzzleView) {
        self.parent = parent
        
        if let mtkDevice = MTLCreateSystemDefaultDevice() {
            self.device = mtkDevice
        }
        
        self.commandQueue = device.makeCommandQueue()
        self.materialLoader = MTKTextureLoader(device: device)
        self.meshAllocator = MTKMeshBufferAllocator(device: device)
        
        let vertexDescriptor = MTLVertexDescriptor()
        var offset: Int = 0
        // Position
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = offset
        vertexDescriptor.attributes[0].bufferIndex = 0
        offset += MemoryLayout<simd_float3>.stride
        // Texture Coordinate
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].offset = offset
        vertexDescriptor.attributes[1].bufferIndex = 0
        offset += MemoryLayout<simd_float2>.stride
        
        vertexDescriptor.layouts[0].stride = offset
        
        self.puzzle = Grid(device: device, filename: "Exusiai", filenameExtension: "jpg")
        
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
        renderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.5, 0.5, 1.0)
        renderPassDescriptor?.colorAttachments[0].loadAction = .clear
        renderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
        
        drawTiles(renderEncoder: renderEncoder)
        
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    func drawTiles(renderEncoder: MTLRenderCommandEncoder?) {
        
        renderEncoder?.setRenderPipelineState(pipeline)
        
        renderEncoder?.setFragmentSamplerState(sampler, index: 0)
        renderEncoder?.setFragmentTexture(puzzle.texture, index: 0)
        renderEncoder?.setCullMode(.none)
    }
}
