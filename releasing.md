# Guide to releasing optable-ios-sdk

This guide is for maintainers of `optable-ios-sdk` and lists the steps required when releasing a new version to third-party developers.

## Publish a release preparation draft PR

Create a branch with the upcoming release number as its name and publish it to GitHub. Create a draft pull request from the branch (example: `0.10.0`).

Commit release-related changes, such as updating `MARKETING_VERSION`, into the release branch.

The release branch will also enable you to run `pod spec lint` once you've updated the `OptableSDK.podspec` file to reference the new upcoming release number, since `spec lint` clones the code from GitHub and looks for a branch or tag that matches the release number.

## Install ruby and CocoaPods locally

One of the supported installation methods for the SDK is [CocoaPods](https://cocoapods.org/), so you'll want to make sure that you have it installed and updated if you are preparing a release.

Make sure your local `ruby` is up to date and that you are using the latest stable release. It is recommended that you use [rvm](https://rvm.io/) to install and manage your local ruby versions.

Refer to the [CocoaPods Getting Started Guide](https://guides.cocoapods.org/using/getting-started.html) to learn how to install.

## Update CocoaPods Gemfile

If it has been some time since you've last updated CocoaPods, once you've updated your local gems you can run `bundle update` from the project's top-level directory. This will update all ruby dependencies that are bundled when CocoaPods is run.

More information regarding bundler update can be found [here](https://bundler.io/man/bundle-update.1.html)

If there are changes to the Gemfile or Gemfile.lock, make sure that you commit them to the release preparation branch.

## Update release version in XCode build target

Open [OptableSDK.xcodeproj](https://github.com/Optable/optable-ios-sdk/tree/master/OptableSDK.xcodeproj) in XCode and navigate to `OptableSDK` under the project's build targets, then to the "General" tab where you will find a "Version" input field. Update this field value to the upcoming release number (example: 0.10.0).

This field is sometimes called the `MARKETING_VERSION` and you should see a diff to `OptableSDK.xcodeproj/project.pbxproj` file once you save your change.

Make sure to commit your changes to the release preparation branch.

## Build OptableSDK and run tests in XCode

Make sure that the `OptableSDK.xcodeproj` build completes successfully, and that you can complete the following steps within XCode without errors:

- Product > Clean Build Folder
- Product > Build
- Product > Test

## Update CocoaPods specfile

Update the `spec.version` field value in the [OptableSDK.podspec](https://github.com/Optable/optable-ios-sdk/blob/master/OptableSDK.podspec) to refer to the upcoming release (example: 0.10.0).

Commit your changes to the release preparation branch and push them upstream to GitHub.

## Run CocoaPods lint checks

Run `pod lib lint` and ensure that it completes successfully.

Finally run `pod spec lint` and ensure that it completes successfully.

## Update and test demo apps

The demo apps in [demo-ios-objc](https://github.com/Optable/optable-ios-sdk/tree/master/demo-ios-objc) and [demo-ios-swift](https://github.com/Optable/optable-ios-sdk/tree/master/demo-ios-swift) make use of CocoaPods to manage their dependency on the SDK. You will notice in each of their `Podfiles` that they refer to the `OptableSDK` pod using a `:path` parameter -- this means that they will look for the `OptableSDK.podspec` in their parent directory locally, and not try to download the pod from the official `cdn.cocoapods.org` repository.

This allows you to update the demo apps to the latest SDK version and run tests simply by changing into the demo app directory and running `pod install` and `pod update`. Once you've run `pod update` in the demo app directory you may notice changes to the `Podfile.lock` so make sure to commit those to the release preparation branch.

You should see a `demo-ios-{swift,objc}.xcworkspace` file locally in the demo app's directory after you've done a first `pod install`. Open the `xcworkspace` file in XCode and make sure that it builds cleanly and that you can run the demo app in the iOS simulators and that it is functioning as expected.

## Merge release preparation PR

Ensure all release preparation changes have been committed and pushed to the release preparation branch and that the draft PR passes all required checks, including the automated [Github Actions](https://github.com/Optable/optable-ios-sdk/actions) builds.

Once the PR is ready, squash and merge it into `master` and delete the release preparation branch.

## Create the release

Ensure that the latest merged changes successfully pass all automated [Github Actions](https://github.com/Optable/optable-ios-sdk/actions) builds in `master`.

Draft a new release in the [GitHub Releases page](https://github.com/Optable/optable-ios-sdk/releases), specifying a new tag for creation with the tag name equal to the version of the release (example: 0.10.0). The release title should also be set to the release version number, and the description should include a list of important changes since the previous release. Publish the release.

Ensure that the [Github Actions](https://github.com/Optable/optable-ios-sdk/actions) release-builds which will run automatically when the release tag is published complete successfully.

## Publish latest spec to CocoaPods trunk

In order for third-party application `Podfiles` that reference the `OptableSDK` pod on `cdn.cocoapods.org` to correctly install the latest released version of the SDK when developers run `pod install`, you'll need to push the latest `OptableSDK.podspec` to the CocoaPods public trunk repository.

You will first need to register with the CocoaPods trunk repository. You can do this by following the [CocoaPods guide here](https://guides.cocoapods.org/making/getting-setup-with-trunk.html). If not already done, and once registered, an existing `optable-ios-sdk` maintainer will need to add you as a contributor by running `pod trunk add-owner OptableSDK your@email.com`.

Authorized contributors can then run `pod trunk push` from the project's top level directory which will run `pod spec lint` automatically and, on success, publish the new `OptableSDK.podspec` to the public repository. Before running `pod trunk push`, make sure to `git pull` the latest `master` branch, containing the latest changes as well as the newly published release tag.
