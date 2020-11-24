Pod::Spec.new do |spec|
  spec.name          = "OptableSDK"
  spec.version       = "0.7.0"
  spec.summary       = "A lightweight SDK used to integrate iOS apps with the Optable Sandbox"
  spec.description   = <<-DESC
	The Optable SDK is used to integrate an iOS application with an instance of the
	Optable Sandbox. It provides client-side APIs that enable identity resolution,
	audience segmentation and targeting, and other marketing and advertising
	capabilities.
                   DESC
  spec.homepage      = "https://github.com/Optable/optable-ios-sdk"

  spec.license       = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  spec.author        = { "Optable Technologies Inc" => "support@optable.co" }

  spec.platform              = :ios
  spec.ios.deployment_target = "9.2"
  spec.swift_version         = "5.0"

  spec.source        = { :git => "git@github.com:Optable/optable-ios-sdk.git", :tag => "#{spec.version}" }
  spec.source_files  = "Source/**/*.{h,m,swift}"

  spec.framework     = ['Foundation', 'WebKit', 'CryptoKit', 'AdSupport']
end
