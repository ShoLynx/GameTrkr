//
//  GameDetailsController.swift
//  GameTrkr
//
//  Created by Sean Foreman on 3/30/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import Foundation
import UIKit

class GameDetailsController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var youtubePlayerView: UIView!
    @IBOutlet weak var watchAnotherVideoButton: UIBarButtonItem!
    @IBOutlet weak var digitalRadio: UIImageView!
    @IBOutlet weak var hasBoxRadio: UIImageView!
    @IBOutlet weak var specialEditionRadio: UIImageView!
    @IBOutlet weak var gameImageCollection: UICollectionView!
    @IBOutlet weak var emptyImageCollectionLabel: UILabel!
    @IBOutlet weak var addNewPhotoButton: UIBarButtonItem!
    @IBOutlet weak var deletePhotoButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var gameDescription: UITextView!
    
    var youtubeURL: String!
    var hasDefaultYoutubeURL: Bool!
    var gameImages: [UIImage] = []
    var hasDescription: Bool!
    var platform: Platform!
    var game: Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = platform.name + " " + game.name
        
        hasDefaultYoutubeURL = false
        //need default youtubeURL to be search with Platform and Game
        if hasDefaultYoutubeURL {
            //apply game.youtubeURL to player
        }
        
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
            gameDescription.text = game.gameText
        }
        
        updateDeleteButton()
    }
    
    @IBAction func toggleEditing(_ sender: UIBarButtonItem) {
        isEditing = true
        
        if isEditing {
            addNewPhotoButton.isEnabled = false
            watchAnotherVideoButton.isEnabled = false
            editButton.isEnabled = false
            sender.title = "Done"
        }
    }
    
    func updateDeleteButton() {
        deletePhotoButton.isEnabled = numberOfPhotos > 0
    }
    
    func photoSelector(source: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func photoSelect(_ sender: Any) {
        photoSelector(source: .photoLibrary)
    }
    
    @IBAction func cancel() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfPhotos
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let image = photo(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GamePhotoCell.defaultReuseIdentifier, for: indexPath) as! GamePhotoCell
        
        cell.gameImage.image = image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "GameImageDetailController") as! GameImageDetailController
        let image = photo(at: indexPath)
        detailController.selectedImage = image
        self.navigationController!.pushViewController(detailController, animated: true)
        
        if isEditing {
            gameImages.remove(at: indexPath.row)
        }
    }
    
    
    var numberOfPhotos: Int { return gameImages.count }
    
    func photo(at indexPath: IndexPath) -> UIImage {
        return gameImages[indexPath.row]
    }
    
}
