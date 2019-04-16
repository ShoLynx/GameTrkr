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
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Game>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = platform.name! + " " + game.title!
        
        if game.hasDefaultYoutubeURL {
            defaultVideoSwitch.isOn = true
        } else {
            defaultVideoSwitch.isOn = false
        }
        
        if game.youtubeURL != nil {
            youTubeField.text = game.youtubeURL
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
        
        if game.hasDescription {
            addDescriptionSwitch.isOn = true
        } else {
            addDescriptionSwitch.isOn = false
        }
        
        if game.gameText != nil {
            descriptionText.text = game.gameText
        }
        
        platformPicker.dataSource = self
        platformPicker.delegate = self
        descriptionText.delegate = self
        
        setupFetchedResultsController()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if defaultVideoSwitch.isOn {
            game.youtubeURL = youTubeField.text
        }
        
        if addDescriptionSwitch.isOn {
            game.gameText = descriptionText.text
        }
        
        try? dataController.viewContext.save()
        fetchedResultsController = nil
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
        let predicate = NSPredicate(format: "platform == %@", game)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "platforms")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    @IBAction func defaultYoutbeVideoSwitched(_ sender: UISwitch) {
        if sender.isOn == true {
            youTubeField.isEnabled = true
            game.hasDefaultYoutubeURL = true
            game.youtubeURL = youTubeField.text ?? ""
        } else {
            youTubeField.isEnabled = false
            game.hasDefaultYoutubeURL = false
            game.youtubeURL = nil
        }
    }
    
    @IBAction func isDigitalSwitched(_ sender: UISwitch) {
        if sender.isOn == true {
            game.isDigital = true
        } else {
            game.isDigital = false
        }
    }
    
    @IBAction func hasBoxSwitched(_ sender: UISwitch) {
        if sender.isOn == true {
            game.hasBox = true
        } else {
            game.hasBox = false
        }
    }
    
    @IBAction func isSpecialEditionSwitched(_ sender: UISwitch) {
        if sender.isOn == true {
            game.isSpecialEdition = true
        } else {
            game.isSpecialEdition = false
        }
    }
    
    @IBAction func hasDescriptionSwitched(_ sender: UISwitch) {
        if sender.isOn == true {
            descriptionText.isEditable = true
            game.hasDescription = true
            game.gameText = descriptionText.text
        } else {
            descriptionText.isEditable = false
            game.hasDescription = false
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
//        game.platform = fetchedResultsController.object(at: [row])
        try? dataController.viewContext.save()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fetchedResultsController.sections?[0].name
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        game.gameText = textView.text
        try? dataController.viewContext.save()
    }
}
