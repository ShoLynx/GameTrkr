//
//  GameDetailsController.swift
//  GameTrkr
//
//  Created by Sean Foreman on 3/30/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import Foundation
import UIKit

class GameDetailsController: UIViewController {
    
    @IBOutlet weak var youtubePlayerView: UIView!
    @IBOutlet weak var watchAnotherVideoButton: UIBarButtonItem!
    @IBOutlet weak var digitalRadio: UIImageView!
    @IBOutlet weak var hasBoxRadio: UIImageView!
    @IBOutlet weak var specialEditionRadio: UIImageView!
    @IBOutlet weak var gameImageCollection: UICollectionView!
    @IBOutlet weak var emptyImageCollectionLabel: UILabel!
    @IBOutlet weak var addNewPhotoButton: UIBarButtonItem!
    @IBOutlet weak var deletePhotoButton: UIBarButtonItem!
    @IBOutlet weak var gameDescription: UITextView!
    
    var youtubeURL: String!
    var isDigital: Bool!
    var hasBox: Bool!
    var isSpecialEdition: Bool!
    var gameImages: [UIImage] = []
    var hasDescription: Bool!
    var game: Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = game.name
        
        //need default youtubeURL to be search with Platform and Game
        
        digitalRadio.image = UIImage(named: "RadioDigitalOff")
        if game.isDigital {
            digitalRadio.image = UIImage(named: "RadioDigitalOn")
        }
        
        hasBoxRadio.image = UIImage(named: "RadioHasBoxOff")
        if game.hasBox {
            hasBoxRadio.image = UIImage(named: "RadioHasBoxOn")
        }
        
        specialEditionRadio.image = UIImage(named: "RadioSpecialEditionOff")
        if game.isSpecialEdition {
            specialEditionRadio.image = UIImage(named: "RadioSpecialEditionOn")
        }
        
        emptyImageCollectionLabel.isHidden = true
        if gameImages.isEmpty {
            emptyImageCollectionLabel.isHidden = false
            deletePhotoButton.isEnabled = false
        }
        
        gameDescription.isHidden = true
        if hasDescription {
            gameDescription.isHidden = false
        }
    }
    
    
}
