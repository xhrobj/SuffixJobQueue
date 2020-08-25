//
//  ShareViewController.swift
//  Safari
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        let userDefaults = UserDefaults(suiteName: "group.ru.mishe1.SuffixJobQueue")
        var array = userDefaults?.object(forKey: "sharingList") as? [String] ?? []
        array.append(contentText)
        userDefaults?.set(array, forKey: "sharingList")
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
