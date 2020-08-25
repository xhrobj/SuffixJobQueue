//
//  Job.swift
//  SuffixJobQueue
//

import Foundation

struct SuffixArrayCreateJob: Job {
    private let originText: String
    let description: String
       
    
    var timeInterval: Double = Double.greatestFiniteMagnitude
    var status = JobStatus.waiting
    
    let id: JobId
    
    init(id: String, originText: String) {
        self.id = id
        self.description = originText
        self.originText = originText
    }
    
    mutating func start() {
        status = .started(at: Date())
        status = .active
        main()
    }
    
    mutating func main() {
        timeInterval = Profiler.runClosureForTime { [self] in
            _ = self.originText.suffixList
        }
        self.status = .completed(at: Date())
    }
}
