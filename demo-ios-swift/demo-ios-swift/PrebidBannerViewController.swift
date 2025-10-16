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
    
    // MARK: Outlets
    
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
    
    // MARK: Actions
    
    @IBAction func loadBannerWithTargeting(_ sender: UIButton) {
        do {
            targetingOutput.text = "Calling /targeting API...\n\n"
            
            try OPTABLE!.targeting() { result in
                var tdata: NSDictionary = [:]
                
                switch result {
                case .success(let keyvalues):
                    print("[OptableSDK] Success on /targeting API call: \(keyvalues)")
                    
                    tdata = keyvalues
                    
                    DispatchQueue.main.async {
                        self.targetingOutput.text += "Data: \(keyvalues)\n"
                    }
                    
                case .failure(let error):
                    print("[OptableSDK] Error on /targeting API call: \(error)")
                    DispatchQueue.main.async {
                        self.targetingOutput.text += "🚫 Error: \(error)\n"
                    }
                }
                
                self.loadBanner(keyvalues: tdata)
            }
        } catch {
            print("[OptableSDK] Exception: \(error)")
        }
    }
    
    @IBAction func loadBannerWithTargetingFromCache(_ sender: UIButton) {
        var tdata: NSDictionary = [:]
        
        targetingOutput.text = "Checking local targeting cache...\n\n"
        
        let cachedValues = OPTABLE!.targetingFromCache()
        if (cachedValues != nil) {
            print("[OptableSDK] Cached targeting values found: \(cachedValues!)")
            targetingOutput.text += "\nFound cached data: \(cachedValues!)\n"
            tdata = cachedValues!
        } else {
            targetingOutput.text += "\nCache empty.\n"
        }
        
        self.loadBanner(keyvalues: tdata)
    }
    
    @IBAction func clearTargetingCache(_ sender: UIButton) {
        targetingOutput.text = "🧹 Clearing local targeting cache.\n"
        OPTABLE!.targetingClearCache()
    }
    
    private func loadBanner(keyvalues: NSDictionary) {
        let req = AdManagerRequest()
        pbmBannerAdUnit.fetchDemand(adObject: req) { [weak self] result in
            // TODO: - Need to clarify how keyvalues should be set in Prebid and probably in GAM(?).
            if let keyvalues = keyvalues as? [String: String] {
                req.customTargeting?.merge(keyvalues, uniquingKeysWith: { $1 })
            }
            
            self?.adManagerBannerView.load(req)
        }
        
        witness()
        profile()
    }
    
    private func witness() {
        do {
            try OPTABLE!.witness(event: "GAMBannerViewController.loadBannerClicked", properties: ["example": "value"]) { result in
                switch result {
                case .success(let response):
                    print("[OptableSDK] Success on /witness API call: response.statusCode = \(response.statusCode)")
                    DispatchQueue.main.async {
                        self.targetingOutput.text += "\n✅ Success calling witness API to log loadBannerClicked event.\n"
                    }
                    
                case .failure(let error):
                    print("[OptableSDK] Error on /witness API call: \(error)")
                    DispatchQueue.main.async {
                        self.targetingOutput.text += "\n🚫 Error: \(error)"
                    }
                }
            }
        } catch {
            print("[OptableSDK] Exception: \(error)")
        }
    }
    
    private func profile() {
        do {
            try OPTABLE!.profile(traits: ["example": "value", "anotherExample": 123, "thirdExample": true ]) { result in
                switch result {
                case .success(let response):
                    print("[OptableSDK] Success on /profile API call: response.statusCode = \(response.statusCode)")
                    DispatchQueue.main.async {
                        self.targetingOutput.text += "\n✅ Success calling profile API to set example traits.\n"
                    }
                    
                case .failure(let error):
                    print("[OptableSDK] Error on /profile API call: \(error)")
                    DispatchQueue.main.async {
                        self.targetingOutput.text += "\n🚫 Error: \(error)"
                    }
                }
            }
        } catch {
            print("[OptableSDK] Exception: \(error)")
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
}

// MARK: - GoogleMobileAds.BannerViewDelegate

extension PrebidBannerViewController: GoogleMobileAds.BannerViewDelegate {
    
    func bannerViewDidReceiveAd(_ bannerView: GoogleMobileAds.BannerView) {
        AdViewUtils.findPrebidCreativeSize(bannerView, success: { size in
            guard let bannerView = bannerView as? AdManagerBannerView else { return }
            bannerView.resize(adSizeFor(cgSize: size))
        }, failure: { (error) in
            print("[PrebidMobile SDK] Error occuring during searching for Prebid creative size: \(error)")
        })
    }
    
    func bannerView(
        _ bannerView: GoogleMobileAds.BannerView,
        didFailToReceiveAdWithError error: any Error
    ) {
        print("[GMA SDK] GMA SDK did fail to receive ad with error: \(error)")
    }
}
