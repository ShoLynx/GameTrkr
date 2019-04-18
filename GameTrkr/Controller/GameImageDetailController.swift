//
//  GameImageDetailController.swift
//  GameTrkr
//
//  Created by Sean Foreman on 3/31/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import Foundation
import UIKit

class GameImageDetailController: UIViewController {
    
    // MARK: Class setup
    
    @IBOutlet weak var fullscreenImage: UIImageView!
    
    var selectedImage: UIImage!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fullscreenImage.image = selectedImage
    }
}
