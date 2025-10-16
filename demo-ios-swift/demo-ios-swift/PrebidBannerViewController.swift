//
//  PrebidBannerViewController.swift
//  demo-ios-swift
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import UIKit
import PrebidMobile
import GoogleMobileAds

fileprivate let AD_MANAGER_AD_UNIT_ID = "/21808260008/prebid_demo_app_original_api_banner"
fileprivate let PREBID_STORED_IMP = "prebid-demo-banner-320-50"

class PrebidBannerViewController: UIViewController {
    
    // MARK: - PrebidMobile
    private var pbmBannerAdUnit: BannerAdUnit!
    
    // MARK: - GoogleMobileAds
    private var adManagerBannerView: AdManagerBannerView!
    
    // MARK: - Outlets
    @IBOutlet weak var adPlaceholder: UIView!
    @IBOutlet weak var loadBannerButton: UIButton!
    @IBOutlet weak var loadBannerFromCacheButton: UIButton!
    @IBOutlet weak var clearTargetingCacheButton: UIButton!
    @IBOutlet weak var targetingOutput: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pbmBannerAdUnit = BannerAdUnit(
            configId: PREBID_STORED_IMP,
            size: .init(width: 320, height: 50)
        )
        
        adManagerBannerView = AdManagerBannerView(adSize: AdSizeBanner)
        adManagerBannerView.adUnitID = AD_MANAGER_AD_UNIT_ID
        adManagerBannerView.rootViewController = self
        adManagerBannerView.delegate = self
        addBannerViewToView(adManagerBannerView)
    }
    
    @IBAction func loadBannerWithTargeting(_ sender: UIButton) {
        setOutput("📡 Calling /targeting API...\n\n")
        
        do {
            try OPTABLE!.targeting { [weak self] result in
                var tdata: NSDictionary = [:]
                
                switch result {
                case .success(let keyvalues):
                    print("[OptableSDK] Success on /targeting API call: \(keyvalues)")
                    tdata = keyvalues
                    self?.appendOutput("✅ Targeting data:\n\(keyvalues)\n")
                    
                case .failure(let error):
                    print("[OptableSDK] Error on /targeting API call: \(error)")
                    self?.appendOutput("🚫 Error: \(error.localizedDescription)\n")
                }
                
                self?.loadBanner(keyvalues: tdata)
            }
        } catch {
            print("[OptableSDK] Exception: \(error)")
            appendOutput("⚠️ Exception: \(error.localizedDescription)\n")
        }
    }
    
    @IBAction func loadBannerWithTargetingFromCache(_ sender: UIButton) {
        setOutput("🗂 Checking local targeting cache...\n\n")
        
        var tdata: NSDictionary = [:]
        if let cachedValues = OPTABLE!.targetingFromCache() {
            print("[OptableSDK] Cached targeting values found: \(cachedValues)")
            appendOutput("✅ Found cached data:\n\(cachedValues)\n")
            tdata = cachedValues
        } else {
            appendOutput("ℹ️ Cache empty.\n")
        }
        
        loadBanner(keyvalues: tdata)
    }
    
    @IBAction func clearTargetingCache(_ sender: UIButton) {
        setOutput("🧹 Clearing local targeting cache.\n")
        OPTABLE!.targetingClearCache()
    }
    
    private func loadBanner(keyvalues: NSDictionary) {
        let request = AdManagerRequest()
        
        pbmBannerAdUnit.fetchDemand(adObject: request) { [weak self] status in
            if status != .prebidDemandFetchSuccess {
                print("[PrebidMobile SDK] Prebid fetch demand was not successful: \(status.name())")
            }
            
            if let keyvalues = keyvalues as? [String: String] {
                request.customTargeting?.merge(keyvalues, uniquingKeysWith: { $1 })
            }
            
            self?.adManagerBannerView.load(request)
        }
        
        witness()
        profile()
    }
    
    private func witness() {
        do {
            try OPTABLE!.witness(
                event: "PrebidBannerViewController.loadBannerClicked",
                properties: ["example": "value"]
            ) { [weak self] result in
                switch result {
                case .success(let response):
                    print("[OptableSDK] Witness success: \(response.statusCode)")
                    self?.appendOutput("✅ Witness API logged loadBannerClicked event.\n")
                case .failure(let error):
                    print("[OptableSDK] Witness error: \(error)")
                    self?.appendOutput("🚫 Witness error: \(error.localizedDescription)\n")
                }
            }
        } catch {
            print("[OptableSDK] Exception: \(error)")
            appendOutput("⚠️ Witness exception: \(error.localizedDescription)\n")
        }
    }
    
    private func profile() {
        do {
            try OPTABLE!.profile(
                traits: ["example": "value", "anotherExample": 123, "thirdExample": true]
            ) { [weak self] result in
                switch result {
                case .success(let response):
                    print("[OptableSDK] Profile success: \(response.statusCode)")
                    self?.appendOutput("✅ Profile API set example traits.\n")
                case .failure(let error):
                    print("[OptableSDK] Profile error: \(error)")
                    self?.appendOutput("🚫 Profile error: \(error.localizedDescription)\n")
                }
            }
        } catch {
            print("[OptableSDK] Exception: \(error)")
            appendOutput("⚠️ Profile exception: \(error.localizedDescription)\n")
        }
    }
    
    // MARK: - Helpers
    private func addBannerViewToView(_ bannerView: AdManagerBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        adPlaceholder.addSubview(bannerView)
        
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: adPlaceholder.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: adPlaceholder.centerYAnchor)
        ])
    }
    
    /// Safely sets the full text of targetingOutput on the main thread.
    private func setOutput(_ text: String) {
        DispatchQueue.main.async {
            self.targetingOutput.text = text
        }
    }
    
    /// Appends text to targetingOutput on the main thread with line break.
    private func appendOutput(_ text: String) {
        DispatchQueue.main.async {
            self.targetingOutput.text += "\n\(text)"
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
        print("[GMA SDK] Failed to receive ad: \(error)")
    }
}
