//
//  FeedViewController.swift
//  SuffixJobQueue
//

import UIKit
import Combine

struct SuffixTestResult {
    let text: String
    let timeInterval: String
}

class FeedViewController: UIViewController {
    
    enum MinMaxState: Int, Comparable {
        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
        
        case none, max, min
        
        var color: UIColor {
            switch self {
            case .min:
                return UIColor.green
            case .max:
                return UIColor.red
            default:
                return UIColor.clear
            }
        }
    }
    
    final class CellData {
        let title: String
        let timeInterval: Double
        var minMax: MinMaxState
        
        init(title: String, timeInterval: Double, minMax: MinMaxState) {
            self.title = title
            self.timeInterval = timeInterval
            self.minMax = minMax
        }
    }
    
    @IBOutlet weak var testTypeSegment: UISegmentedControl!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    
    private let scheduler = JobScheduler()
    private var subscriber: AnyCancellable?
    private var notificationCancel: AnyCancellable?
    
    private var data: [CellData] = [] {
        didSet {
            feedTableView.reloadData()
        }
    }
    
    private var sharings: [String]? = nil
    
    private lazy var timeNumberFormatter: NumberFormatter = {
        var formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        let digits = 6
        formatter.minimumFractionDigits = digits
        formatter.maximumFractionDigits = digits
        return formatter
    }()
    
    
    @IBOutlet weak var feedTableView: UITableView!
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustResultLabel()
        feedTableView.allowsSelection = false
        sharings = UserDefaults.currentGroup?.sharingList
        
        notificationCancel = NotificationCenter.Publisher(center: .default, name: UIApplication.didBecomeActiveNotification)
            .sink { _ in
                self.sharings = UserDefaults.currentGroup?.sharingList
        }
        
        subscriber = scheduler.$result.sink { [weak self] jobList in
            self?.setControlsEnabled(true)
            guard let self = self else {
                return
            }
            self.data = jobList.map {
                CellData(title: $0.description, timeInterval: $0.timeInterval, minMax: .none)
            }
            if self.data.count > 1 {
                 self.updateMinMax()
            }
            self.adjustResultLabel()
        }
    }
    
    @IBAction func startTest(_ sender: UIButton) {
        guard let textArray = sharings else {
            return
        }
        setControlsEnabled(false)
        if testTypeSegment.selectedSegmentIndex == 0 {
            createTest(textArray: textArray)
        } else {
            accessTest(textArray: textArray)
        }
    }
    
    @IBAction func changeTestTypeSegment(_ sender: UISegmentedControl) {
        data = []
        adjustResultLabel()
    }
}

private extension FeedViewController {
    
    private func createTest(textArray: [String]) {
        scheduler.setDelay(seconds: 1)
        DispatchQueue.global().async { [weak self] in
            textArray.forEach {
                let job = SuffixArrayCreateJob(id: UUID().uuidString, originText: $0)
                self?.scheduler.schedule(job: job)
            }
            self?.scheduler.start()
        }
    }
    
    private func accessTest(textArray: [String]) {
        scheduler.setDelay(seconds: nil)
        DispatchQueue.global().async { [weak self] in
            textArray.forEach {
                let job = SuffixArrayAccessJob(id: UUID().uuidString, originText: $0)
                self?.scheduler.schedule(job: job)
            }
            self?.scheduler.start()
        }
    }
    
    private func adjustResultLabel() {
        resultLabel.text = data.isEmpty ? "" : "Result Times"
    }
    
    private func setControlsEnabled(_ enabled: Bool) {
        startButton.isEnabled = enabled
        if enabled {
            spinner.stopAnimating()
        } else {
            spinner.startAnimating()
        }
    }
    
    private func formattedTime(_ time: TimeInterval) -> String? {
        return timeNumberFormatter.string(from: time as NSNumber)
    }
    
    private func updateMinMax() {
        self.data.forEach { $0.minMax = .none }
        let minItem = self.data.min(by: { $0.timeInterval < $1.timeInterval })
        let maxItem = self.data.max(by: { $0.timeInterval < $1.timeInterval })
        minItem?.minMax = .min
        maxItem?.minMax = .max
    }
}

extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = feedTableView.dequeueReusableCell(withIdentifier: FeedTableViewCell.reuseID, for: indexPath) as? FeedTableViewCell
        guard let feedCell = cell else { return UITableViewCell() }
        
        let cellData = data[indexPath.row]
        feedCell.updateCell(
            name: cellData.title,
            timeInterval: formattedTime(cellData.timeInterval),
            color: cellData.minMax.color
        )
        
        return feedCell
    }
}
