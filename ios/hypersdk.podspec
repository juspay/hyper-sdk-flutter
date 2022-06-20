#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint hypersdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'hypersdk'
  s.version          = '2.0.2'
  s.summary          = 'Flutter plugin for Juspay SDK'
  s.description      = <<-DESC
Flutter plugin for juspay SDK.
                       DESC
  s.homepage         = 'https://juspay.in/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Juspay' => 'rachit.naithani@juspay.in' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'HyperSDK', '2.1.5'
  s.platform = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
