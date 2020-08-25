//
//  Job.swift
//  SuffixJobQueue
//

import Foundation

typealias JobId = String
typealias Action = () -> Void

enum JobStatus: Equatable {
    case waiting
    case started(at: Date)
    case active
    case completed(at: Date)
    case paused
    
    public var isActive: Bool {
        switch self {
        case .active:
            return true
        default:
            return false
        }
    }
}

protocol Job {
    var id: JobId { get }
    var description: String { get }
    var status: JobStatus { get }
    var timeInterval: TimeInterval { get }
    mutating func start()
    mutating func main()
}
