//
//  GameDetailsController.swift
//  GameTrkr
//
//  Created by Sean Foreman on 3/30/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import YouTubePlayer_Swift

class GameDetailsController: UIViewController {
    
    @IBOutlet weak var youtubePlayer: YouTubePlayerView!
    @IBOutlet weak var noPlayerText: UITextView!
    @IBOutlet weak var watchAVideoButton: UIButton!
    @IBOutlet weak var watchAnotherVideoButton: UIBarButtonItem!
    @IBOutlet weak var digitalRadio: UIImageView!
    @IBOutlet weak var hasBoxRadio: UIImageView!
    @IBOutlet weak var specialEditionRadio: UIImageView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var gameImageCollection: UICollectionView!
    @IBOutlet weak var emptyImageCollectionLabel: UILabel!
    @IBOutlet weak var addNewPhotoButton: UIBarButtonItem!
    @IBOutlet weak var deletePhotoButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var gameDescription: UITextView!
    
    var youtubeURL: String!
    var defaultURL: String!
    var platform: Platform!
    var game: Game!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    let pickerController = UIImagePickerController()
    var photoArray: [Photo] = []
    var platformName: String!
    var gameTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = platform.name! + " " + game.title!
        
        gameImageCollection.delegate = self
        pickerController.delegate = self
        
        setupFetchedResultsController()
        setCollectionFormat()
        
        photoArray = fetchedResultsController.fetchedObjects ?? []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchedResultsController()
        updateYoutubePlayer()
        updateDigitalRadio()
        updateHasBoxRadio()
        updateSpecialEditionRadio()
        updateCollectionState()
        updateDescriptionState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "game == %@", game)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "addDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "games")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    fileprivate func setCollectionFormat() {
        let space: CGFloat = 4.0
        let size = self.view.frame.size
        let dWidth = (size.width - (space)) / 3.0
        let dHeight = (size.height - (space)) / 1.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dWidth, height: dHeight)
    }
    
    @IBAction func photoSelect(_ sender: Any) {
        photoSelector(source: .photoLibrary)
    }
    
    @IBAction func cancel() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func enterEditDetails(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToEditController", sender: nil)
    }
    
    //Add IBAction for watchAnotherVideo button.  Set to YouTube's next video functionality (may need to run getPlaylistVideo if next functionality is not available when game.youtubeURL is used)
    
    @IBAction func toggleEditing(_ sender: UIBarButtonItem) {
        self.setEditing(!self.isEditing, animated: true)
        deletePhotoButton.title = self.isEditing ? "Done" : "Remove Photos"
        
        if isEditing {
            addNewPhotoButton.isEnabled = false
            watchAVideoButton.isEnabled = false
            watchAnotherVideoButton.isEnabled = false
            editButton.isEnabled = false
        } else {
            addNewPhotoButton.isEnabled = true
            watchAVideoButton.isEnabled = true
            watchAnotherVideoButton.isEnabled = true
            editButton.isEnabled = true
        }
    }
    
    @IBAction func retreiveDefaultVideo(_ sender: UIButton) {
        AppClient.getPlaylistVideo(platformName: platform.name!, gameTitle: game.title!, completion: handleURLResponse(videos:error:))
    }
    
    func handleURLResponse(videos: [Items]?, error: Error?) {
        if videos != nil {
            youtubePlayer.isHidden = false
            defaultURL = DefaultVideo.video
            youtubePlayer.loadVideoID(defaultURL)
        } else {
            showVideoRetreivalFailure()
            print(error!)
        }
    }
    
    func showVideoRetreivalFailure() {
        let alertVC = UIAlertController(title: "Unable to Get Video", message: "Please check your internet connection and try the Watch Video button, again.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
    func photoSelector(source: UIImagePickerController.SourceType) {
        pickerController.allowsEditing = false
        present(pickerController, animated: true, completion: nil)
    }
    
    func updateYoutubePlayer() {
        if game.hasDefaultYoutubeURL {
            youtubePlayer.isHidden = false
            youtubeURL = game.youtubeURL
            noPlayerText.isHidden = true
            watchAVideoButton.isHidden = true
            watchAVideoButton.isEnabled = false
            youtubePlayer.loadVideoURL(URL(string: youtubeURL)!)
        } else {
            youtubePlayer.isHidden = true
            noPlayerText.isHidden = false
            watchAVideoButton.isHidden = false
            watchAVideoButton.isEnabled = true
            watchAnotherVideoButton.isEnabled = false
        }
    }
    
    func updateDigitalRadio() {
        if game.isDigital {
            digitalRadio.image = UIImage(named: "RadioDigitalOn")
        } else {
            digitalRadio.image = UIImage(named: "RadioDigitalOff")
        }
    }
    
    func updateHasBoxRadio() {
        if game.hasBox {
            hasBoxRadio.image = UIImage(named: "RadioHasBoxOn")
        } else {
            hasBoxRadio.image = UIImage(named: "RadioHasBoxOff")
        }
    }
    
    func updateSpecialEditionRadio() {
        if game.isSpecialEdition {
            specialEditionRadio.image = UIImage(named: "RadioSpecialEditionOn")
        } else {
            specialEditionRadio.image = UIImage(named: "RadioSpecialEditionOff")
        }
    }
    
    func updateCollectionState() {
        if photoArray.count > 0 {
            emptyImageCollectionLabel.isHidden = true
            deletePhotoButton.isEnabled = true
        } else {
            emptyImageCollectionLabel.isHidden = false
            deletePhotoButton.isEnabled = false
        }
    }
    
    func updateDescriptionState() {
        if game.hasDescription {
            gameDescription.isHidden = false
            gameDescription.text = game.gameText
        } else {
            gameDescription.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? GameDetailsEditController {
            destinationVC.platform = platform
            destinationVC.game = game
            destinationVC.dataController = dataController
        }
    }
    
}

extension GameDetailsController: UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let image = photoArray[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GamePhotoCell.defaultReuseIdentifier, for: indexPath) as! GamePhotoCell
        
        cell.gameImage.image = UIImage(data: image.photo!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "GameImageDetailController") as! GameImageDetailController
        let image = photoArray[indexPath.row]
        detailController.selectedImage = UIImage(data: image.photo!)
        self.navigationController!.pushViewController(detailController, animated: true)
        
        if isEditing {
            dataController.viewContext.delete(image)
            try? dataController.viewContext.save()
            updateCollectionState()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let photo = Photo(context: dataController.viewContext)
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let photoData: Data = image.pngData()!
            photo.photo = photoData
            photo.addDate = Date()
            try? dataController.viewContext.save()
            photoArray.append(photo)
            updateCollectionState()
            print("Photo added to \(platform.name!) \(game.title!) successfully.")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
