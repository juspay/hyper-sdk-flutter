require 'json'

allTenantParams = [{
  resource_url: "https://visabenefits.me1.juspay.io/build/visabenefits/%@client_id-ios/zip",
  sandbox_resource_url: "https://visabenefits.me1.juspay.io/build/visabenefits/%@client_id-ios/zip",
  versioned_resource_url: "https://visabenefits.me1.juspay.io/build/visabenefits/%@client_id-ios/zip",
  merchant_config_json: "VisaInfiniteAccessConfig.json",
  tenant_id: "visabenefits"
}]

fuse_path = if Dir.exist?("./Pods/HyperSDK")
  "./Pods/HyperSDK/Fuse.rb"
elsif ENV['BUILD_DIR'] && Dir.exist?("#{ENV['BUILD_DIR'].sub(/Build.*/, '')}SourcePackages/artifacts/hypersdk-ios/HyperSDK")
  "#{ENV['BUILD_DIR'].sub(/Build.*/, '')}SourcePackages/artifacts/hypersdk-ios/HyperSDK/Fuse.rb"
elsif Dir.exist?(File.join(__dir__, "../../hypersdk-ios/HyperSDK"))
  File.join(__dir__, "../../hypersdk-ios/HyperSDK/Fuse.rb")
else
  abort("Error: HyperSDK Fuse.rb not found. Please ensure HyperSDK is installed via CocoaPods or SPM.")
end

success = system("ruby", fuse_path, "true", "xcframework", JSON.generate(allTenantParams))
exit(success ? 0 : 1)
