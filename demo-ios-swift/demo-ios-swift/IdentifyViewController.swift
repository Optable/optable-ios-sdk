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
import CryptoKit

// MARK: - IdentifyViewController
class IdentifyViewController: UIViewController {
    // Outlets
    @IBOutlet var identifyInput: UITextField!
    @IBOutlet var identifyButton: UIButton!
    @IBOutlet var identifyOutput: UITextView!
    @IBOutlet var identifyURLInput: UITextField!

    // Logging
    private var networkLogObserver: (any NSObjectProtocol)?

    override func viewDidLoad() {
        super.viewDidLoad()
        identifyInput.delegate = self
        identifyURLInput.delegate = self

        // A link like the ones in a newsletter Email, carrying the SHA256 of the reader's Email address
        identifyURLInput.text = "https://example.com/newsletter?oeid=\(sha256Email("some.email@address.com"))"
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
        
        // If the user gives consent to be tracked - IDFA will be added
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

    // dispatchIdentifyHashed() sends the Email as a SHA256 hashed in the app, as you would with a hash from your own backend.
    // `.hem` sends it as given; passing a hash to `.emailAddress` would hash it a second time.
    @IBAction func dispatchIdentifyHashed(_ sender: UIButton) {
        view.endEditing(true)

        do {
            let email = identifyInput.text ?? ""
            try OPTABLE!.identify([.hem(sha256Email(email))]) { result in
                switch result {
                case .success:
                    print("[OptableSDK] ✅ Success on /identify API call with a hashed Email")
                case let .failure(error):
                    print("[OptableSDK] 🚫 Error on /identify API call: \(error)")
                }
            }
        } catch {
            print("[OptableSDK] 🚫 Exception on /identify API call: \(error)")
            identifyOutput.text += "🚫 EXCEPTION: \(error)"
        }
    }

    // dispatchIdentifyFromURL() passes a link to tryIdentifyFromURL(), as you would from a universal link handler.
    // If the link has an `oeid` query parameter holding a SHA256, the SDK calls /identify with it; otherwise it does nothing.
    @IBAction func dispatchIdentifyFromURL(_ sender: UIButton) {
        view.endEditing(true)

        do {
            try OPTABLE!.tryIdentifyFromURL(identifyURLInput.text ?? "")
        } catch {
            print("[OptableSDK] 🚫 Exception on tryIdentifyFromURL: \(error)")
            identifyOutput.text += "🚫 EXCEPTION: \(error)"
        }
    }
}

// MARK: - Helpers
private extension IdentifyViewController {
    /// SHA256 of the Email, normalized the way the SDK does it for `.emailAddress`: whitespace removed, lowercased.
    func sha256Email(_ email: String) -> String {
        let normalized = email.components(separatedBy: .whitespacesAndNewlines).joined().lowercased()
        return SHA256.hash(data: Data(normalized.utf8)).map { String(format: "%02x", $0) }.joined()
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
