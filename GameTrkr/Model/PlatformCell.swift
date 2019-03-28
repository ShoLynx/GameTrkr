//
//  PlatformCell.swift
//  GameTrkr
//
//  Created by Sean Foreman on 3/27/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import Foundation
import UIKit

class PlatformCell: UITableViewCell {
    
    @IBOutlet weak var platformName: UILabel!
    @IBOutlet weak var gamesSub: UILabel!
    
    func configure(with model: Platform) {
        platformName.text = model.name
        gamesSub.text = "Games: \(model.games.count)"
    }
}
