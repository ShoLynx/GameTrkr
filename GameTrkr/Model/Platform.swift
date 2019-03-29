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
    let games: [Games] = []
}

struct Games {
    let name: String
    let isDigital: Bool
    let hasBox: Bool
    let specialEdition: Bool
    //need variable for photo group
    //need variable for YouTube video
    let description: String
}
