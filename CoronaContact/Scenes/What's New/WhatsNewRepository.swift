//
//  WhatsNewRepository.swift
//  CoronaContact
//

import UIKit

typealias AppHistoryItem = String
typealias AppVersionHistory = [AppVersion: AppHistoryItem]

var appVersionHistory: AppVersionHistory = [
    "2.0": "We now use Apple's Exposure Notification framework :)",
]
var firstHistoryItemVersion: AppVersion = {
    appVersionHistory.keys.sorted(by: <).first!
}()

class WhatsNewRepository {
    
    var appInfo: AppInfo = UIApplication.shared

    @Persisted(userDefaultsKey: "lastWhatsNewShown", notificationName: .init("lastWhatsNewShownDidChange"), defaultValue: .notPreviouslyInstalled)
    var lastWhatsNewShown: AppVersion
    
    lazy var currentAppVersion: AppVersion = {
        appInfo.appVersion
    }()
    
    var newHistoryItems: [AppHistoryItem] {
        appVersionHistory
            .filter { $0.key > lastWhatsNewShown }
            .sorted(by: ascendingKeys)
            .map { $0.value }
    }
    
    var isWhatsNewAvailable: Bool {
        
        // for the first upgrade to version 2.0 we cannot detect if it is a new
        // install or an upgrade. We have to show the history item:
        #warning("Remove this check for the first update after 2.0")
        if lastWhatsNewShown == .notPreviouslyInstalled && currentAppVersion == firstHistoryItemVersion {
            return true
        }
        
        // Fresh installs should not show app history:
        if lastWhatsNewShown == .notPreviouslyInstalled {
            lastWhatsNewShown = currentAppVersion
            return false
        }
        return appVersionHistory.contains { $0.key > lastWhatsNewShown }
    }
    
    func currentWhatsNewShown() {
        lastWhatsNewShown = currentAppVersion
    }
}

private func ascendingKeys<K, V>(_ lhs: (key: K, value: V), _ rhs: (key: K, value: V)) -> Bool
where K: Comparable {
    lhs.key < rhs.key
}
