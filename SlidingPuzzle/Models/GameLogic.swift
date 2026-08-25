//
//  GameLogic.swift
//  SlidingPuzzle
//
//  Created by Zach Zaborowski on 8/25/26.
//

import Foundation
import SwiftUI
internal import Combine

final class GameLogic: ObservableObject {
    var objectWillChange: PassthroughSubject<GameLogic, Never>()
    
    
    enum Direction {
        case left
        case right
        case up
        case down
    }
    
    init() {
        newGame()
    }
    
    func newGame() {
        objectWillChange.send(self)
    }
}
