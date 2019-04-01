//
//  Platform.swift
//  GameTrkr
//
//  Created by Sean Foreman on 3/27/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import Foundation

struct Platform {
    let name: String
    let games: [Game] = []
}

struct Game {
    let name: String
    let isDigital: Bool
    let hasBox: Bool
    let isSpecialEdition: Bool
    //need variable for photo group
    let photos: [Photo]?
    //need variable for YouTube video
    let youTubeURL: String?
    let description: String?
}

struct Photo {
    //need variable fo
}
