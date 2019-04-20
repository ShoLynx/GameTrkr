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
    
    // MARK: Class setup
    
    @IBOutlet weak var defaultVideoSwitch: UISwitch!
    @IBOutlet weak var youTubeField: UITextField!
    @IBOutlet weak var digitalSwitch: UISwitch!
    @IBOutlet weak var hasBoxSwitch: UISwitch!
    @IBOutlet weak var specialEditionSwitch: UISwitch!
    @IBOutlet weak var addDescriptionSwitch: UISwitch!
    @IBOutlet weak var descriptionText: UITextView!
    
    var platform: Platform!
    var game: Game!
    var platforms: [Platform] = []
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Game>!
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = platform.name! + " " + game.title!
        
        // Set the default position of all switches in the view.  New games will default to all switches being off, since their values are defaulted to off at creation.
        
        if game.hasDefaultYoutubeURL {
            defaultVideoSwitch.isOn = true
        } else {
            defaultVideoSwitch.isOn = false
        }
        
        // Load existing youtubeURLs of they are available.
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
        
        // Load existing game descriptions if they are avaialble.
        if game.gameText != nil {
            descriptionText.text = game.gameText
        }
        
        youTubeField.delegate = self
        descriptionText.delegate = self
        
        // Adding to viewDidLoad, as this view is the last in the chain.  It cannot be backed into.
        setupFetchedResultsController()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
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
        
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: IBActions and Class functions
    
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
    
    // MARK: TextView obscurrance prevention
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if descriptionText.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
}

    // MARK: Class extension - Protocol list and delegate rules

extension GameDetailsEditController: UITextViewDelegate, UITextFieldDelegate,  NSFetchedResultsControllerDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        game.gameText = textView.text
        if textView.text!.isEmpty {
            game.gameText = nil
            game.hasDescription = false
        }
        try? dataController.viewContext.save()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let defaultText = "Enter a description for your game."
        if textView.text == defaultText {
            textView.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        game.youtubeURL = textField.text
        if textField.text!.isEmpty {
            game.youtubeURL = nil
            game.hasDefaultYoutubeURL = false
        }
        try? dataController.viewContext.save()
    }
}
