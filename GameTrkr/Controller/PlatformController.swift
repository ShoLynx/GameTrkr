//
//  PlatformController.swift
//  GameTrkr
//
//  Created by Sean Foreman on 3/26/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import UIKit

class PlatformController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var platformTable: UITableView!
    @IBOutlet weak var noPlatformsText: UITextView!
    @IBOutlet weak var addPlatformButton: UIBarButtonItem!
    
    var platforms: [Platform] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(toggleEditing))
        self.navigationItem.rightBarButtonItem = editButton
        
        noPlatformsText.isHidden = true
        if platforms.isEmpty {
            platformTable.isHidden = true
            noPlatformsText.isHidden = false
        }
        updateEditButton()
    }
    
    @objc private func toggleEditing() {
        platformTable.setEditing(!platformTable.isEditing, animated: true)
        navigationItem.rightBarButtonItem?.title = platformTable.isEditing ? "Done" : "Edit"
    }
    
    @IBAction func addTapped(sender: Any) {
        newPlatformAlert()
    }
    
    func addPlatform(title: String) {
        let platform = Platform(name: title)
        platforms.append(platform)
        platformTable.insertRows(at: [IndexPath(row: numberOfPlatforms - 1, section: 0)], with: .fade)
        updateEditButton()
    }
    
    func deletePlatform(at indexPath: IndexPath) {
        platforms.remove(at: indexPath.row)
        platformTable.deleteRows(at: [indexPath], with: .fade)
        if numberOfPlatforms == 0 {
            setEditing(false, animated: true)
        }
        updateEditButton()
    }
    
    func updateEditButton() {
        navigationItem.rightBarButtonItem?.isEnabled = numberOfPlatforms > 0
    }
    
    func newPlatformAlert() {
        let alert = UIAlertController(title: "New Platform", message: "Enter a name for this platform.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] action in
            if let name = alert.textFields?.first?.text {
                self?.addPlatform(title: name)
            }
        }
        confirmAction.isEnabled = false
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { (notif) in
                if let text = textField.text, !text.isEmpty {
                    confirmAction.isEnabled = true
                } else {
                    confirmAction.isEnabled = false
                }
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfPlatforms
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlatformCell.defaultReuseIdentifier, for: indexPath) as! PlatformCell
        let iPlatform = platform(at: indexPath)
        
        cell.platformName.text = iPlatform.name
        cell.gamesSub.text = "Games: \(iPlatform.games.count)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //segue to selected platform's Games controller
    }
    
    func platform(at indexPath: IndexPath) -> Platform {
        return platforms[indexPath.row]
    }
    
    var numberOfPlatforms: Int { return platforms.count }
}

