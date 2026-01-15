//
//  GAMBannerViewController.swift
//  demo-ios-swift
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import GoogleMobileAds
import OptableSDK
import UIKit

private let AD_MANAGER_AD_UNIT_ID = "/22081946781/ios-sdk-demo/mobile-leaderboard"

// MARK: - GAMBannerViewController
final class GAMBannerViewController: UIViewController {
    // Outlets
    @IBOutlet var adPlaceholder: UIView!
    @IBOutlet var loadBannerButton: UIButton!
    @IBOutlet var loadBannerFromCacheButton: UIButton!
    @IBOutlet var clearTargetingCacheButton: UIButton!
    @IBOutlet var targetingOutput: UITextView!

    // GoogleMobileAds - GADBannerView
    var gadBannerView: BannerView!

    // Logging
    private var targetingLog: String? { didSet { updateUILog() } }
    private var witnessLog: String? { didSet { updateUILog() } }
    private var profileLog: String? { didSet { updateUILog() } }
    private var networkLogObserver: (any NSObjectProtocol)?

    override func viewDidLoad() {
        super.viewDidLoad()

        gadBannerView = BannerView(adSize: AdSizeBanner)
        gadBannerView.adUnitID = AD_MANAGER_AD_UNIT_ID
        gadBannerView.rootViewController = self
        gadBannerView.delegate = self
        addBannerViewToView(gadBannerView)
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
    @IBAction func loadBannerWithTargeting(_ sender: UIButton) {
        do {
            try OPTABLE!.targeting { [weak self] result in
                switch result {
                case let .success(optableTargeting):
                    print("[OptableSDK] ✅ Success on /targeting API call: \(optableTargeting)")
                    self?.loadBanner(optableTargeting)

                case let .failure(error):
                    print("[OptableSDK] 🚫 Error on /targeting API call: \(error)")
                    self?.loadBanner()
                }
            }
        } catch {
            print("[OptableSDK] 🚫 Exception on /targeting API call: \(error)")
            targetingLog = "🚫 EXCEPTION: \(error)"
        }
    }

    @IBAction func loadBannerWithTargetingFromCache(_ sender: UIButton) {
        if let cachedOptableTargeting = OPTABLE!.targetingFromCache() {
            print("[OptableSDK] ✅ Cached targeting values found: \(cachedOptableTargeting)")
            loadBanner(cachedOptableTargeting)
        } else {
            print("[OptableSDK] ℹ️ Cache empty")
            loadBanner()
        }
    }

    @IBAction func clearTargetingCache(_ sender: UIButton) {
        targetingOutput.text = "🧹 Cleared local targeting cache.\n"
        OPTABLE!.targetingClearCache()
    }
}

// MARK: - Private
private extension GAMBannerViewController {
    func loadBanner(_ optableTargeting: OptableTargeting? = nil) {
        loadGADAd(optableTargeting)
        witness()
        profile()
    }

    func loadGADAd(_ optableTargeting: OptableTargeting? = nil) {
        let adRequest = AdManagerRequest()
        adRequest.customTargeting = optableTargeting?.gamTargetingKeywords as? [String: Any]
        gadBannerView.load(adRequest)
    }

    func witness() {
        do {
            try OPTABLE!.witness(
                event: "GAMBannerViewController.loadBannerClicked",
                properties: ["example": "value"]
            ) { result in
                switch result {
                case .success:
                    print("[OptableSDK] ✅ Success on /witness API call")
                case let .failure(error):
                    print("[OptableSDK] 🚫 Error on /witness API call: \(error)")
                }
            }
        } catch {
            print("[OptableSDK] 🚫 Exception on /witness API call: \(error)")
            witnessLog = "🚫 EXCEPTION: \(error)"
        }
    }

    func profile() {
        do {
            try OPTABLE!.profile(
                traits: ["example": "value", "anotherExample": 123, "thirdExample": true]
            ) { result in
                switch result {
                case .success:
                    print("[OptableSDK] ✅ Success on /profile API call")
                case let .failure(error):
                    print("[OptableSDK] 🚫 Error on /profile API call: \(error)")
                }
            }
        } catch {
            print("[OptableSDK] 🚫 Exception on /profile API call: \(error)")
            profileLog = "🚫 EXCEPTION: \(error)"
        }
    }
}

// MARK: - GoogleMobileAds.BannerViewDelegate
extension GAMBannerViewController: GoogleMobileAds.BannerViewDelegate {
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: any Error) {
        print("[GAMBannerViewController] Failed to receive ad: \(error)")
    }
}

// MARK: - Helpers
private extension GAMBannerViewController {
    func addBannerViewToView(_ bannerView: BannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        adPlaceholder.addSubview(bannerView)

        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: adPlaceholder.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: adPlaceholder.centerYAnchor),
        ])
    }

    func updateUILog() {
        targetingOutput.text = [targetingLog, witnessLog, profileLog].compactMap({ $0 }).joined(separator: "\n\n")
    }
}

// MARK: - Logging
private extension GAMBannerViewController {
    /// Setups observation for URLRequest/URLResponse logging
    func startObservingNetworkLogs() {
        networkLogObserver = NotificationCenter.default
            .addObserver(forName: .HTTPURLLogUpdated, object: nil, queue: .main, using: { [weak self] notification in
                if let logEntry = notification.userInfo?["data"] as? HTTPURLLogEntry,
                   logEntry.request.url?.absoluteString.contains("/targeting") == true {
                    self?.targetingLog = logEntry.debugDescription
                    print(logEntry.response == nil ? logEntry.requestDebugDescription : logEntry.responseDebugDescription)
                }

                if let logEntry = notification.userInfo?["data"] as? HTTPURLLogEntry,
                   logEntry.request.url?.absoluteString.contains("/witness") == true {
                    self?.witnessLog = logEntry.debugDescription
                    print(logEntry.response == nil ? logEntry.requestDebugDescription : logEntry.responseDebugDescription)
                }

                if let logEntry = notification.userInfo?["data"] as? HTTPURLLogEntry,
                   logEntry.request.url?.absoluteString.contains("/profile") == true {
                    self?.profileLog = logEntry.debugDescription
                    print(logEntry.response == nil ? logEntry.requestDebugDescription : logEntry.responseDebugDescription)
                }
            })
    }

    func stopObservingNetworkLogs() {
        guard let networkLogObserver else { return }
        NotificationCenter.default.removeObserver(networkLogObserver)
    }
}
