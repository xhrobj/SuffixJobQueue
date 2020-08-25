//
//  Job.swift
//  SuffixJobQueue
//

import Foundation

struct SuffixArrayAccessJob: Job {
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
        let suffixArray = originText.suffixList
        timeInterval = Profiler.runClosureForTime {
            _ = suffixArray.last
        }
        self.status = .completed(at: Date())
    }
}
