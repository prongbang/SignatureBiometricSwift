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
                        result(KeyPairResult(publicKey: nil, status: "error"))
                        print("Error is null")
                        return
                    }
                    
                    let nsError = error as NSError
                    
                    print(nsError.localizedDescription)
                    
                    switch nsError.code {
                    case Int(kLAErrorPasscodeNotSet):
                        result(KeyPairResult(publicKey: nil, status: "passcodeNotSet"))
                        break
                    case Int(kLAErrorTouchIDNotEnrolled):
                        result(KeyPairResult(publicKey: nil, status: "touchIDNotEnrolled"))
                        break
                    case Int(kLAErrorTouchIDLockout):
                        result(KeyPairResult(publicKey: nil, status: "touchIDLockout"))
                        break
                    case Int(kLAErrorTouchIDNotAvailable):
                        result(KeyPairResult(publicKey: nil, status: "touchIDNotAvailable"))
                        break
                    case Int(kLAErrorUserFallback):
                        result(KeyPairResult(publicKey: nil, status: "userFallback"))
                        break
                    case Int(kLAErrorAuthenticationFailed):
                        result(KeyPairResult(publicKey: nil, status: "authenticationFailed"))
                        break
                    case Int(kLAErrorSystemCancel):
                        result(KeyPairResult(publicKey: nil, status: "systemCancel"))
                        break
                    case Int(kLAErrorAppCancel):
                        result(KeyPairResult(publicKey: nil, status: "appCancel"))
                        break
                    case Int(kLAErrorUserCancel):
                        result(KeyPairResult(publicKey: nil, status: "userCancel"))
                        break
                    default:
                        result(KeyPairResult(publicKey: nil, status: "error"))
                        break
                    }
                    
                }
            })
            
        } else {
            result(KeyPairResult(publicKey: nil, status: "notEvaluatePolicy"))
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
