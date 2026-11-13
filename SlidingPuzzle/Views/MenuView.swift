//
//  MenuView.swift
//  SlidingPuzzle
//
//  Created by Zach Zaborowski on 10/29/26.
//

import SwiftUI

struct MenuView: View {
    
    let imageName: String
    
    init(imageName: String) {
        self.imageName = imageName
    }
    
    var body: some View {
        Text(imageName)
    }
}
