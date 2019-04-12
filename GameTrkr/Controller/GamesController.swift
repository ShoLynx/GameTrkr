//
//  GamesController.swift
//  GameTrkr
//
//  Created by Sean Foreman on 3/28/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class GamesController: UIViewController {
    
    @IBOutlet var gameTable: UITableView!
    @IBOutlet weak var noGamesText: UITextView!
    @IBOutlet weak var newGameButton: UIBarButtonItem!
    
    var platform: Platform!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Game>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameTable.dataSource = self
        gameTable.delegate = self
        
        let editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(toggleEditing))
        self.navigationItem.rightBarButtonItem = editButton
        
        navigationItem.title = platform.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        setupFetchedResultsController()
        
        if let indexPath = gameTable.indexPathForSelectedRow {
            gameTable.deselectRow(at: indexPath, animated: false)
            gameTable.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
        let predicate = NSPredicate(format: "platform == %@", platform)
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
        updateEditButton()
        updateEmptyText()
    }
    
    @objc private func toggleEditing() {
        gameTable.setEditing(!gameTable.isEditing, animated: true)
        navigationItem.rightBarButtonItem?.title = gameTable.isEditing ? "Done" : "Edit"
    }
    
    @IBAction func addTapped(sender: Any) {
        newGameAlert()
    }
    
    func addGame(title: String) {
        let game = Game(context: dataController.viewContext)
        game.platform = platform
        game.title = title
        try? dataController.viewContext.save()
        print("\(game.title!) has been added to the \(platform.name!) platform successfully.")
    }
    
    func deleteGame(at indexPath: IndexPath) {
        let gameToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(gameToDelete)
        try? dataController.viewContext.save()
        print("The game has been removed successfully.")
    }
    
    func updateEditButton() {
        if let sections = fetchedResultsController.sections {
            navigationItem.rightBarButtonItem?.isEnabled = sections[0].numberOfObjects > 0
        }
    }
    
    func updateEmptyText() {
        if let sections = fetchedResultsController.sections {
            if sections[0].numberOfObjects > 0 {
                gameTable.isHidden = false
                noGamesText.isHidden = true
            } else {
                gameTable.isHidden = true
                noGamesText.isHidden = false
            }
        }
    }
    
    func newGameAlert() {
        let alert = UIAlertController(title: "New Game", message: "Enter a name for this game.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] action in
            if let name = alert.textFields?.first?.text {
                self?.addGame(title: name)
            }
        }
        confirmAction.isEnabled = false
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { (notif) in
                if let text = textField.text, !text.isEmpty {
                    confirmAction.isEnabled = true
                } else {
                    confirmAction.isEnabled = false
                }
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? GameDetailsController {
            if let indexPath = gameTable.indexPathForSelectedRow {
                destinationVC.platform = platform
                destinationVC.game = fetchedResultsController.object(at: indexPath)
                destinationVC.dataController = dataController
            }
        }
    }
}


extension GamesController: UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GameCell.defaultReuseIdentifier, for: indexPath) as! GameCell
        let iGame = fetchedResultsController.object(at: indexPath)
        
        cell.gameTitle.text = iGame.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToDetailsController", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteGame(at: indexPath)
        default: ()
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        gameTable.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        gameTable.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            gameTable.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            gameTable.deleteRows(at: [indexPath!], with: .fade)
        default:
            break
        }
    }

}
