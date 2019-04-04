//
//  GamesController.swift
//  GameTrkr
//
//  Created by Sean Foreman on 3/28/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import Foundation
import UIKit

class GamesController: UIViewController, UITableViewDataSource {
    
    @IBOutlet var gameTable: UITableView!
    @IBOutlet weak var noGamesText: UITextView!
    @IBOutlet weak var newGameButton: UIBarButtonItem!
    
    var platform: Platform!
    var games: [Game] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(toggleEditing))
        self.navigationItem.rightBarButtonItem = editButton
        updateEditButton()
        
        navigationItem.title = platform.name
        
        noGamesText.isHidden = true
        if games.isEmpty {
            noGamesText.isHidden = false
        }
    }
    
    @objc private func toggleEditing() {
        gameTable.setEditing(!gameTable.isEditing, animated: true)
        navigationItem.rightBarButtonItem?.title = gameTable.isEditing ? "Done" : "Edit"
    }
    
    @IBAction func addTapped(sender: Any) {
        newGameAlert()
    }
    
    func addGame(title: String) {
        //TODO: need viewContext values
//        let game = Game(name: title)
//        games.append(game)
        gameTable.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        updateEditButton()
    }
    
    func deleteGame(at indexPath: IndexPath) {
        games.remove(at: indexPath.row)
        gameTable.deleteRows(at: [indexPath], with: .fade)
        if numberOfGames == 0 {
            setEditing(false, animated: true)
        }
        updateEditButton()
    }
    
    func updateEditButton() {
        navigationItem.rightBarButtonItem?.isEnabled = numberOfGames > 0
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
        //segue to selected platform's Games controller
    }
    
    func game(at indexPath: IndexPath) -> Game {
        return games[indexPath.row]
    }
    
    var numberOfGames: Int { return games.count }
}
