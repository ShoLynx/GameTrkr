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
    var games: [Game] = []
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameTable.dataSource = self
        gameTable.delegate = self
        
        let editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(toggleEditing))
        self.navigationItem.rightBarButtonItem = editButton
        
        navigationItem.title = platform.name
        
        let fetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
        let predicate = NSPredicate(format: "platform == %@", platform)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            games = result
            gameTable.reloadData()
        }
        
        updateEditButton()
        updateEmptyText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        if let indexPath = gameTable.indexPathForSelectedRow {
            gameTable.deselectRow(at: indexPath, animated: false)
            gameTable.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        PlatformController().dataController = dataController
//    }
    
    @objc private func toggleEditing() {
        gameTable.setEditing(!gameTable.isEditing, animated: true)
        navigationItem.rightBarButtonItem?.title = gameTable.isEditing ? "Done" : "Edit"
    }
    
    @IBAction func addTapped(sender: Any) {
        newGameAlert()
    }
    
    func addGame(title: String) {
        let game = Game(context: dataController.viewContext)
        game.title = title
        games.append(game)
        try? dataController.viewContext.save()
        gameTable.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        updateEditButton()
        updateEmptyText()
        gameTable.reloadData()
    }
    
    func deleteGame(at indexPath: IndexPath) {
        let gameToDelete = game(at: indexPath)
        dataController.viewContext.delete(gameToDelete)
        try? dataController.viewContext.save()
        games.remove(at: indexPath.row)
        gameTable.deleteRows(at: [indexPath], with: .fade)
        if numberOfGames == 0 {
            setEditing(false, animated: true)
        }
        
        updateEditButton()
        updateEmptyText()
        gameTable.reloadData()
    }
    
    func updateEditButton() {
        navigationItem.rightBarButtonItem?.isEnabled = numberOfGames > 0
    }
    
    func updateEmptyText() {
        if games.isEmpty {
            gameTable.isHidden = true
            noGamesText.isHidden = false
        } else {
            gameTable.isHidden = false
            noGamesText.isHidden = true
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
                destinationVC.game = game(at: indexPath)
                destinationVC.dataController = dataController
            }
        }
    }
}


extension GamesController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfGames
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GameCell.defaultReuseIdentifier, for: indexPath) as! GameCell
        let iGame = game(at: indexPath)
        
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
    
    func game(at indexPath: IndexPath) -> Game {
        return games[indexPath.row]
    }
    
    var numberOfGames: Int { return games.count }
}
