//
//  ImageRefinerOptionsViewController.swift
//  iOSImageRefiner
//
//  Created by Allen Snow on 6/5/18.
//  Copyright © 2018 Waggle Bum. All rights reserved.
//

import UIKit
import Foundation

public protocol ImageRefinerOptionsDelegate: class {
    func optionsUpdated(options: ImageRefinerOptions)
}

public class ImageRefinerOptionsViewController: UITableViewController {
    
    @IBOutlet weak var heightOptionTextbox: UITextField!
    @IBOutlet weak var widthOptionTextbox: UITextField!
    @IBOutlet weak var qualityOptionChoice: UISegmentedControl!
    
    public var options: ImageRefinerOptions = ImageRefinerOptions()
    public var delegate: ImageRefinerOptionsDelegate?
    
    public override func viewDidLoad() {
        self.heightOptionTextbox.text = String(describing: options.cropHeight)
        self.widthOptionTextbox.text = String(describing: options.cropWidth)
        
        self.qualityOptionChoice.selectedSegmentIndex = options.quality.rawValue - 1
    }
    
    private func stringToDimension(value: String?) -> CGFloat? {
        if let _value = value,
            let n = NumberFormatter().number(from: _value) {
            return CGFloat(truncating: n)
        }
        
        return nil
    }
    
    @IBAction func CancelButtonClick(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func DoneButtonClick(_ sender: Any) {
        
        if let _delegate = self.delegate {
            var optionsChanged = false

            // check width option
            if let _width = self.stringToDimension(value: self.widthOptionTextbox.text) {
                if _width != self.options.cropWidth &&
                    _width <= self.options.maxCropWidth {
                    self.options.cropWidth = _width
                    optionsChanged = true
                }
            }
            
            // check height option
            if let _height = self.stringToDimension(value: self.heightOptionTextbox.text) {
                if _height != self.options.cropHeight &&
                    _height <= self.options.maxCropHeight {
                    self.options.cropHeight = _height
                    optionsChanged = true
                }
            }
            
            // check image quality
            if qualityOptionChoice.selectedSegmentIndex + 1 != options.quality.rawValue {
                self.options.quality = ImageRefinerQuality(rawValue: qualityOptionChoice.selectedSegmentIndex + 1)!
                optionsChanged = true
            }
            
            if optionsChanged {
                _delegate.optionsUpdated(options: self.options)
            }
        }
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let refiner = segue.destination as? ImageRefinerViewController {
            refiner.options = self.options
        }
    }
}
