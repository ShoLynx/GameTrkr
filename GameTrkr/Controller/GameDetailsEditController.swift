//
//  GameDetailsEditController.swift
//  GameTrkr
//
//  Created by Sean Foreman on 3/31/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class GameDetailsEditController: UIViewController {
    
    @IBOutlet weak var defaultVideoSwitch: UISwitch!
    @IBOutlet weak var youTubeField: UITextField!
    @IBOutlet weak var digitalSwitch: UISwitch!
    @IBOutlet weak var platformPicker: UIPickerView!
    @IBOutlet weak var hasBoxSwitch: UISwitch!
    @IBOutlet weak var specialEditionSwitch: UISwitch!
    @IBOutlet weak var addDescriptionSwitch: UISwitch!
    @IBOutlet weak var descriptionText: UITextView!
    
    var platform: Platform!
    var game: Game!
    var platforms: [Platform] = []
    let gameDetails = GameDetailsController()
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Platform>!
    var platformName: String!
    var gameTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = platform.name! + " " + game.title!
        
        if game.youtubeURL != nil {
            defaultVideoSwitch.isOn = true
            youTubeField.text = game.youtubeURL
        } else {
            defaultVideoSwitch.isOn = false
        }
        
        if game.isDigital {
            digitalSwitch.isOn = true
        } else {
            digitalSwitch.isOn = false
        }
        
        if game.hasBox {
            hasBoxSwitch.isOn = true
        } else {
            hasBoxSwitch.isOn = false
        }
        
        if game.isSpecialEdition {
            specialEditionSwitch.isOn = true
        } else {
            specialEditionSwitch.isOn = false
        }
        
        if game.gameText != nil {
            addDescriptionSwitch.isOn = true
            descriptionText.text = game.gameText
        } else {
            addDescriptionSwitch.isOn = false
        }
        
        platformPicker.dataSource = self
        platformPicker.delegate = self
        descriptionText.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchedResultsController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        try? dataController.viewContext.save()
        fetchedResultsController = nil
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Platform> = Platform.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "platforms")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    fileprivate func updateDefaultVideoSwitch() {
        if defaultVideoSwitch.isOn {
            youTubeField.isEnabled = true
            gameDetails.hasDefaultYoutubeURL = true
            game.youtubeURL = youTubeField.text ?? ""
        } else {
            youTubeField.isEnabled = false
            gameDetails.hasDefaultYoutubeURL = false
            game.youtubeURL = nil
        }
    }
    
    fileprivate func updateDigitalSwitch() {
        if digitalSwitch.isOn {
            game.isDigital = true
        } else {
            game.isDigital = false
        }
    }
    
    fileprivate func updateHasBoxSwitch() {
        if digitalSwitch.isOn {
            game.hasBox = true
        } else {
            game.hasBox = false
        }
    }
    
    fileprivate func updateSpecialEditionSwitch() {
        if specialEditionSwitch.isOn {
            game.isSpecialEdition = true
        } else {
            game.isSpecialEdition = false
        }
    }
    
    fileprivate func updateDescriptionSwitch() {
        if addDescriptionSwitch.isOn {
            descriptionText.isEditable = true
            gameDetails.hasDescription = true
        } else {
            descriptionText.isEditable = false
            gameDetails.hasDescription = false
        }
    }
}

extension GameDetailsEditController: UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, NSFetchedResultsControllerDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        game.platform = fetchedResultsController.object(at: [row])
        try? dataController.viewContext.save()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let platformNames = [platform.name]
        return platformNames[row]
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        game.gameText = textView.text
        try? dataController.viewContext.save()
    }
}
