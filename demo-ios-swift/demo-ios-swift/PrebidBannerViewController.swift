//
//  PrebidBannerViewController.swift
//  demo-ios-swift
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import GoogleMobileAds
import PrebidMobile
import UIKit
import OptableSDK

private let AD_MANAGER_AD_UNIT_ID = "/21808260008/prebid_demo_app_original_api_banner"
private let PREBID_STORED_IMP = "prebid-demo-banner-320-50"

// MARK: - PrebidBannerViewController
final class PrebidBannerViewController: UIViewController { // Outlets
    @IBOutlet var adPlaceholder: UIView!
    @IBOutlet var loadBannerButton: UIButton!
    @IBOutlet var loadBannerFromCacheButton: UIButton!
    @IBOutlet var clearTargetingCacheButton: UIButton!
    @IBOutlet var targetingOutput: UITextView!

    // PrebidMobile
    private var pbmBannerAdUnit: BannerAdUnit!

    // GoogleMobileAds - GAMBannerView
    private var gamBannerView: AdManagerBannerView!

    // Logging
    private var targetingLog: String? { didSet { updateUILog() } }
    private var witnessLog: String? { didSet { updateUILog() } }
    private var profileLog: String? { didSet { updateUILog() } }
    private var networkLogObserver: (any NSObjectProtocol)?

    override func viewDidLoad() {
        super.viewDidLoad()

        gamBannerView = AdManagerBannerView(adSize: AdSizeBanner)
        gamBannerView.adUnitID = AD_MANAGER_AD_UNIT_ID
        gamBannerView.rootViewController = self
        gamBannerView.delegate = self
        addBannerViewToView(gamBannerView)
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
private extension PrebidBannerViewController {
    func loadBanner(_ optableTargeting: OptableTargeting? = nil) {
        loadPrebidAd(optableTargeting)
        witness()
        profile()
    }

    func loadPrebidAd(_ optableTargeting: OptableTargeting? = nil) {
        setOptableTargetingToPrebid(optableTargeting)

        let adRequest = AdManagerRequest()
        adRequest.customTargeting = optableTargeting?.gamTargetingKeywords as? [String: Any]
        
        pbmBannerAdUnit = BannerAdUnit(configId: PREBID_STORED_IMP, size: .init(width: 320, height: 50))
        pbmBannerAdUnit.fetchDemand(adObject: adRequest) { [weak self] status in
            print("[PrebidMobile]:fetchDemand(adObject:): \(status.name())")
            self?.loadGAMAd(adRequest)
        }
    }

    func setOptableTargetingToPrebid(_ optableTargeting: OptableTargeting? = nil) {
        guard
            let optableTargeting,
            let ortb2 = optableTargeting.ortb2
        else {
            PrebidMobile.Targeting.shared.setGlobalORTBConfig(nil)
            return
        }

        PrebidMobile.Targeting.shared.setGlobalORTBConfig(ortb2)
    }

    func loadGAMAd(_ request: AdManagerRequest) {
        gamBannerView.load(request)
    }

    func witness() {
        do {
            try OPTABLE!.witness(
                event: "PrebidBannerViewController.loadBannerClicked",
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
extension PrebidBannerViewController: GoogleMobileAds.BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GoogleMobileAds.BannerView) {
        AdViewUtils.findPrebidCreativeSize(bannerView, success: { size in
            guard let bannerView = bannerView as? AdManagerBannerView else { return }
            bannerView.resize(adSizeFor(cgSize: size))
        }, failure: { error in
            print("[PrebidMobile SDK] Error finding creative size: \(error)")
        })
    }

    func bannerView(
        _ bannerView: GoogleMobileAds.BannerView,
        didFailToReceiveAdWithError error: any Error
    ) {
        print("[PrebidBannerViewController] Failed to receive ad: \(error)")
    }
}

// MARK: - Helpers
private extension PrebidBannerViewController {
    func addBannerViewToView(_ bannerView: AdManagerBannerView) {
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
private extension PrebidBannerViewController {
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
