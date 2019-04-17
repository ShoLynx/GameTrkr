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
    @IBOutlet weak var closeButton: UIButton!
    
    var selectedImage: UIImage!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeButton.layer.cornerRadius = 10.0
        closeButton.layer.masksToBounds = true
        
        fullscreenImage.image = selectedImage
    }
    
    // MARK: Exit function
    
    @IBAction func exitDetail (_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
