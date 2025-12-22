# Optable iOS SDK [![iOS SDK CI](https://github.com/Optable/optable-ios-sdk/actions/workflows/ios-sdk-ci.yml/badge.svg)](https://github.com/Optable/optable-ios-sdk/actions/workflows/ios-sdk-ci.yml)

SDK for integrating with an [Optable Data Connectivity Node (DCN)](https://docs.optable.co) from an iOS application.

## Install

### Swift Package Manager (SPM)

The [Swift Package Manager](https://www.swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the swift compiler.

Once you have your Swift package set up, you can add this SDK as a dependency. Add it to the dependencies value of your Package.swift or the Package list in Xcode.

```swift
dependencies: [
    .package(url: "https://github.com/Optable/optable-ios-sdk", .branch("master"))
]
```

### CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website.

To integrate this SDK into your Xcode project using CocoaPods, specify it in your Podfile:

```ruby
pod 'OptableSDK'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

To integrate this SDK into your Xcode project using Carthage, specify it in your Cartfile:

```
github "Optable/optable-ios-sdk"
```

## Usage

Simplest usage example:

```swift
// Configure
let config = OptableConfig(tenant: "dcn.customer.com", originSlug: "my-app")
let optableSDK = OptableSDK(config: config) // can instantiate multiple instances

// Use
let identifiers = OptableIdentifiers(emailAddress: "test@test.test")
try await optableSDK.identify(identifiers)
```

For more detailed usage guide, see our:

-   [<ins>Swift integration guide</ins>](docs/usage-swift.md)
-   [<ins>Objective-C integration guide</ins>](docs/usage-objc.md)

## Demo Applications

The Swift and Objective-C demo applications show a working example of `identify` , `targeting`, `profile` and `witness` APIs, as well as an integration with the [Google Ad Manager 360](https://admanager.google.com/home/) ad server, enabling the targeting of ads served by GAM360 to audiences activated in the [Optable](https://optable.co/) DCN.

By default, the demo applications will connect to the [Optable](https://optable.co/) demo DCN.

The demo apps depend on the [GAM Mobile Ads SDK for iOS](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/quick-start) and load ads from a GAM360 account operated by [Optable](https://optable.co/).

**Build**

[Cocoapods](https://cocoapods.org/) is required to build the `demo-ios-swift` and `demo-ios-objc` applications. After cloning the repo, simply `cd` into either of the two demo app directories and run:

```bash
cd demo-ios-swift

# Install dependencies
pod install
```

Then open the generated `demo-ios-swift.xcworkspace` or `demo-ios-objc.xcworkspace` in [Xcode](https://developer.apple.com/xcode/), and build and run from there.
