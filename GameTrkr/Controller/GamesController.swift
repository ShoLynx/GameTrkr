//
//  GamesController.swift
//  GameTrkr
//
//  Created by Sean Foreman on 3/28/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import Foundation
import UIKit

class GamesController: UITableViewController {
    
    @IBOutlet var gameTable: UITableView!
    @IBOutlet weak var noGamesText: UITextView!
    @IBOutlet weak var newGameButton: UIBarButtonItem!
    
    var platform: Platform!
    var games: [Game] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(toggleEditing))
        self.navigationItem.rightBarButtonItem = editButton
        
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
}
