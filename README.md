# SignatureBiometricSwift

Generate key pair and signing using Local Authentication for iOS.

## CocoaPods

```shell
pod 'SignatureBiometricSwift'
```

## Swift Package Manager

In your `Package.swift` file, add `SignatureBiometricSwift` dependency to corresponding targets:

```swift
let package = Package(
  dependencies: [
    .package(url: "https://github.com/prongbang/SignatureBiometricSwift.git", from: "1.0.5"),
  ],
)
```

## How to use

### Privacy `info.plist`

```xml
<dict>
  <key>NSFaceIDUsageDescription</key>
  <string>This application wants to access your TouchID or FaceID</string>
</dict>
```

### Initialize

```swift
import SignatureBiometricSwift

let keyConfig = KeyConfig(name: "com.prongbang.signx.kSecAccKey")
let signatureBiometricManager = LocalSignatureBiometricManager.newInstance(
    keyConfig: keyConfig
)
```

### Generate KeyPair

```swift
import SignatureBiometricSwift

let reason = "Please scan your fingerprint (or face) to authenticate"
signatureBiometricManager.createKeyPair(reason: reason) { result in
    if result.status == "success" {
        let publicKey = result.publicKey ?? ""
        print("publicKey: \(publicKey)")
    } else {
        print("Error: \(result.status)")
    }
}
```

### Sign

```swift
import SignatureBiometricSwift

let clearText = "Hello"
signatureBiometricManager.sign(payload: clearText) { signature in
    print("signature: \(signature)")
}
```

### Verify

```swift
import SignatureBiometricSwift

let clearText = "Hello"
signatureBiometricManager.verify(payload: clearText, signature: signed) { verified in
    print("verified: \(verified)")
}
```
