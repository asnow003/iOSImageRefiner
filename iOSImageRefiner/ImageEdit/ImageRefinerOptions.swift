//
//  ImageRefinerOptions.swift
//  iOSImageRefiner
//
//  Created by Allen Snow on 6/9/18.
//  Copyright © 2018 Waggle Bum. All rights reserved.
//

import UIKit
import Foundation

public class ImageRefinerOptions {
    public var cropWidth: CGFloat?
    public var cropHeight: CGFloat?
    public var quality: ImageRefinerQuality?
    
    init(
        cropWidth: CGFloat? = nil,
        cropHeight: CGFloat? = nil,
        quality: ImageRefinerQuality? = nil
        ) {
        self.cropHeight = cropHeight
        self.cropWidth = cropWidth
        self.quality = quality
    }
}
