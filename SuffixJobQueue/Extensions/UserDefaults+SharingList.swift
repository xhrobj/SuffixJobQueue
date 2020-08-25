//
//  UserDefaults+SuffixList.swift
//  SuffixJobQueue
//

import Foundation

extension UserDefaults {
    static var currentGroup: UserDefaults? {
        UserDefaults(suiteName: "group.ru.mishe1.SuffixJobQueue")
    }
    
    var sharingList: [String]? {
        self.object(forKey: "sharingList") as? [String]
    }
}
