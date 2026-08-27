//
//  PuzzleView.swift
//  SlidingPuzzle
//
//  Created by Zach Zaborowski on 8/25/26.
//

import SwiftUI
import MetalKit

struct PuzzleView : UIViewRepresentable {
    
    @EnvironmentObject var grid: Grid
    
    func makeCoordinator() -> Renderer {
        Renderer(self, grid)
    }
    
    func makeUIView(context: UIViewRepresentableContext<PuzzleView>) ->  MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = true
        
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
        mtkView.framebufferOnly = false
        mtkView.drawableSize = mtkView.frame.size
        mtkView.isPaused = false
        mtkView.depthStencilPixelFormat = .depth32Float
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
    }
    
}

#Preview {
    PuzzleView()
}
