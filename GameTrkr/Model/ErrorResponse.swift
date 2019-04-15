//
//  ErrorResponse.swift
//  GameTrkr
//
//  Created by Sean Foreman on 4/14/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import Foundation

struct ErrorResponse: Codable {
    let errors: [Errors]
    let code: Int?
    let message: String?
}

struct Errors: Codable {
    let domain: String?
    let reason: String?
    let message: String?
    let locationType: String?
    let location: String?
}

extension ErrorResponse: LocalizedError {
    var errorMessage: String? {
        return message
    }
}
