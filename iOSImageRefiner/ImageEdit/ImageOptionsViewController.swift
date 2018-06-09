//
//  ImageEditOptions.swift
//  iOSImageRefiner
//
//  Created by Allen Snow on 6/5/18.
//  Copyright © 2018 Waggle Bum. All rights reserved.
//

import UIKit
import Foundation

public class ImageOptionsViewController: UITableViewController {

    
    @IBAction func CancelButtonClick(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func DoneButtonClick(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
