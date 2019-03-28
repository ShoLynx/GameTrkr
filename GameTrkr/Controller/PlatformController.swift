//
//  PlatformController.swift
//  GameTrkr
//
//  Created by Sean Foreman on 3/26/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import UIKit
import UIKit

class PlatformController: UITableViewController {
    
    @IBOutlet weak var platformTable: UITableView!
    @IBOutlet weak var noPlatformsLabel: UILabel!
    @IBOutlet weak var addPlatformButton: UIBarButtonItem!
    
    var platforms: [Platform]! = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(toggleEditing))
        self.navigationItem.leftBarButtonItem = editButton
        
        noPlatformsLabel.isHidden = true
        if platforms.isEmpty {
            noPlatformsLabel.isHidden = false
        }
    }
    
    @objc private func toggleEditing() {
        platformTable.setEditing(!platformTable.isEditing, animated: true)
        navigationItem.leftBarButtonItem?.title = platformTable.isEditing ? "Done" : "Edit"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return platforms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlatformCell", for: indexPath) as! PlatformCell
        
        let platform = self.platforms[(indexPath as NSIndexPath).row]
        
        cell.platformName.text = platform.name
        cell.gamesSub.text = "Games: \(platform.games.count)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //segue to selected platform's Games controller
    }
    
}

