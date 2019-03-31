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
    var games: [Games] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = platform.name
        noGamesText.isHidden = true
        if games.isEmpty {
            noGamesText.isHidden = false
        }
    }
}
