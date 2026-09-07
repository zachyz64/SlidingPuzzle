//
//  ContentView.swift
//  SlidingPuzzle
//
//  Created by Zach Zaborowski on 8/22/26.
//

import SwiftUI

struct GameView: View {
    
    let dimension: CGFloat = 600
    
    @EnvironmentObject var grid: Grid
    
    var body: some View {
        VStack {
            
            Text("Sliding Puzzle")
                .font(.title)
                .bold()
                .italic()
            PuzzleView()
                .frame(width: dimension, height: dimension)
                .onTapGesture(coordinateSpace: .local) { location in
                    grid.onTileWasSelected(location: location, dimension: dimension)
                }
            HStack {
                
                Button(action: { grid.showTiles.toggle() }) {
                    Text(grid.showTiles ? "Hide Tiles" : "Show Tiles")
                        .font(.headline)
                        .frame(width: 90, height: 25, alignment: .center)
                }.buttonStyle(.borderedProminent)
                
                Button(action: { grid.reset() }) {
                    Text("Reset")
                        .font(.headline)
                        .frame(width: 50, height: 25, alignment: .center)
                        .foregroundColor(.white)
                        .background(.blue)
                }.buttonStyle(.borderedProminent)
            }
            .padding()
            
            HStack {
                Text("Moves: \(grid.moves)")
            }
        }
    }
}

#Preview {
    GameView()
}
