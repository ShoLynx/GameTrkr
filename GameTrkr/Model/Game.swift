//
//  Game.swift
//  GameTrkr
//
//  Created by Sean Foreman on 4/1/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import Foundation
import UIKit

class Game {
    let name: String
    let isDigital: Bool
    let hasBox: Bool
    let isSpecialEdition: Bool
    var photos: [Photo] = []
    let youTubeURL: String?
    let description: String?
    
    init(name: String) {
        self.name = name
        isDigital = false
        hasBox = false
        isSpecialEdition = false
        photos = []
        youTubeURL = nil
        description = nil
    }
}

struct Photo {
    let photo: UIImage?
}
