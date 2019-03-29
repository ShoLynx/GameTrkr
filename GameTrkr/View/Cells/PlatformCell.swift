//
//  PlatformCell.swift
//  GameTrkr
//
//  Created by Sean Foreman on 3/27/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import Foundation
import UIKit

internal final class PlatformCell: UITableViewCell, Cell {
    
    @IBOutlet weak var platformName: UILabel!
    @IBOutlet weak var gamesSub: UILabel!
    
    override func prepareForReuse() {
        platformName.text = nil
        gamesSub.text = nil
    }
}
