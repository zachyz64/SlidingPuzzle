//
//  ImageList.swift
//  SlidingPuzzle
//
//  Created by Zach Zaborowski on 10/21/26.
//

import Foundation
import SwiftUI
import MetalKit

internal import Combine

class ImageList: ObservableObject
{
    let images: Dictionary<String, String>
    var imagesFromPhotos: Dictionary<String, String>
    
    init()
    {
        self.images = ["TeaGardenMist": "jpg"]
        self.imagesFromPhotos = [:]
    }
}
