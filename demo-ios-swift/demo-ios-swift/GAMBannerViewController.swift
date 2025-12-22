//
//  GAMBannerViewController.swift
//  demo-ios-swift
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import UIKit
import GoogleMobileAds

fileprivate let AD_MANAGER_AD_UNIT_ID = "/22081946781/ios-sdk-demo/mobile-leaderboard"

class GAMBannerViewController: UIViewController {
    
    // MARK: - GoogleMobileAds
    var bannerView: BannerView!
    
    // MARK: - Outlets
    @IBOutlet weak var adPlaceholder: UIView!
    @IBOutlet weak var loadBannerButton: UIButton!
    @IBOutlet weak var loadBannerFromCacheButton: UIButton!
    @IBOutlet weak var clearTargetingCacheButton: UIButton!
    @IBOutlet weak var targetingOutput: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView = BannerView(adSize: AdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.rootViewController = self
        bannerView.adUnitID = AD_MANAGER_AD_UNIT_ID
    }
    
    @IBAction func loadBannerWithTargeting(_ sender: UIButton) {
        setOutput("📡 Calling /targeting API...\n\n")
        
        do {
            try OPTABLE!.targeting() { [weak self] result in
                var tdata: NSDictionary = [:]
                
                switch result {
                case .success(let keyvalues):
                    print("[OptableSDK] Success on /targeting API call: \(keyvalues)")
                    tdata = keyvalues
                    self?.appendOutput("✅ Data: \(keyvalues)\n")
                    
                case .failure(let error):
                    print("[OptableSDK] Error on /targeting API call: \(error)")
                    self?.appendOutput("🚫 Error: \(error)\n")
                }
                
                self?.loadBanner(keyvalues: tdata)
            }
        } catch {
            print("[OptableSDK] Exception: \(error)")
        }
    }
    
    @IBAction func loadBannerWithTargetingFromCache(_ sender: UIButton) {
        setOutput("🗂 Checking local targeting cache...\n\n")
        
        var tdata: NSDictionary = [:]
        let cachedValues = OPTABLE!.targetingFromCache()
        
        if let cachedValues {
            print("[OptableSDK] Cached targeting values found: \(cachedValues)")
            appendOutput("✅ Found cached data: \(cachedValues)\n")
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
        let req = AdManagerRequest()
        req.customTargeting = keyvalues as? [String: String]
        bannerView.load(req)
        
        witness()
        profile()
    }
    
    private func witness() {
        do {
            try OPTABLE!.witness(
                event: "GAMBannerViewController.loadBannerClicked",
                properties: ["example": "value"]
            ) { [weak self] result in
                switch result {
                case .success:
                    self?.appendOutput("\n✅ Success calling witness API to log loadBannerClicked event.\n")
                case .failure(let error):
                    self?.appendOutput("\n🚫 Error: \(error)\n")
                }
            }
        } catch {
            print("[OptableSDK] Exception: \(error)")
        }
    }
    
    private func profile() {
        do {
            try OPTABLE!.profile(
                traits: ["example": "value", "anotherExample": 123, "thirdExample": true]
            ) { [weak self] result in
                switch result {
                case .success:
                    self?.appendOutput("\n✅ Success calling profile API to set example traits.\n")
                case .failure(let error):
                    self?.appendOutput("\n🚫 Error: \(error)\n")
                }
            }
        } catch {
            print("[OptableSDK] Exception: \(error)")
        }
    }
    
    // MARK: - Helpers
    
    private func setOutput(_ text: String) {
        DispatchQueue.main.async {
            self.targetingOutput.text = text
        }
    }
    
    private func appendOutput(_ text: String) {
        DispatchQueue.main.async {
            self.targetingOutput.text += text
        }
    }
    
    private func addBannerViewToView(_ bannerView: BannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        adPlaceholder.addSubview(bannerView)
        
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: adPlaceholder.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: adPlaceholder.centerYAnchor)
        ])
    }
}
