//
//  ImageRefinerViewController.swift
//  iOSImageRefiner
//
//  Created by Allen Snow on 10/12/16.
//  Copyright © 2016 Waggle Bum. All rights reserved.
//

import UIKit
import ImageIO

public enum ImageRefinerQuality: Int {
    case standard = 1
    case high = 2
    case retina = 3
}

public protocol ImageRefinerDelegate: class {
    func imageUpdated(image: UIImage, thumbnail: UIImage?, scaleFactor: Int)
}

public class ImageRefinerViewController: UIViewController, UIScrollViewDelegate, ImageRefinerOptionsDelegate, UIGestureRecognizerDelegate {
    
    public static let storyboardName: String = "ImageRefiner"
    
    public weak var delegate: ImageRefinerDelegate?
    
    public var image: UIImage?
    public var imageOptions: ImageRefinerOptions? {
        didSet {
            self.imageCropHeight = imageOptions?.cropHeight ?? self.imageCropHeight
            self.imageCropWidth = imageOptions?.cropWidth ?? self.imageCropWidth
            self.imageScaleFactor = imageOptions?.quality ?? self.imageScaleFactor
            self.thumbWidthHeight = imageOptions?.thumbWidthHeight ?? self.thumbWidthHeight
            self.thumbQuality = imageOptions?.thumbQuality ?? self.thumbQuality
        }
    }
    
    public var buttonColor: UIColor = UIColor.white
    public var showThumbnailPreview: Bool = true
    public var showEditOptionsButton: Bool = true
    
    private var imageCropWidth: CGFloat = 200
    private var imageCropHeight: CGFloat = 200
    private var imageScaleFactor: ImageRefinerQuality = ImageRefinerQuality.standard
    
    private var thumbWidthHeight: CGFloat = 75
    private var thumbQuality: ImageRefinerQuality = ImageRefinerQuality.standard
    
    private var imageCropScale: CGFloat = 1
    private var scaledImageCropWidth: CGFloat = 0
    private var scaledImageCropHeight: CGFloat = 0
    
    private var generateThumbnailTimer: Timer = Timer()
    
    private var imageWidth: CGFloat = 0
    private var imageHeight: CGFloat = 0
    private var imageScale: CGFloat = 1
    private var imageCropX: CGFloat = 0
    private var imageCropY: CGFloat = 0
    private var imageCropFocusX: CGFloat = 0
    private var imageCropFocusY: CGFloat = 0
    
    private var imageLoaded: Bool = false
    private var imageView = UIImageView()
    
    @IBOutlet weak var thumbnailContainerView: UIView!
    @IBOutlet weak var thumbnailView: UIImageView!
    
    @IBOutlet weak var imagePinchZoomScroll: UIScrollView!
    @IBOutlet weak var imageOverlay: ViewWithCutout!
    
    @IBOutlet weak var buttonBar: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var imageInfoLabel: UILabel!

    @IBOutlet weak var editOptionsButton: UIButton!
    
    public override func viewWillAppear(_ animated: Bool) {
        self.imageInfoLabel.alpha = 0
        self.thumbnailView.alpha = 0
    }
    
    public override func viewDidLoad() {
        
        if #available(iOS 11.0, *) {
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        self.editOptionsButton.isHidden = !self.showEditOptionsButton
        
        super.viewDidLoad()
        
        self.imagePinchZoomScroll.minimumZoomScale = -6.0;
        self.imagePinchZoomScroll.maximumZoomScale = 6.0;
        
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        self.okButton.imageView!.tintColor = self.buttonColor
        self.cancelButton.imageView!.tintColor = self.buttonColor
        self.editOptionsButton.imageView!.tintColor = self.buttonColor
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.imagePinchZoomScroll.addGestureRecognizer(tap)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        if let _image = self.image {
            if !self.imageLoaded {
                self.loadImage(image: _image)
                self.imageLoaded = true
            } else {
                self.setThumbnail()
            }
        }
    }
    
    @IBAction func okButtonClick(_ sender: AnyObject) {
        if let _image = self.getEditedImage() {
            if let _delegate = self.delegate {
                self.generateThumbnail()
                _delegate.imageUpdated(image: _image, thumbnail: self.thumbnailView.image, scaleFactor: self.imageScaleFactor.rawValue)
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonClick(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func optionsUpdated(options: ImageRefinerOptions) {
        self.imageOptions = options
        if let _image = self.image {
            self.loadImage(image: _image)
        }
    }
    
    func compress(_ image: UIImage) -> UIImage {
        let imageData:Data = UIImageJPEGRepresentation(image, 0.75)!
        
        return UIImage(data: imageData)!
    }
    
    private func adjustedImageCropWidth() -> CGFloat {
        return self.imageCropWidth * CGFloat(imageScaleFactor.rawValue)
    }
    
    private func adjustedImageCropHeight() -> CGFloat {
        return self.imageCropHeight * CGFloat(imageScaleFactor.rawValue)
    }
    
    public func scaleImage(image: UIImage, scaleFactor: CGFloat) -> UIImage? {
        let size = image.size
        
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

    private func getEditedImage() -> UIImage? {
        
        let offsetX: CGFloat = self.imagePinchZoomScroll.contentOffset.x
        let offsetY: CGFloat = self.imagePinchZoomScroll.contentOffset.y
        
        var cropX = self.imageCropX + offsetX
        if cropX < 0 {
            cropX = 0
        }
        
        var cropY = self.imageCropY + offsetY
        if cropY < 0 {
            cropY = 0
        }
        
        var cropWidth = self.scaledImageCropWidth
        var cropHeight = self.scaledImageCropHeight
        
        var imageScale = self.imagePinchZoomScroll.zoomScale
        
        // if the crop area has been scaled
        if self.scaledImageCropWidth != self.adjustedImageCropWidth() ||
            self.scaledImageCropHeight != self.adjustedImageCropHeight() {
            
            let scaleAdjustment =  self.adjustedImageCropWidth() / self.scaledImageCropWidth
            
            cropWidth = cropWidth * scaleAdjustment
            cropHeight = cropHeight * scaleAdjustment
            
            cropX = cropX * scaleAdjustment
            cropY = cropY * scaleAdjustment
            
            imageScale = scaleAdjustment * imageScale
        }
        
        if let _image = self.image {
            
            if let _scaledImage = scaleImage(image: _image, scaleFactor: imageScale) {
                let crop = CGRect(x: cropX,
                                  y: cropY,
                                  width: cropWidth,
                                  height: cropHeight)
                
                
                if let _croppedCGImage = _scaledImage.cgImage?.cropping(to: crop) {
                    let croppedImage = UIImage(cgImage: _croppedCGImage)
                    
                    return croppedImage
                }
            }
        }
        
        return nil
    }
    
    private func getCropScale() -> CGFloat {
        let editorWidth = self.imageOverlay.frame.size.width - 50
        let editorHeight = self.imageOverlay.frame.size.height - 50
        
        let cropWidth = self.adjustedImageCropWidth()
        let cropHeight = self.adjustedImageCropHeight()
        
        // if the crop area is bigger than the screen
        if cropWidth > editorWidth ||
            cropHeight > editorHeight {
            let widthScale = editorWidth / cropWidth
            let heightScale = editorHeight / cropHeight
            
            return min(widthScale, heightScale)
        }
        
        return 1
    }
    
    private func loadImage(image: UIImage) {
        
        self.imageView.removeFromSuperview()
        self.imageView = UIImageView()
        
        self.imageView.alpha = 0
        self.thumbnailView.alpha = 0
        self.thumbnailContainerView.layer.borderColor = UIColor.gray.cgColor
        self.thumbnailContainerView.layer.borderWidth = 1
        
        self.imageCropScale = self.getCropScale()
        self.scaledImageCropWidth = self.adjustedImageCropWidth() * self.imageCropScale
        self.scaledImageCropHeight = self.adjustedImageCropHeight() * self.imageCropScale

        self.imageWidth = image.size.width
        self.imageHeight = image.size.height
        
        self.imageView.frame = CGRect(x: 0, y: 0, width: self.imageWidth, height: self.imageHeight)
        
        // place the crop cutout on the stage
        // scale it down if needed to fix
        self.imageCropX = (self.imageOverlay.frame.size.width - scaledImageCropWidth) / 2
        self.imageCropY = (self.imageOverlay.frame.size.height - scaledImageCropHeight) / 2
        self.imageOverlay.transparentHoleView = UIView(
            frame: CGRect(x: self.imageCropX,
                          y: self.imageCropY,
                          width: scaledImageCropWidth,
                          height: scaledImageCropHeight))
        
        self.imageOverlay.setNeedsDisplay()
        
        // set the correct scale of the viewport to fit the whole image the best
        let widthScale = scaledImageCropWidth / self.imageWidth
        let heightScale = scaledImageCropHeight / self.imageHeight
        
        // set the crop focus point to the center of the crop area
        let cropCenterX: CGFloat = self.imageCropX + (scaledImageCropWidth / 2)
        let cropCenterY: CGFloat = self.imageCropY + (scaledImageCropHeight / 2)
        self.setCropFocus(x: cropCenterX, y: cropCenterY)
        
        self.imageScale = max(widthScale, heightScale)
  
        self.imagePinchZoomScroll.setZoomScale(self.imageScale, animated: false)

        if (self.imageScale == 1) {
            self.centerContent(scrollView: self.imagePinchZoomScroll)
        }
        
        self.imageView.image = image
        
        self.imagePinchZoomScroll.addSubview(self.imageView)
        
        // center the scaled image
        let centerX: CGFloat = (self.imagePinchZoomScroll.bounds.width - self.imageView.frame.size.width) / 2
        let centerY: CGFloat = (self.imagePinchZoomScroll.bounds.height - self.imageView.frame.size.height) / 2
        
        self.imagePinchZoomScroll.contentOffset = CGPoint(x: centerX * -1, y: centerY * -1)
        
        self.setThumbnail()
        
        // set the min scale so it doesn't go smaller than the crop area
        self.imagePinchZoomScroll.minimumZoomScale = self.imageScale
        UIView.animate(withDuration: 0.2) {
            self.imageView.alpha = 1
        }
    }

    @objc public func handleTap(_ touch: UITapGestureRecognizer) {
        if touch.state == UIGestureRecognizerState.recognized
        {
            print(touch.location(in: touch.view))
        }
    }
    
    private func setCropFocus(x: CGFloat, y: CGFloat) {
        self.imageCropFocusX = x
        self.imageCropFocusY = y
    }
    
    private func setThumbnail() {
        if self.showThumbnailPreview {
            self.thumbnailView.image = nil
            self.thumbnailView.alpha = 0
            self.generateThumbnailTimer.invalidate()
            self.generateThumbnailTimer = Timer.scheduledTimer(timeInterval: 0.2,
                                                               target: self,
                                                               selector: #selector(ImageRefinerViewController.generateThumbnail),
                                                               userInfo: nil,
                                                               repeats: false)
        }
    }
    
    private func getImageDetails(image: UIImage, width: Int, height: Int) -> String? {
        if let _imageData = UIImagePNGRepresentation(image) {
            
            let imageSize = Int64(_imageData.count)
            
            let size = ByteCountFormatter.string(fromByteCount: imageSize, countStyle: ByteCountFormatter.CountStyle.file)
            
            return "w\(width) x h\(height), \(size)"
        }
        
        return nil
    }
    
    private func resizeImage(_ image: UIImage, targetSize: CGSize, compression: CGFloat = 100, origin: CGPoint? = nil, useDeviceScaleFactor: Bool = false) -> UIImage {
        
        let sourceImage:UIImage = image
        var newImage:UIImage? = nil
        let imageSize:CGSize = sourceImage.size
        let width = imageSize.width
        let height = imageSize.height
        let targetWidth = targetSize.width
        let targetHeight = targetSize.height
        var scaleFactor:CGFloat = 0.00
        var scaledWidth = targetWidth
        var scaledHeight = targetHeight
        var thumbnailPoint:CGPoint = origin == nil ? CGPoint(x: 0.0, y: 0.0) : origin!
        
        if (imageSize.equalTo(targetSize) == false)
        {
            let widthFactor = targetWidth / width;
            let heightFactor = targetHeight / height;
            
            if (widthFactor > heightFactor)
            {
                scaleFactor = widthFactor; // scale to fit height
            } else {
                scaleFactor = heightFactor; // scale to fit width
            }
            
            scaledWidth  = width * scaleFactor;
            scaledHeight = height * scaleFactor;
            
            // center the image
            if (widthFactor > heightFactor)
            {
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            } else {
                if (widthFactor < heightFactor)
                {
                    thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
                }
            }
        }
        
        let deviceScaleFactor:CGFloat = UIScreen.main.scale
        let imageScaleFactor: CGFloat = useDeviceScaleFactor ? deviceScaleFactor : 1
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, imageScaleFactor)
        
        var thumbnailRect = CGRect.zero;
        thumbnailRect.origin = thumbnailPoint
        thumbnailRect.size.width  = scaledWidth
        thumbnailRect.size.height = scaledHeight
        
        sourceImage.draw(in: thumbnailRect)
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        let imageData = UIImageJPEGRepresentation(newImage!, compression);
        
        UIGraphicsEndImageContext();
        
        return UIImage(data: imageData!)!
    }
    
    @objc public func generateThumbnail() {
        if let _image = self.getEditedImage() {
            
            self.imageInfoLabel.alpha = 0
            self.imageInfoLabel.text = getImageDetails(
                image: _image,
                width: Int(self.imageCropWidth),
                height: Int(self.imageCropHeight)
            )
            
            // make sure its the center of the cutout
            var xOffset: CGFloat = 0
            var yOffset: CGFloat = 0
            
            if (self.imageCropWidth != self.imageCropHeight) {
                let newOffset = abs(self.imageCropWidth - self.imageCropHeight) / 2
                xOffset = self.imageCropWidth > self.imageCropHeight ? newOffset : 0
                yOffset = self.imageCropWidth < self.imageCropHeight ? newOffset : 0
            }
            
            let point = CGPoint(x: xOffset,
                                y: yOffset)
            
            let scaledThumbWidthHeight = self.thumbWidthHeight * CGFloat(self.thumbQuality.rawValue)
            
            let thumbnail = resizeImage(
                _image,
                targetSize: CGSize(width: scaledThumbWidthHeight, height: scaledThumbWidthHeight),
                compression: 1,
                origin: point,
                useDeviceScaleFactor: false)
            
            self.thumbnailView.image = thumbnail
            
            UIView.animate(withDuration: 0.2) {
                self.imageInfoLabel.alpha = 1
                self.thumbnailView.alpha = 1
            }
        }
    }
    
    private func centerContent(scrollView: UIScrollView) {
        let left = (scrollView.bounds.size.width - self.scaledImageCropWidth) * 0.5
        let top = (scrollView.bounds.size.height - self.scaledImageCropHeight) * 0.5;

        scrollView.contentInset = UIEdgeInsetsMake(top, left, top, left);
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerContent(scrollView: scrollView)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.setThumbnail()
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _nav = segue.destination as? UINavigationController,
            let _editor = _nav.topViewController as? ImageRefinerOptionsViewController,
            let _options = self.imageOptions {
            _editor.delegate = self
            _editor.options = _options
        }
    }
}

public class ViewWithCutout: UIView {
    
    public var transparentHoleView: UIView? = nil
    
    private var outlineBorder = UIView()
    private var thumbnailBorder = UIView()
    
    // MARK: - Drawing
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        outlineBorder.removeFromSuperview()
        thumbnailBorder.removeFromSuperview()
        
        if let _hole = self.transparentHoleView {
            // Ensures to use the current background color to set the filling color
            self.backgroundColor?.setFill()
            UIRectFill(rect)
            
            let layer = CAShapeLayer()
            let path = CGMutablePath()
            
            path.addRect(_hole.frame)
            path.addRect(bounds)
            
            layer.path = path
            layer.fillRule = kCAFillRuleEvenOdd
            
            self.layer.mask = layer
            
            // the the outlined border
            outlineBorder = UIView()
            outlineBorder.backgroundColor = UIColor.clear
            outlineBorder.layer.borderWidth = 1
            outlineBorder.layer.borderColor = UIColor.gray.cgColor
            outlineBorder.frame = CGRect(x: _hole.frame.origin.x - 1, y: _hole.frame.origin.y - 1, width: _hole.frame.size.width + 2, height: _hole.frame.size.height + 2)
            
            self.addSubview(outlineBorder)
        }
    }
    
    override public func layoutSubviews () {
        super.layoutSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

