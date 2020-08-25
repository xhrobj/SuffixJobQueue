//
//  JobScheduler.swift
//  SuffixJobQueue
//

import Foundation
import Combine

struct JobResult {
    let name: String
}

final class JobScheduler {
    
    @Published var result: [Job] = []
    
    private var delay: Double? = nil
    
    private let jobQueue = JobQueue()
    private let isolatedQueue = DispatchQueue(label: "isolated", attributes: .concurrent)
    private let executeQueue = DispatchQueue.global()
    private var bag = Set<AnyCancellable>()
    
    private var isStopped = true
    
    private var isActive: Bool {
        get {
            isolatedQueue.sync {
                !isStopped
            }
        }
        set {
            isolatedQueue.async(flags: .barrier) {
                self.isStopped = !newValue
            }
        }
    }
    
    func setDelay(seconds delay: Double?) {
        self.delay = delay
    }
    
    func cancel(jobId: JobId) {
        _ = self.jobQueue.remove(with: jobId)
    }
    
    func cancelAll() {
        self.jobQueue.clear()
    }
    
    func schedule(job: Job) {
        self.jobQueue.enqueue(job: job)
    }
    
    func start() {
        if isActive {
            return
        }
        isActive = true
        main()
    }
    
    func stop() {
        isActive = false
    }
    
    private func main() {
        var publishers: [AnyPublisher<Job, Never>] =  []
        while isActive, let job = jobQueue.poll() {
            var publisher = promisifiedAsyncExecutor(inputJob: job)
            if let delay = delay {
                publisher = publisher
                    .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
                    .eraseToAnyPublisher()
            }
            publishers.append(publisher)
        }
        publishers.publisher
            .flatMap { $0 }
            .collect()
            .receive(on: DispatchQueue.main)
            .sink {
                self.result = $0
                self.stop()
        }
        .store(in: &bag)
    }
    
    private func promisifiedAsyncExecutor(inputJob: Job) -> AnyPublisher<Job, Never> {
        Future<Job, Never> { promise in
            self.asyncExecutor(inputJob: inputJob) { outputJob in
                promise(.success(outputJob))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func asyncExecutor(inputJob: Job, completion: @escaping ((Job) -> Void)) {
        executeQueue.async {
            var outputJob = inputJob
            outputJob.start()
            completion(outputJob)
        }
    }
}

