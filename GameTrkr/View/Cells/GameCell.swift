//
//  GameCell.swift
//  GameTrkr
//
//  Created by Sean Foreman on 3/28/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import Foundation
import UIKit

internal final class GameCell: UITableViewCell, Cell {
    
    @IBOutlet weak var gameTitle: UILabel!
    
    override func prepareForReuse() {
        gameTitle.text = nil
    }
}
