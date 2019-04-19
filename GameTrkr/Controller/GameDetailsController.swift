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
    
    // MARK: Class setup
    
    @IBOutlet weak var youtubePlayer: YouTubePlayerView!
    @IBOutlet weak var curtainView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyPlayerText: UITextView!
    @IBOutlet weak var loadVideoButton: UIBarButtonItem!
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
    
    @IBOutlet weak var collectionViewConstraints: NSLayoutConstraint!
    
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
    var videoArray: [Items] = []
    var currentVideo: Int = 0
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = platform.name! + " " + game.title!
        
        setupFetchedResultsController()
        setCollectionFormat()
        
        pickerController.delegate = self
        gameImageCollection.delegate = self
        gameImageCollection.dataSource = self
        
        photoArray = fetchedResultsController.fetchedObjects ?? []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        curtainView.isHidden = false
        emptyPlayerText.isHidden = false
        activityIndicator.hidesWhenStopped = true
        
        setupFetchedResultsController()
        updateYoutubePlayer()
        updateDigitalRadio()
        updateHasBoxRadio()
        updateSpecialEditionRadio()
        updateCollectionState()
        gameImageCollection.reloadData()
        updateDescriptionState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    // MARK: IBActions and Class functions
    
    @IBAction func photoSelect(_ sender: Any) {
        photoSelector(source: .photoLibrary)
    }
    
    @IBAction func cancel() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func enterEditDetails(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToEditController", sender: nil)
    }
    
    @IBAction func nextVideo(_ sender: UIBarButtonItem) {
        curtainView.isHidden = false
        activityIndicator.startAnimating()
        currentVideo = currentVideo + 1
        if currentVideo >= 25 {
            currentVideo = 0
        }
        
        youtubePlayer.loadVideoID(videoArray[currentVideo].id.videoId!)
        curtainView.isHidden = true
        activityIndicator.stopAnimating()
        activityIndicator.hidesWhenStopped = true
    }
    
    @IBAction func toggleEditing(_ sender: UIBarButtonItem) {
        self.setEditing(!self.isEditing, animated: true)
        deletePhotoButton.title = self.isEditing ? "Done" : "Remove Photos"
        
        if isEditing {
            addNewPhotoButton.isEnabled = false
            loadVideoButton.isEnabled = false
            watchAnotherVideoButton.isEnabled = false
            editButton.isEnabled = false
        } else {
            addNewPhotoButton.isEnabled = true
            loadVideoButton.isEnabled = true
            watchAnotherVideoButton.isEnabled = false
            editButton.isEnabled = true
        }
    }
    
    @IBAction func retreiveDefaultVideo(_ sender: UIBarButtonItem) {
        // Calls Youtube API to get the first video from a search using Platform name and Game title as search terms.
        AppClient.getPlaylistVideo(platformName: platform.name!, gameTitle: game.title!, completion: handleURLResponse(videos:error:))
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
        //Sets the formatting rules for the collection view's FlowLayout.
        let space: CGFloat = 2.0
        let size = self.view.frame.size
        let dWidth = (size.width - (space)) / 1.0
        let dHeight = (size.height - (space)) / 1.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dWidth, height: dHeight)
    }
    
    func handleURLResponse(videos: [Items]?, error: Error?) {
        if videos != nil {
            curtainView.isHidden = false
            emptyPlayerText.isHidden = true
            activityIndicator.startAnimating()
            videoArray = videos!
            defaultURL = videoArray[currentVideo].id.videoId
            youtubePlayer.loadVideoID(defaultURL)
            curtainView.isHidden = true
            activityIndicator.stopAnimating()
            watchAnotherVideoButton.isEnabled = true
        } else {
            showVideoRetreivalFailure(message: error?.localizedDescription ?? "")
            watchAnotherVideoButton.isEnabled = false
            print(error!)
        }
        activityIndicator.hidesWhenStopped = true
    }
    
    func showVideoRetreivalFailure(message: String) {
        let alertVC = UIAlertController(title: "Unable to Get Video", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true)
    }
    
    func photoSelector(source: UIImagePickerController.SourceType) {
        present(pickerController, animated: true, completion: nil)
    }
    
    // MARK: UI Update functions - Set the state of the controller assets
    
    func updateYoutubePlayer() {
        if game.hasDefaultYoutubeURL {
            curtainView.isHidden = false
            emptyPlayerText.isHidden = true
            activityIndicator.startAnimating()
            youtubeURL = game.youtubeURL
            youtubePlayer.loadVideoURL(URL(string: youtubeURL)!)
            curtainView.isHidden = true
            activityIndicator.stopAnimating()
            watchAnotherVideoButton.isEnabled = false
        } else {
            watchAnotherVideoButton.isEnabled = false
        }
        activityIndicator.hidesWhenStopped = true
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

    // MARK: Class extension - Protocol list and delegate rules

extension GameDetailsController: UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GamePhotoCell.defaultReuseIdentifier, for: indexPath) as! GamePhotoCell
        let image = photoArray[indexPath.row]
        
        cell.gameImage.image = UIImage(data: image.photoData!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = photoArray[indexPath.row]
        
        if isEditing {
            dataController.viewContext.delete(image)
            try? dataController.viewContext.save()
            gameImageCollection.reloadData()
            updateCollectionState()
        } else {
            let detailController = self.storyboard!.instantiateViewController(withIdentifier: "GameImageDetailController") as! GameImageDetailController
            detailController.selectedImage = UIImage(data: image.photoData!)
            self.navigationController!.pushViewController(detailController, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let photo = Photo(context: dataController.viewContext)
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let imageData = image.jpegData(compressionQuality: 1.0)
            photo.photoData = imageData
            photo.addDate = Date()
            try? dataController.viewContext.save()
            photoArray.append(photo)
            gameImageCollection.reloadData()
            updateCollectionState()
            print("Photo added to \(platform.name!) \(game.title!) successfully.")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
