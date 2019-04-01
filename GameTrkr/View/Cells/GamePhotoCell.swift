//
//  GamePhotoCell.swift
//  GameTrkr
//
//  Created by Sean Foreman on 3/31/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import Foundation
import UIKit

internal final class GamePhotoCell: UICollectionViewCell, Cell {
    
    @IBOutlet weak var gameImage: UIImageView!
    
    override func prepareForReuse() {
        gameImage.image = nil
    }
}
