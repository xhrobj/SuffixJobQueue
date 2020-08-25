//
//  String+Extensions.swift
//  SuffixJobQueue
//
//

import Foundation

extension String {
    var suffixList: [String] {
        self.split(separator: " ")
            .reduce([[String]]()) { (accumulator, word) -> [[String]] in
                let sequence = SuffixSequence(text: String(word))
                let result = Array<String>(sequence)
                
                return accumulator + [result]
            }
            .flatMap { $0 }
    }
}
