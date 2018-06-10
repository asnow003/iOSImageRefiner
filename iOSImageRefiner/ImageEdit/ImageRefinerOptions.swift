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
    public var thumbWidthHeight: CGFloat?
    public var thumbQuality: ImageRefinerQuality?
    
    init(
        cropWidth: CGFloat? = nil,
        cropHeight: CGFloat? = nil,
        quality: ImageRefinerQuality? = nil,
        thumbWidthHeight: CGFloat? = nil,
        thumbQuality: ImageRefinerQuality? = nil
        ) {
        self.cropHeight = cropHeight
        self.cropWidth = cropWidth
        self.quality = quality
        self.thumbWidthHeight = thumbWidthHeight
        self.thumbQuality = thumbQuality
    }
}
