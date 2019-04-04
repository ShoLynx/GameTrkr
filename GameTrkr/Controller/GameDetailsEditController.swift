//
//  GameDetailsEditController.swift
//  GameTrkr
//
//  Created by Sean Foreman on 3/31/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import Foundation
import UIKit

class GameDetailsEditController: UIViewController {
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var defaultVideoSwitch: UISwitch!
    @IBOutlet weak var youTubeField: UITextField!
    @IBOutlet weak var digitalSwitch: UISwitch!
    @IBOutlet weak var hasBoxSwitch: UISwitch!
    @IBOutlet weak var specialEditionSwitch: UISwitch!
    @IBOutlet weak var addDescriptionSwitch: UISwitch!
    @IBOutlet weak var descriptionText: UITextView!
    
    var platform: Platform!
    var game: Game!
    let gameDetails = GameDetailsController()
    var platformName: String!
    var gameTitle: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let name = platform.name {
            platformName = name
        }
        
        if let title = game.title {
            gameTitle = title
        }
        
        navigationItem.title = platformName + " " + gameTitle
        
        youTubeField.isEnabled = false
        descriptionText.isEditable = false
        
        defaultVideoSwitch.isOn = false
        if defaultVideoSwitch.isOn {
            youTubeField.isEnabled = true
            gameDetails.hasDefaultYoutubeURL = true
            game.youtubeURL = youTubeField.text ?? ""
        }
        
        digitalSwitch.isOn = false
        if digitalSwitch.isOn {
            game.isDigital = true
        }
        
        hasBoxSwitch.isOn = false
        if digitalSwitch.isOn {
            game.hasBox = true
        }
        
        specialEditionSwitch.isOn = false
        if specialEditionSwitch.isOn {
            game.isSpecialEdition = true
        }
        
        addDescriptionSwitch.isOn = false
        if addDescriptionSwitch.isOn {
            descriptionText.isEditable = true
            gameDetails.hasDescription = true
            game.gameText = descriptionText.text
        }
        
    }
    
    @IBAction func exitEdit(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
