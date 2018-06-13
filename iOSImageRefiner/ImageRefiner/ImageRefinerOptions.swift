//
//  ImageRefinerOptions.swift
//  iOSImageRefiner
//
//  Created by Allen Snow on 6/9/18.
//  Copyright © 2018 Waggle Bum. All rights reserved.
//

import UIKit
import Foundation

/// Optional values to configure the imaged editing experience
public class ImageRefinerOptions {
    public var cropWidth: CGFloat
    public var cropHeight: CGFloat
    public var quality: ImageRefinerQuality
    public var maxCropWidth: CGFloat
    public var maxCropHeight: CGFloat
    public var thumbWidthHeight: CGFloat
    public var thumbQuality: ImageRefinerQuality
    
    init(
        cropWidth: CGFloat = 200,
        cropHeight: CGFloat = 200,
        quality: ImageRefinerQuality = ImageRefinerQuality.standard,
        maxCropWidth: CGFloat = 1000,
        maxCropHeight: CGFloat = 1000,
        thumbWidthHeight: CGFloat = 75,
        thumbQuality: ImageRefinerQuality = ImageRefinerQuality.standard
        ) {
        self.cropHeight = cropHeight
        self.cropWidth = cropWidth
        self.quality = quality
        self.maxCropWidth = maxCropWidth
        self.maxCropHeight = maxCropHeight
        self.thumbWidthHeight = thumbWidthHeight
        self.thumbQuality = thumbQuality
    }
}
