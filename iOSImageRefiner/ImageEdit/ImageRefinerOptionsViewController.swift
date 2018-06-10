//
//  ImageRefinerOptionsViewController.swift
//  iOSImageRefiner
//
//  Created by Allen Snow on 6/5/18.
//  Copyright © 2018 Waggle Bum. All rights reserved.
//

import UIKit
import Foundation

public class ImageRefinerOptionsViewController: UITableViewController {

    public var options: ImageRefinerOptions = ImageRefinerOptions()
    
    @IBAction func CancelButtonClick(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func DoneButtonClick(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let refiner = segue.destination as? ImageRefinerViewController {
            refiner.imageOptions = self.options
        }
    }
}
