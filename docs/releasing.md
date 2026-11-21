# Guide to releasing optable-ios-sdk

This guide is for maintainers of `optable-ios-sdk` and lists the steps required when releasing a new version to third-party developers.

The SDK is distributed through [Swift Package Manager](https://www.swift.org/package-manager/), which resolves versions from the repository's git tags: publishing a release tag is what makes a version installable. Version 1.4.0 was the last one published to CocoaPods, whose trunk became read-only on December 2, 2026.

## Publish a release preparation PR

Create a branch named after the upcoming release (example: `release/2.1.0`) and open a pull request from it. Don't name the branch after the bare version number (`2.1.0`): once the release tag exists, git can't tell the branch and the tag apart.

Commit release-related changes, such as updating `MARKETING_VERSION`, into the release branch.

## Update release version in Xcode build target

Open [OptableSDK.xcodeproj](https://github.com/Optable/optable-ios-sdk/tree/master/OptableSDK.xcodeproj) in Xcode and navigate to `OptableSDK` under the project's build targets, then to the "General" tab where you will find a "Version" input field. Update this field value to the upcoming release number (example: 2.1.0).

This field is sometimes called the `MARKETING_VERSION` and you should see a diff to `OptableSDK.xcodeproj/project.pbxproj` file once you save your change.

If the release is a new major version, also update the version in the README's Swift Package Manager example (`from: "2.0.0"`).

Make sure to commit your changes to the release preparation branch.

## Build OptableSDK and run tests in Xcode

Make sure that the `OptableSDK.xcodeproj` build completes successfully, and that you can complete the following steps within Xcode without errors:

- Product > Clean Build Folder
- Product > Build
- Product > Test

## Update and test demo apps

Build and run the demo apps in [demo-ios-objc](https://github.com/Optable/optable-ios-sdk/tree/master/demo-ios-objc) and [demo-ios-swift](https://github.com/Optable/optable-ios-sdk/tree/master/demo-ios-swift) from the release branch, following the build steps in the README's Demo Applications section. Both use the SDK from the repository checkout rather than a published version, so they test the code being released. Make sure that they build cleanly, run in the iOS simulators and work as expected. Commit any dependency lock file changes to the release preparation branch.

## Merge release preparation PR

Ensure all release preparation changes have been committed and pushed to the release preparation branch and that the PR passes all required checks, including the automated [Github Actions](https://github.com/Optable/optable-ios-sdk/actions) builds.

Once the PR is ready, squash and merge it into `master` and delete the release preparation branch.

## Create the release

Ensure that the latest merged changes successfully pass all automated [Github Actions](https://github.com/Optable/optable-ios-sdk/actions) builds in `master`.

Draft a new release in the [GitHub Releases page](https://github.com/Optable/optable-ios-sdk/releases), specifying a new tag for creation with the tag name equal to the version of the release, without a `v` prefix (example: 2.1.0), targeting the squash-merge commit of the release preparation PR. The release title should also be set to the release version number, and the description should include a list of important changes since the previous release.

Publish the release. A release left as a draft creates no tag, so the version can't be installed.

Ensure that the [Github Actions](https://github.com/Optable/optable-ios-sdk/actions) release-builds which will run automatically when the release tag is published complete successfully.

## Check the release resolves

Confirm that Swift Package Manager can install the new version, for example by running `swift package resolve` in a scratch package that depends on `.package(url: "https://github.com/Optable/optable-ios-sdk", exact: "2.1.0")`.
