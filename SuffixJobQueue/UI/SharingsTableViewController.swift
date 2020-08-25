//
//  SharingsTableViewController.swift
//  SuffixJobQueue
//

import UIKit
import Combine

class SharingsTableViewController: UITableViewController {

    private var sharings: [String]? = nil {
        didSet {
            tableView.reloadData()
        }
    }
    private var notificationCancel: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
        sharings = UserDefaults.currentGroup?.sharingList
        
        notificationCancel = NotificationCenter.Publisher(center: .default, name: UIApplication.didBecomeActiveNotification)
            .sink { _ in
                self.sharings = UserDefaults.currentGroup?.sharingList
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sharings?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SharingCell", for: indexPath)
        if let sharings = sharings {
            cell.textLabel?.text = sharings[indexPath.row]
        }
        
        return cell
    }
}
