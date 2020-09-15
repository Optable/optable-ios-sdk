//
//  GAMBannerViewController.swift
//  demo-ios-swift
//
//  Created by Bosko Milekic on 2020-08-27.
//  Copyright © 2020 Bosko Milekic. All rights reserved.
//

import UIKit
import GoogleMobileAds

class GAMBannerViewController: UIViewController {

    var bannerView: DFPBannerView!

    //MARK: Properties
    @IBOutlet weak var loadBannerButton: UIButton!
    @IBOutlet weak var targetingOutput: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        bannerView = DFPBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.rootViewController = self
    }

    //MARK: Actions

    @IBAction func loadBannerWithTargeting(_ sender: UIButton) {
        do {
            targetingOutput.text = "Calling /targeting API...\n\n"

            try OPTABLE!.targeting() { result in
                switch result {
                case .success(let keyvalues):
                    print("[OptableSDK] Success on /targeting API call: \(keyvalues)")

                    self.loadBanner(adUnitID: "/22081946781/ios-sdk-demo/mobile-leaderboard", keyvalues: keyvalues)

                    DispatchQueue.main.async {
                        self.targetingOutput.text += "Data: \(keyvalues)\n"
                    }

                case .failure(let error):
                    print("[OptableSDK] Error on /targeting API call: \(error)")
                    DispatchQueue.main.async {
                        self.targetingOutput.text += "Error: \(error)\n"
                    }
                }
            }
        } catch {
            print("[OptableSDK] Exception: \(error)")
        }
    }

    private func loadBanner(adUnitID: String, keyvalues: NSDictionary) {
        bannerView.adUnitID = adUnitID

        let req = DFPRequest()
        req.customTargeting = keyvalues as! [String: Any]
        bannerView.load(req)
    }

    private func addBannerViewToView(_ bannerView: DFPBannerView) {
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
