//
//  Platform.swift
//  GameTrkr
//
//  Created by Sean Foreman on 3/27/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import Foundation
import UIKit

class Platform {
    let name: String
    var games: [Game] = []
    
    init(name: String) {
        self.name = name
        games = []
    }
}
