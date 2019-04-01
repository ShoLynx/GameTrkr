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
    
    @IBOutlet weak var defaultVideoSwitch: UISwitch!
    @IBOutlet weak var youTubeField: UITextField!
    @IBOutlet weak var digitalSwitch: UISwitch!
    @IBOutlet weak var hasBoxSwitch: UISwitch!
    @IBOutlet weak var specialEditionSwitch: UISwitch!
    @IBOutlet weak var addDescriptionSwitch: UISwitch!
    @IBOutlet weak var descriptionText: UITextView!
    
    var game: Game! //selected game from indexPath
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = game.name
        
        defaultVideoSwitch.isOn = false
        if defaultVideoSwitch.isOn {
            //game.youTubeURL = youTubeField.text ?? ""
        }
        digitalSwitch.isOn = false
        if digitalSwitch.isOn {
            //game.isDigital = true
        }
        hasBoxSwitch.isOn = false
        if digitalSwitch.isOn {
            //game.hasBox = true
        }
        specialEditionSwitch.isOn = false
        if specialEditionSwitch.isOn {
            //game.isSpecialEdition = true
        }
        
        addDescriptionSwitch.isOn = false
        if addDescriptionSwitch.isOn {
            descriptionText.isEditable = true
            //game.description = descriptionText.text
        }
    }
}
