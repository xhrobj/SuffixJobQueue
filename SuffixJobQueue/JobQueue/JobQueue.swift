//
//  JobQueue.swift
//  SuffixJobQueue
//

import Foundation

final class JobQueue {
    
    private var rawJobList: [Job] = []
    
    private let isolatedQueue = DispatchQueue(label: "isolated", attributes: .concurrent)
    
    private(set) var jobList: [Job] {
        get {
           isolatedQueue.sync() {
                self.rawJobList
            }
        }
        set {
            isolatedQueue.async(flags: .barrier) {
                self.rawJobList = newValue
            }
        }
    }
    
    private func safeAppend(_ job: Job) {
        isolatedQueue.async(flags: .barrier) {
            self.rawJobList.append(job)
        }
    }
    
    private func safeRemove(at index: Int) -> Job {
        isolatedQueue.sync(flags: .barrier) {
            self.rawJobList.remove(at: index)
        }
    }
    
    func clear() {
        jobList = []
    }
    
    func remove(with jobId: JobId) -> Job? {
        if let index = jobList.firstIndex(where: { $0.id == jobId }) {
            return safeRemove(at: index)
        }
        return nil
    }
    
    func enqueue(job: Job) {
        if jobList.first(where: { $0.id == job.id }) == nil {
            safeAppend(job)
        }
    }
    
    func poll() -> Job? {
        guard !jobList.isEmpty else {
            return nil
        }
        return safeRemove(at: 0)
    }
}

