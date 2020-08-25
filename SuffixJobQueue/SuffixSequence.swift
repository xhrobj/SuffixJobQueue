//
//  SuffixIterator.swift
//  SuffixArrayExample
//
//

import Foundation

struct SuffixIterator: IteratorProtocol {
    private let text: String
    private var currentIndex: String.Index
    
    init(text: String) {
        self.text = text
        currentIndex = text.endIndex
    }
    
    mutating func next() -> String? {
        guard let nextIndex = text.index(currentIndex, offsetBy: -1, limitedBy: text.startIndex) else {
            return nil
        }
        currentIndex = nextIndex
        return "\(text.suffix(from: currentIndex))"
    }
}

struct SuffixSequence: Sequence {
    private let text: String
    
    init(text: String) {
        self.text = text
    }
    
    func makeIterator() -> SuffixIterator {
        return SuffixIterator(text: text)
    }
}
