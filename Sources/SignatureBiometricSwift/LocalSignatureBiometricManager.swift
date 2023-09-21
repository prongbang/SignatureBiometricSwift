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
                    
                    let keyPair = self.keyPairManager.create()
                    let pk = keyPair?.publicKey?.toBase64()
                    
                    result(KeyPairResult(publicKey: pk, status: SignatureBiometricStatus.success))
                    
                } else {
                    
                    guard let error = error else {
                        result(KeyPairResult(publicKey: nil, status: SignatureBiometricStatus.error))
                        print("Error is null")
                        return
                    }
                    
                    let nsError = error as NSError
                    
                    print(nsError.localizedDescription)
                    
                    switch nsError.code {
                    case Int(kLAErrorPasscodeNotSet):
                        result(KeyPairResult(publicKey: nil, status: SignatureBiometricStatus.passcodeNotSet))
                        break
                    case Int(kLAErrorTouchIDNotEnrolled), Int(kLAErrorBiometryNotEnrolled):
                        result(KeyPairResult(publicKey: nil, status: SignatureBiometricStatus.notEnrolled))
                        break
                    case Int(kLAErrorTouchIDLockout), Int(kLAErrorBiometryLockout):
                        result(KeyPairResult(publicKey: nil, status: SignatureBiometricStatus.lockedOut))
                        break
                    case Int(kLAErrorBiometryNotPaired):
                        result(KeyPairResult(publicKey: nil, status: SignatureBiometricStatus.notPaired))
                        break
                    case Int(kLAErrorBiometryDisconnected):
                        result(KeyPairResult(publicKey: nil, status: SignatureBiometricStatus.disconnected))
                        break
                    case Int(kLAErrorInvalidDimensions):
                        result(KeyPairResult(publicKey: nil, status: SignatureBiometricStatus.invalidDimensions))
                        break
                    case Int(kLAErrorBiometryNotAvailable), Int(kLAErrorTouchIDNotAvailable):
                        result(KeyPairResult(publicKey: nil, status: SignatureBiometricStatus.notAvailable))
                        break
                    case Int(kLAErrorUserFallback):
                        result(KeyPairResult(publicKey: nil, status: SignatureBiometricStatus.userFallback))
                        break
                    case Int(kLAErrorAuthenticationFailed):
                        result(KeyPairResult(publicKey: nil, status: SignatureBiometricStatus.authenticationFailed))
                        break
                    case Int(kLAErrorSystemCancel), Int(kLAErrorAppCancel), Int(kLAErrorUserCancel):
                        result(KeyPairResult(publicKey: nil, status: SignatureBiometricStatus.canceled))
                        break
                    default:
                        result(KeyPairResult(publicKey: nil, status: SignatureBiometricStatus.error))
                        break
                    }
                    
                }
            })
            
        } else {
            
            result(KeyPairResult(publicKey: nil, status: SignatureBiometricStatus.notEvaluatePolicy))
            
        }
    }
    
    public func sign(payload: String, result: @escaping (SignatureResult) -> ()) {
        let context = LAContext()
        
        // Removing enter password option
        context.localizedFallbackTitle = ""
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            
            let signResult = self.signatureManager.sign(message: payload)
            result(signResult)
            
        } else {

            result(SignatureResult(signature: nil, status: SignatureBiometricStatus.notEvaluatePolicy))

        }
    }
    
    public func verify(reason: String, payload: String, signature: String, result: @escaping (VerifyResult) -> ()) {
        let context = LAContext()
        
        // Removing enter password option
        context.localizedFallbackTitle = ""
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: {(success, error) in
                
                if (success) {
                    
                    let verified = self.signatureManager.verify(message: payload, signature: signature)
                    result(VerifyResult(verified: verified, status: SignatureBiometricStatus.success))
                    
                } else {
                    guard let error = error else {
                        result(VerifyResult(verified: false, status: SignatureBiometricStatus.error))
                        print("Error is null")
                        return
                    }
                    
                    let nsError = error as NSError
                    
                    print(nsError.localizedDescription)
                    
                    switch nsError.code {
                    case Int(kLAErrorPasscodeNotSet):
                        result(VerifyResult(verified: false, status: SignatureBiometricStatus.passcodeNotSet))
                        break
                    case Int(kLAErrorTouchIDNotEnrolled), Int(kLAErrorBiometryNotEnrolled):
                        result(VerifyResult(verified: false, status: SignatureBiometricStatus.notEnrolled))
                        break
                    case Int(kLAErrorTouchIDLockout), Int(kLAErrorBiometryLockout):
                        result(VerifyResult(verified: false, status: SignatureBiometricStatus.lockedOut))
                        break
                    case Int(kLAErrorBiometryNotPaired):
                        result(VerifyResult(verified: false, status: SignatureBiometricStatus.notPaired))
                        break
                    case Int(kLAErrorBiometryDisconnected):
                        result(VerifyResult(verified: false, status: SignatureBiometricStatus.disconnected))
                        break
                    case Int(kLAErrorInvalidDimensions):
                        result(VerifyResult(verified: false,status: SignatureBiometricStatus.invalidDimensions))
                        break
                    case Int(kLAErrorBiometryNotAvailable), Int(kLAErrorTouchIDNotAvailable):
                        result(VerifyResult(verified: false, status: SignatureBiometricStatus.notAvailable))
                        break
                    case Int(kLAErrorUserFallback):
                        result(VerifyResult(verified: false,status: SignatureBiometricStatus.userFallback))
                        break
                    case Int(kLAErrorAuthenticationFailed):
                        result(VerifyResult(verified: false,status: SignatureBiometricStatus.authenticationFailed))
                        break
                    case Int(kLAErrorSystemCancel), Int(kLAErrorAppCancel), Int(kLAErrorUserCancel):
                        result(VerifyResult(verified: false, status: SignatureBiometricStatus.canceled))
                        break
                    default:
                        result(VerifyResult(verified: false, status: SignatureBiometricStatus.error))
                        break
                    }
                    
                }
                
            })
            
        } else {

            result(VerifyResult(verified: false, status: SignatureBiometricStatus.notEvaluatePolicy))

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
