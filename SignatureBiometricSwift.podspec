Pod::Spec.new do |s|
    s.name             = 'SignatureBiometricSwift'
    s.version          = '1.0.10'
    s.summary          = 'Generate key pair and signing using Local Authentication for iOS.'
    s.homepage         = 'https://github.com/prongbang/SignatureBiometricSwift'
    s.license          = 'MIT'
    s.author           = 'prongbang'
    s.source           = { :git => 'https://github.com/prongbang/SignatureBiometricSwift.git', :tag => "#{s.version}" }
    s.social_media_url = 'https://github.com/prongbang'
    s.platform         = :ios, "11.0"
    s.swift_versions   = ["4.0", "4.1", "4.2", "5.0", "5.1", "5.2", "5.3", "5.4", "5.5", "5.6", "5.7", "5.8", "5.9"]
    s.module_name      = "SignatureBiometricSwift"
    s.source_files     = "Sources", "Sources/**/*.{h,m,swift}"
end
