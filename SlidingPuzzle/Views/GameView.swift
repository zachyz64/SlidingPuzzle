//
//  ContentView.swift
//  SlidingPuzzle
//
//  Created by Zach Zaborowski on 8/22/26.
//

import SwiftUI
import PhotosUI

struct GameView: View {
    
    let dimension: CGFloat = 600
    
    @State var pickerItem: PhotosPickerItem!
    @State var selectedImage: Image?
    
    @EnvironmentObject var grid: Grid
    @EnvironmentObject var imageList: ImageList
    
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
                
                Button(action: { grid.reshuffleTiles() }) {
                    Text("Reshuffle")
                        .font(.headline)
                        .frame(width: 80, height: 25, alignment: .center)
                        .foregroundColor(.white)
                        .background(.blue)
                }.buttonStyle(.borderedProminent)
            }
            .padding()
            
            HStack {
                Text("Moves: \(grid.moves)")
            }

            PhotosPicker(selection: $pickerItem, matching: .images) {
                Label("Select Image", systemImage: "photo.fill")
            }.buttonStyle(.borderedProminent)
            
            Menu("Change Image") {
                Button(action: openList) {
                    Label("From List", systemImage: "list.dash")
                }
                Button(action: openPhotos) {
                    
                    Label("From Photos", systemImage: "photo")
                }
            }.buttonStyle(.borderedProminent)
            
            /*
            NavigationStack {
                List(Array(imageList.images.keys), id: \.self) { image in
                    NavigationLink(destination: MenuView(imageName: image)) {
                        Text(image)
                    }
                }
            }
             */
        }
        .onChange(of: pickerItem) {
            Task {
                if let loaded = try? await pickerItem?.loadTransferable(type: Image.self) {
                    selectedImage = loaded
                    let puzzleImage = ImageRenderer(content: loaded).cgImage
                    
                    grid.updateTexture(device: grid.device, image: puzzleImage!)
                    grid.reset()
                }
                else {
                    print("Failed to load image")
                }
            }
        }
    }
    
    func openList() { print("Open List") }
    func openPhotos() { print("Open Photos") }
}

#Preview {
    GameView()
}
