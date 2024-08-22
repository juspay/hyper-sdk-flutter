require "yaml"

hyper_sdk_version = "2.1.43"

begin
  # Read hyper_sdk_version from pubspec.yaml if it exists
  pubspec_path = File.expand_path(File.join(__dir__, "../../../../../pubspec.yaml"))
  if File.exist?(pubspec_path)
    pubspec = YAML.load_file(pubspec_path)
    if pubspec["hyper_sdk_ios_version"]
      override_version = pubspec["hyper_sdk_ios_version"]
      hyper_sdk_version = Gem::Version.new(override_version) > Gem::Version.new(hyper_sdk_version) ? override_version : hyper_sdk_version
      if hyper_sdk_version != override_version
        puts ("Ignoring the overridden SDK version present in pubspec.yaml (#{override_version}) as there is a newer version present in the SDK (#{hyper_sdk_version}).").yellow
      end
    end
  end
rescue => e
  puts ("An error occurred while overriding the IOS SDK Version. #{e.message}").red
end

puts ("HyperSDK HyperSDK Version Version: #{hyper_sdk_version}")

Pod::Spec.new do |s|
  s.name             = 'hypersdkflutter'
  s.version          = '4.0.20'
  s.summary          = 'Flutter plugin for Juspay SDK'
  s.description      = <<-DESC
Flutter plugin for juspay SDK.
                       DESC
  s.homepage         = 'https://juspay.in/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Juspay' => 'support@juspay.in' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'HyperSDK', hyper_sdk_version
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain an i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end
