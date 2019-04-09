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
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var gameDescription: UITextView!
    
    var youtubeURL: String!
    var hasDefaultYoutubeURL: Bool!
    var hasDescription: Bool!
    var platform: Platform!
    var game: Game!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var pickerController: UIImagePickerController!
    var blockOperations: [BlockOperation] = []
    var platformName: String!
    var gameTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = platform.name! + " " + game.title!
        
        hasDefaultYoutubeURL = false
        //need default youtubeURL to be search with Platform and Game
        if hasDefaultYoutubeURL {
            game.youtubeURL = youtubeURL
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
        if let sections = fetchedResultsController.sections {
            if sections[0].numberOfObjects > 0 {
                emptyImageCollectionLabel.isHidden = true
                deletePhotoButton.isEnabled = true
            } else {
                emptyImageCollectionLabel.isHidden = false
                deletePhotoButton.isEnabled = false
            }
        }
        
        hasDescription = false
        gameDescription.isHidden = true
        if hasDescription {
            gameDescription.isHidden = false
            gameDescription.text = game.gameText
        } else {
            gameDescription.isHidden = true
        }
        
        updateDeleteButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchedResultsController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fetchedResultsController = nil
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "game == %@", game)
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "photos")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    @IBAction func enterEditDetails(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToEditController", sender: nil)
    }
    
    @IBAction func toggleEditing(_ sender: UIBarButtonItem) {
        self.setEditing(!self.isEditing, animated: true)
        deletePhotoButton.title = self.isEditing ? "Done" : "Remove Photos"
        
        if isEditing {
            addNewPhotoButton.isEnabled = false
            watchAnotherVideoButton.isEnabled = false
            editButton.isEnabled = false
        }
    }
    
    @IBAction func photoSelect(_ sender: Any) {
        photoSelector(source: .photoLibrary)
    }
    
    @IBAction func cancel() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func updateDeleteButton() {
        if let sections = fetchedResultsController.sections {
            if sections[0].numberOfObjects > 0 {
                deletePhotoButton.isEnabled = true
            } else {
                deletePhotoButton.isEnabled = false
            }
        }
    }
    
    func photoSelector(source: UIImagePickerController.SourceType) {
        pickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        present(pickerController, animated: true, completion: nil)
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let image = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GamePhotoCell.defaultReuseIdentifier, for: indexPath) as! GamePhotoCell
        
        cell.gameImage.image = UIImage(data: image.photo!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "GameImageDetailController") as! GameImageDetailController
        let image = fetchedResultsController.object(at: indexPath)
        detailController.selectedImage = UIImage(data: image.photo!)
        self.navigationController!.pushViewController(detailController, animated: true)
        
        if isEditing {
            dataController.viewContext.delete(image)
            try? dataController.viewContext.save()
        }
    }
    
    //blockOperations methods gathered from https://stackoverflow.com/questions/20554137/nsfetchedresultscontollerdelegate-for-collectionview/20554673#20554673
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeObject anObject: AnyObject, anIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if type == NSFetchedResultsChangeType.insert {
            blockOperations.append(BlockOperation(block: { [weak self] in
                if let this = self {
                    this.gameImageCollection!.reloadItems(at: [indexPath! as IndexPath])
                }
            }))
        } else if type == NSFetchedResultsChangeType.delete {
            blockOperations.append(BlockOperation(block: { [weak self] in
                if let this = self {
                    this.gameImageCollection!.deleteItems(at: [indexPath! as IndexPath])
                }
            }))
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        gameImageCollection.performBatchUpdates({ () -> Void in
            for operation: BlockOperation in self.blockOperations {
                operation.start()
            }
        }, completion: { (finished) -> Void in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let photo = Photo(context: dataController.viewContext)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photo.photo = image.pngData()!
            try? dataController.viewContext.save()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
