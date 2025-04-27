# SignatureBiometricSwift 🔐

[![Swift](https://img.shields.io/badge/Swift-5.5+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)](https://developer.apple.com/ios/)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SignatureBiometricSwift.svg)](https://cocoapods.org/pods/SignatureBiometricSwift)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/github/v/release/prongbang/SignatureBiometricSwift)](https://github.com/prongbang/SignatureBiometricSwift/releases)

> Generate key pairs and cryptographic signatures using NIST P-256 EC key pair with ECDSA, protected by biometric authentication on iOS.

## ✨ Features

- 🔑 **Secure Key Generation** - Generate NIST P-256 EC key pairs
- 🔒 **Biometric Protection** - Keys protected by Touch ID or Face ID
- ✍️ **Digital Signatures** - Create and verify ECDSA signatures
- 💾 **Secure Storage** - Keys stored in iOS Secure Enclave
- 🔄 **Change Detection** - Detect biometric enrollment changes

## 📱 Platform Support

- [iOS Version](https://github.com/prongbang/SignatureBiometricSwift) (You are here)
- [Android Version](https://github.com/prongbang/android-biometric-signature)

## 📦 Installation

### CocoaPods

Add to your `Podfile`:

```ruby
pod 'SignatureBiometricSwift'
```

Then run:
```bash
pod install
```

### Swift Package Manager

Add to your `Package.swift`:

```swift
let package = Package(
  dependencies: [
    .package(url: "https://github.com/prongbang/SignatureBiometricSwift.git", from: "1.0.10"),
  ],
)
```

Or via Xcode:
1. File → Add Packages...
2. Enter package URL: `https://github.com/prongbang/SignatureBiometricSwift.git`
3. Select version: `1.0.10` or later

## 🚀 Quick Start

### 1. Configure Privacy Settings

Add to your `Info.plist`:

```xml
<dict>
  <key>NSFaceIDUsageDescription</key>
  <string>This application wants to access your TouchID or FaceID</string>
</dict>
```

### 2. Initialize

```swift
import SignatureBiometricSwift

let keyConfig = KeyConfig(name: "com.yourapp.biometric.key")
let signatureBiometricManager = LocalSignatureBiometricManager.newInstance(
    keyConfig: keyConfig
)
```

### 3. Generate Key Pair

```swift
let reason = "Please scan your fingerprint (or face) to authenticate"

signatureBiometricManager.createKeyPair(reason: reason) { result in
    switch result.status {
    case .success:
        if let publicKey = result.publicKey {
            print("Public Key: \(publicKey)")
            // Send publicKey to your server
        }
    case .authenticationFailed:
        print("Authentication failed")
    case .biometryNotAvailable:
        print("Biometry not available")
    default:
        print("Error: \(result.status)")
    }
}
```

### 4. Sign Data

```swift
let payload = "Hello, World!"

signatureBiometricManager.sign(payload: payload) { result in
    switch result.status {
    case .success:
        if let signature = result.signature {
            print("Signature: \(signature)")
            // Send signature to your server
        }
    default:
        print("Error: \(result.status)")
    }
}
```

## 📚 API Reference

### Key Management

#### Generate Key Pair
```swift
func createKeyPair(reason: String, completion: @escaping (SignatureBiometricResult) -> Void)
```

#### Sign Data
```swift
func sign(payload: String, completion: @escaping (SignatureBiometricResult) -> Void)
```

#### Verify Signature
```swift
func verify(reason: String, payload: String, signature: String, completion: @escaping (SignatureBiometricResult) -> Void)
```

### Biometric Management

#### Check Biometric Changes
```swift
func biometricsChanged() -> Bool
```

#### Reset Biometric Policy State
```swift
func biometricsPolicyStateReset()
```

## 🔍 Complete Examples

### Full Implementation

```swift
import SignatureBiometricSwift

class BiometricSignatureManager {
    private let keyConfig = KeyConfig(name: "com.yourapp.biometric.key")
    private lazy var biometricManager = LocalSignatureBiometricManager.newInstance(
        keyConfig: keyConfig
    )
    
    func setupBiometricKeys() {
        let reason = "Authenticate to generate secure keys"
        
        biometricManager.createKeyPair(reason: reason) { [weak self] result in
            guard let self = self else { return }
            
            switch result.status {
            case .success:
                if let publicKey = result.publicKey {
                    self.savePublicKey(publicKey)
                }
            case .authenticationFailed:
                self.showError("Authentication failed")
            case .biometryNotAvailable:
                self.showError("Biometry not available")
            default:
                self.showError("Failed to generate keys")
            }
        }
    }
    
    func signDocument(_ document: String) {
        biometricManager.sign(payload: document) { [weak self] result in
            switch result.status {
            case .success:
                if let signature = result.signature {
                    self?.processSignature(signature)
                }
            default:
                self?.showError("Failed to sign document")
            }
        }
    }
    
    func checkBiometricChanges() {
        if biometricManager.biometricsChanged() {
            // Handle biometric enrollment changes
            biometricManager.biometricsPolicyStateReset()
            setupBiometricKeys()
        }
    }
}
```

## 📝 Status Codes

| Status | Description |
|--------|-------------|
| `.success` | Operation completed successfully |
| `.authenticationFailed` | Biometric authentication failed |
| `.biometryNotAvailable` | No biometric hardware available |
| `.biometryNotEnrolled` | No biometric data enrolled |
| `.keyPairNotFound` | Key pair not found in keychain |
| `.userCancel` | User cancelled the operation |
| `.unknown` | Unknown error occurred |

## 🔒 Security Considerations

1. **Secure Enclave**: Keys are stored in the Secure Enclave when available
2. **Biometric Protection**: Private keys require biometric authentication
3. **Change Detection**: Detect when biometric enrollments change
4. **Key Invalidation**: Keys become invalid when biometrics change

## 📚 Documentation

- [Protecting keys with the Secure Enclave](https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/protecting_keys_with_the_secure_enclave)
- [Storing Keys in the Keychain](https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/storing_keys_in_the_keychain)
- [SecKeyAlgorithm](https://developer.apple.com/documentation/security/seckeyalgorithm/)

## 🔧 Requirements

- iOS 13.0+
- Swift 5.5+
- Xcode 13.0+

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 💖 Support the Project

If you find this package helpful, please consider supporting it:

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/prongbang)

---
