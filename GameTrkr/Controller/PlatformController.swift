//
//  PlatformController.swift
//  GameTrkr
//
//  Created by Sean Foreman on 3/26/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import UIKit
import CoreData

class PlatformController: UIViewController {
    
    @IBOutlet weak var platformTable: UITableView!
    @IBOutlet weak var noPlatformsText: UITextView!
    @IBOutlet weak var addPlatformButton: UIBarButtonItem!
    
    var platforms: [Platform] = []
    var dataController: DataController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        platformTable.dataSource = self
        platformTable.delegate = self
        
        let editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(toggleEditing))
        self.navigationItem.rightBarButtonItem = editButton
        
        let fetchRequest: NSFetchRequest<Platform> = Platform.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            platforms = result
            platformTable.reloadData()
        }
        
        updateEditButton()
        updateEmptyText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        if let indexPath = platformTable.indexPathForSelectedRow {
            platformTable.deselectRow(at: indexPath, animated: false)
            platformTable.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    @objc private func toggleEditing() {
        platformTable.setEditing(!platformTable.isEditing, animated: true)
        navigationItem.rightBarButtonItem?.title = platformTable.isEditing ? "Done" : "Edit"
    }
    
    @IBAction func addTapped(sender: Any) {
        newPlatformAlert()
    }
    
    func addPlatform(title: String) {
        let platform = Platform(context: dataController.viewContext)
        platform.name = title
        platforms.append(platform)
        try? dataController.viewContext.save()
        platformTable.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        updateEditButton()
        updateEmptyText()
        platformTable.reloadData()
    }
    
    func deletePlatform(at indexPath: IndexPath) {
        let platformToDelete = platform(at: indexPath)
        dataController.viewContext.delete(platformToDelete)
        try? dataController.viewContext.save()
        platforms.remove(at: indexPath.row)
        platformTable.deleteRows(at: [indexPath], with: .fade)
        if numberOfPlatforms == 0 {
            setEditing(false, animated: true)
        }
        
        updateEditButton()
        updateEmptyText()
        platformTable.reloadData()
    }
    
    func updateEditButton() {
        navigationItem.rightBarButtonItem?.isEnabled = numberOfPlatforms > 0
    }
    
    func updateEmptyText() {
        if platforms.isEmpty {
            platformTable.isHidden = true
            noPlatformsText.isHidden = false
        } else {
            platformTable.isHidden = false
            noPlatformsText.isHidden = true
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? GamesController {
            if let indexPath = platformTable.indexPathForSelectedRow {
                destinationVC.platform = platform(at: indexPath)
                destinationVC.dataController = dataController
            }
        }
    }
    
}

extension PlatformController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfPlatforms
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlatformCell.defaultReuseIdentifier, for: indexPath) as! PlatformCell
        let iPlatform = platform(at: indexPath)
        
        if let count = iPlatform.games?.count {
            cell.gamesSub.text = "Games: \(count)"
        }
        
        cell.platformName.text = iPlatform.name
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToGamesController", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deletePlatform(at: indexPath)
        default: ()
        }
    }
    
    func platform(at indexPath: IndexPath) -> Platform {
        return platforms[indexPath.row]
    }
    
    var numberOfPlatforms: Int { return platforms.count }
}

