#
#  Be sure to run `pod spec lint OptableSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name          = "OptableSDK"
  spec.version       = "0.0.1"
  spec.summary       = "A lightweight SDK used to integrate iOS apps with the Optable Sandbox"
  spec.description   = <<-DESC
	The Optable SDK is used to integrate an iOS application with an instance of the
	Optable Sandbox. It provides client-side APIs that enable identity resolution,
	audience segmentation and targeting, and other marketing and advertising
	capabilities.
                   DESC
  spec.homepage      = "https://optable.co"

  spec.license       = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  spec.author        = { "Optable Technologies Inc" => "support@optable.co" }

  spec.platform      = :ios, "13.0"
  spec.swift_version = "5.0"

# spec.source        = { :git => "https://github.com/Optable/optable-ios-sdk", :tag => "#{spec.version}" }
  spec.source        = { :path => '.' }
  spec.source_files  = "Source/**/*.{h,m,swift}"
# spec.exclude_files = "Exclude"
# spec.public_header_files = "Source/**/*.h"

  spec.framework     = ['Foundation', 'WebKit']
end
