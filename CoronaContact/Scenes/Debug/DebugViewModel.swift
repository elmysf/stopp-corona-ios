//
// DebugViewModel.swift
// CoronaContact
//

import UIKit
import Resolver

// swiftlint:disable:line_length
let simulatedKey = "MIGJAoGBAMvH7iUvrAODD2NwS7ZRRFrr31sJdJHpvhFaR4EZt6lIZvXFzWnqdvRCg3VmpdsJtqzsZEzsFhINXSfNpXAFj2Sb67Yrs4kWhVtEXq" +
        "I0wuYVH0qsCvfnqGTqYiyp+LzD66FkmCnVvnFxoTaQOB3K0B3DPEkgAlmLQdSgYWfIj1Z3AgMBAAE="

// swiftlint:enable:line_length

class DebugViewModel: ViewModel {
    weak var viewController: DebugViewController?
    weak var coordinator: DebugCoordinator?

    @Injected private var dba: DatabaseService
    @Injected private var crypto: CryptoService
    @Injected private var network: NetworkService
    @Injected private var notificationService: NotificationService
    @available(iOS 13.5, *)
    @Injected private var exposureManager: ExposureManager


    var timer: Timer?
    var numberOfContacts = 0

    init(coordintator: DebugCoordinator) {
        self.coordinator = coordintator
    }

    func close() {
        coordinator?.finish(animated: true)
    }

    func shareLog() {
        coordinator?.shareLog()
    }

    func resetLog() {
        LoggingService.deleteLogFile()
    }

    func addHandShakes() {
        var date = Date()
        let calendar = Calendar.current

        for _ in 1...3 {
            let rco = RemoteContact(name: "1234", key: Data(base64Encoded: simulatedKey)!, timestamp: date)
            _ = dba.saveContact(rco)
            date = calendar.date(byAdding: .hour, value: -2, to: date)!
        }
    }

    func addRedInfectionMessage() {
        let date = Calendar.current.date(byAdding: .hour, value: -2, to: Date())!
        dba.saveIncomingInfectionWarning(uuid: UUID().uuidString, warningType: .red, contactTimeStamp: date)
    }

    func addYellowInfectionMessage() {
        let date = Calendar.current.date(byAdding: .hour, value: -2, to: Date())!
        dba.saveIncomingInfectionWarning(uuid: UUID().uuidString, warningType: .yellow, contactTimeStamp: date)
    }

    func scheduleTestNotifications() {
        notificationService.showTestNotifications()
    }

    func attestSickness() {
        dba.saveSicknessState(true)
    }

    func exposeDiagnosesKeys(test: Bool = false) {
        if #available(iOS 13.5, *) {
            if test {
                exposureManager.getTestDiagnosisKeys { error in }
            } else {
                exposureManager.getDiagnosisKeys { error in}
            }
        }
    }

}
