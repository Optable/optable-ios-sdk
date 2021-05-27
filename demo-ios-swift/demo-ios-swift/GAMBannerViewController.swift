//
//  GAMBannerViewController.swift
//  demo-ios-swift
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import UIKit
import GoogleMobileAds

class GAMBannerViewController: UIViewController {

    var bannerView: GADBannerView!

    //MARK: Properties
    @IBOutlet weak var loadBannerButton: UIButton!
    @IBOutlet weak var loadBannerFromCacheButton: UIButton!
    @IBOutlet weak var clearTargetingCacheButton: UIButton!
    @IBOutlet weak var targetingOutput: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.rootViewController = self
    }

    //MARK: Actions

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
                        self.targetingOutput.text += "Error: \(error)\n"
                    }
                }

                self.loadBanner(adUnitID: "/22081946781/ios-sdk-demo/mobile-leaderboard", keyvalues: tdata)
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
            targetingOutput.text += "Found cached data: \(cachedValues!)\n"
            tdata = cachedValues!
        } else {
            targetingOutput.text += "Cache empty.\n"
        }

        self.loadBanner(adUnitID: "/22081946781/ios-sdk-demo/mobile-leaderboard", keyvalues: tdata)
    }

    @IBAction func clearTargetingCache(_ sender: UIButton) {
        targetingOutput.text = "Clearing local targeting cache.\n"
        OPTABLE!.targetingClearCache()
    }

    private func loadBanner(adUnitID: String, keyvalues: NSDictionary) {
        bannerView.adUnitID = adUnitID

        let req = GAMRequest()
        req.customTargeting = keyvalues as? [String: String]
        bannerView.load(req)

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
                        self.targetingOutput.text += "\nSuccess calling witness API to log loadBannerClicked event.\n"
                    }

                case .failure(let error):
                    print("[OptableSDK] Error on /witness API call: \(error)")
                    DispatchQueue.main.async {
                        self.targetingOutput.text += "\nError: \(error)"
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
                        self.targetingOutput.text += "\nSuccess calling profile API to set example traits.\n"
                    }

                case .failure(let error):
                    print("[OptableSDK] Error on /profile API call: \(error)")
                    DispatchQueue.main.async {
                        self.targetingOutput.text += "\nError: \(error)"
                    }
                }
            }
        } catch {
            print("[OptableSDK] Exception: \(error)")
        }
    }

    private func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints([
            NSLayoutConstraint(item: bannerView,
                            attribute: .bottom,
                            relatedBy: .equal,
                            toItem: bottomLayoutGuide,
                            attribute: .top,
                            multiplier: 1,
                            constant: 0),
             NSLayoutConstraint(item: bannerView,
                            attribute: .centerX,
                            relatedBy: .equal,
                            toItem: view,
                            attribute: .centerX,
                            multiplier: 1,
                            constant: 0)
        ])
     }

}
