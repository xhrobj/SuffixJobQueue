//
//  FeedTableViewCell.swift
//  SuffixJobQueue
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    
    static let reuseID = String(describing: FeedTableViewCell.self)
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeIntervalLabel: UILabel!
    
    func updateCell(name: String, timeInterval: String?, color: UIColor?) {
        nameLabel.text = name
        timeIntervalLabel.text = timeInterval
        backgroundColor = color ?? .clear
    }
}
