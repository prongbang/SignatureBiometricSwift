//
//  LocalSignatureBiometricManager.swift
//  
//
//  Created by M on 23/12/2565 BE.
//

import Foundation
import LocalAuthentication

public class LocalSignatureBiometricManager : SignatureBiometricManager {
    
    private let signatureManager: SignatureManager
    private let keyPairManager: KeyManager
    
    init(signatureManager: SignatureManager, keyPairManager: KeyManager) {
        self.signatureManager = signatureManager
        self.keyPairManager = keyPairManager
    }
    
    public func createKeyPair(reason: String, result: @escaping (KeyPairResult) -> ()) {
        let context = LAContext()
        
        // Removing enter password option
        context.localizedFallbackTitle = ""
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: {(success, error) in
                
                if (success) {
                    
                    let keyPair = self.keyPairManager.getOrCreate()
                    let pk = keyPair?.publicKey?.toBase64()
                    
                    result(KeyPairResult(publicKey: pk, status: "success"))
                    
                } else {
                    
                    guard let error = error else {
                        result(KeyPairResult(publicKey: nil, status: "Error"))
                        print("Error is null")
                        return
                    }
                    
                    let nsError = error as NSError
                    
                    print(nsError.localizedDescription)
                    
                    switch nsError.code {
                    case Int(kLAErrorPasscodeNotSet):
                        result(KeyPairResult(publicKey: nil, status: "PasscodeNotSet"))
                        break
                    case Int(kLAErrorTouchIDNotEnrolled), Int(kLAErrorBiometryNotEnrolled):
                        result(KeyPairResult(publicKey: nil, status: "NotEnrolled"))
                        break
                    case Int(kLAErrorTouchIDLockout), Int(kLAErrorBiometryLockout):
                        result(KeyPairResult(publicKey: nil, status: "LockedOut"))
                        break
                    case Int(kLAErrorBiometryNotPaired):
                        result(KeyPairResult(publicKey: nil, status: "NotPaired"))
                        break
                    case Int(kLAErrorBiometryDisconnected):
                        result(KeyPairResult(publicKey: nil, status: "Disconnected"))
                        break
                    case Int(kLAErrorInvalidDimensions):
                        result(KeyPairResult(publicKey: nil, status: "InvalidDimensions"))
                        break
                    case Int(kLAErrorBiometryNotAvailable), Int(kLAErrorTouchIDNotAvailable):
                        result(KeyPairResult(publicKey: nil, status: "NotAvailable"))
                        break
                    case Int(kLAErrorUserFallback):
                        result(KeyPairResult(publicKey: nil, status: "UserFallback"))
                        break
                    case Int(kLAErrorAuthenticationFailed):
                        result(KeyPairResult(publicKey: nil, status: "AuthenticationFailed"))
                        break
                    case Int(kLAErrorSystemCancel), Int(kLAErrorAppCancel), Int(kLAErrorUserCancel):
                        result(KeyPairResult(publicKey: nil, status: "Canceled"))
                        break
                    default:
                        result(KeyPairResult(publicKey: nil, status: "Error"))
                        break
                    }
                    
                }
            })
            
        } else {
            result(KeyPairResult(publicKey: nil, status: "NotEvaluatePolicy"))
        }
    }
    
    public func sign(payload: String, result: @escaping (String?) -> ()) {
        let context = LAContext()
        
        // Removing enter password option
        context.localizedFallbackTitle = ""
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            let signed = signatureManager.sign(message: payload)
            result(signed)
        } else {
            result(nil)
        }
    }
    
    public func verify(payload: String, signature: String, result: @escaping (Bool) -> ()) {
        let context = LAContext()
        
        // Removing enter password option
        context.localizedFallbackTitle = ""
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            let verified = signatureManager.verify(message: payload, signature: signature)
            result(verified)
        } else {
            result(false)
        }
    }
    
    public static func newInstance(keyConfig: KeyConfig) -> SignatureBiometricManager {
        let keychainManager = KeychainAccessManager()
        let keyPairManager = KeyPairManager(
            keyConfig: keyConfig,
            keychainManager: keychainManager
        )
        let signatureManager = BiometricSignatureManager(
            keyManager: keyPairManager,
            keyConfig: keyConfig
        )
        
        return LocalSignatureBiometricManager(
            signatureManager: signatureManager,
            keyPairManager: keyPairManager
        )
    }
}
