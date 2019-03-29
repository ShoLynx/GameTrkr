//
//  Cell.swift
//  GameTrkr
//
//  Created by Sean Foreman on 3/28/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import Foundation
import UIKit

protocol Cell {
    static var defaultReuseIdentifier: String {
        get
    }
}

extension Cell {
    static var defaultReuseIdentifier: String {
        return "\(self)"
    }
}
