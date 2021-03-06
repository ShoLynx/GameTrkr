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
    
    //  MARK: Class Setup
    
    @IBOutlet weak var platformTable: UITableView!
    @IBOutlet weak var noPlatformsText: UITextView!
    @IBOutlet weak var addPlatformButton: UIBarButtonItem!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Platform>!
    
    //  MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set table datasource and delegate as Platform Controller
        platformTable.dataSource = self
        platformTable.delegate = self
        
        //Create an edit toggle for the right navigation button
        let editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(toggleEditing))
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        //Set up FRC at viewDidAppear to accomodate for reenabling FRC when dismissing other view controllers.
        setupFetchedResultsController()
        
        if let indexPath = platformTable.indexPathForSelectedRow {
            platformTable.deselectRow(at: indexPath, animated: false)
            platformTable.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Relinquish FRC for the next viewable view controller.
        fetchedResultsController = nil
    }
    
    //  MARK: IBActions and Class Functions
    
    @IBAction func addTapped(sender: Any) {
        newPlatformAlert()
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Platform> = Platform.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "platforms")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        updateEmptyText()
        updateEditButton()
    }
    
    @objc private func toggleEditing() {
        platformTable.setEditing(!platformTable.isEditing, animated: true)
        navigationItem.rightBarButtonItem?.title = platformTable.isEditing ? "Done" : "Edit"
    }
    
    func addPlatform(title: String) {
        let platform = Platform(context: dataController.viewContext)
        platform.name = title
        try? dataController.viewContext.save()
        platformTable.reloadData()
        updateEmptyText()
        print("\(platform.name!) has been added successfully.")
    }
    
    func deletePlatform(at indexPath: IndexPath) {
        let platformToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(platformToDelete)
        try? dataController.viewContext.save()
        platformTable.reloadData()
        updateEmptyText()
        print("The platform has been deleted successfully.")
    }
    
    func updateEditButton() {
        //Disable the Edit button if there are no platforms in the table.  Must be applied to all functions that affect number of Platforms.
        if let sections = fetchedResultsController.sections {
            navigationItem.rightBarButtonItem?.isEnabled = sections[0].numberOfObjects > 0
        }
    }
    
    func updateEmptyText() {
        //Hides the table and displays instruction text when there are no platforms in the table.  Must be applied to all functions that affect number of Platforms.
        if let sections = fetchedResultsController.sections {
            if sections[0].numberOfObjects > 0 {
                platformTable.isHidden = false
                noPlatformsText.isHidden = true
            } else {
                platformTable.isHidden = true
                noPlatformsText.isHidden = false
            }
        }
    }
    
    func newPlatformAlert() {
        //Displays an alert view with a text field allowing users to add a platform to the table.
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
                destinationVC.platform = fetchedResultsController.object(at: indexPath)
                destinationVC.dataController = dataController
            }
        }
    }
    
}

    //  MARK: Class extension - Protocol list and delegate rules.

extension PlatformController: UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlatformCell.defaultReuseIdentifier, for: indexPath) as! PlatformCell
        let iPlatform = fetchedResultsController.object(at: indexPath)
        
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        platformTable.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        platformTable.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            platformTable.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            platformTable.deleteRows(at: [indexPath!], with: .fade)
        default:
            break
        }
    }

}

