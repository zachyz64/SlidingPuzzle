//
//  GameScene.swift
//  SlidingPuzzle
//
//  Created by Zach Zaborowski on 8/25/26.
//

import Foundation
internal import Combine

class GameScene: ObservableObject {
    
    init() {
        
    }
    
    func update() {
        
    }
    
    func updateView() {
        self.objectWillChange.send()
    }
    
}
