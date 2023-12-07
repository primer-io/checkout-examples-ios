//
//  LaunchScreenViewController.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 02/11/2023.
//

import Foundation
import UIKit

class LaunchScreenViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        self.imageView.image = UIImage(named: "primer-icon")
    }
}
