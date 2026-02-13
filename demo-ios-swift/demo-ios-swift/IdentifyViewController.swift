//
//  IdentifyViewController.swift
//  demo-ios-swift
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import OptableSDK
import UIKit
import AppTrackingTransparency

// MARK: - IdentifyViewController
class IdentifyViewController: UIViewController {
    // Outlets
    @IBOutlet var identifyInput: UITextField!
    @IBOutlet var identifyButton: UIButton!
    @IBOutlet var identifyOutput: UITextView!

    // Logging
    private var networkLogObserver: (any NSObjectProtocol)?

    override func viewDidLoad() {
        super.viewDidLoad()
        identifyInput.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startObservingNetworkLogs()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingNetworkLogs()
    }

    // MARK: Actions
    // dispatchIdentify() is the action invoked on a click on the "Identify" UIButton in our demo app.
    // It initiates a call to the OptableSDK.identify() API and prints debugging information to the UI and debug console.
    @IBAction func dispatchIdentify(_ sender: UIButton) {
        view.endEditing(true)
        
        // If еру user gives consent to be tracked - IDFA will be added
        // automatically to the list of identifiers,
        // either in the `identify` or `targeting` calls
        ATTrackingManager.requestTrackingAuthorization { [self] _ in
            DispatchQueue.main.async {
                do {
                    let email = self.identifyInput.text ?? ""
                    let optableIdentifiers: [OptableIdentifier] = [
                        .emailAddress(email),
                        .phoneNumber("+1234567890"),
                        .custom(nil, "new-custom.ABC"),
                        .custom(9, "custom-9-id")
                    ]
                    
                    try OPTABLE!.identify(optableIdentifiers) { result in
                        switch result {
                        case .success:
                            print("[OptableSDK] ✅ Success on /identify API call")
                        case let .failure(error):
                            print("[OptableSDK] 🚫 Error on /identify API call: \(error)")
                        }
                    }
                    
                } catch {
                    print("[OptableSDK] 🚫 Exception on /identify API call: \(error)")
                    self.identifyOutput.text += "🚫 EXCEPTION: \(error)"
                }
            }
        }
        
    }
}

// MARK: - UITextFieldDelegate
extension IdentifyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

// MARK: - Logging
private extension IdentifyViewController {
    /// Setups observation for URLRequest/URLResponse logging
    func startObservingNetworkLogs() {
        networkLogObserver = NotificationCenter.default
            .addObserver(forName: .HTTPURLLogUpdated, object: nil, queue: .main, using: { [weak self] notification in
                if let logEntry = notification.userInfo?["data"] as? HTTPURLLogEntry,
                   logEntry.request.url?.absoluteString.contains("/identify") == true {
                    self?.identifyOutput.text = logEntry.debugDescription
                    print(logEntry.response == nil ? logEntry.requestDebugDescription : logEntry.responseDebugDescription)
                }
            })
    }

    func stopObservingNetworkLogs() {
        guard let networkLogObserver else { return }
        NotificationCenter.default.removeObserver(networkLogObserver)
    }
}
