//
//  ContentView.swift
//  SlidingPuzzle
//
//  Created by Zach Zaborowski on 8/22/26.
//

import SwiftUI

struct GameView: View {
    var body: some View {
        VStack {
            /*
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
             */
            Text("Sliding Puzzle")
                .bold()
                .italic()
            PuzzleView()
                .frame(width: 600, height: 600)
            HStack {
                Button {
                    print("Hide Tiles")
                } label: {
                    Text("Hide Tiles")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .background(.blue)
                        .clipShape(Capsule())
                }.buttonStyle(.borderedProminent)
                Button {
                    print("Reset")
                } label: {
                    Text("Reset")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .background(.blue)
                        .clipShape(Capsule())
                }.buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

#Preview {
    GameView()
}
