//
//  BiometricSignatureManager.swift
//  
//
//  Created by M on 23/12/2565 BE.
//

import Foundation
import CommonCrypto
import LocalAuthentication

public class BiometricSignatureManager : SignatureManager {
    
    private let keyManager: KeyManager
    private let keyConfig: KeyConfig
    
    public init(keyManager: KeyManager, keyConfig: KeyConfig) {
        self.keyManager = keyManager
        self.keyConfig = keyConfig
    }
    
    public func sign(message: String) -> SignatureResult {
        return sign(
            algorithm: .ecdsaSignatureMessageX962SHA256,
            data: message.data(using: .utf8)!
        )
    }
    
    public func sign(algorithm: SecKeyAlgorithm, data: Data) -> SignatureResult {
        
        let key = keyManager.getOrCreate()
        guard key != nil else {
            print("Can't get or create key pair")
            return SignatureResult(signature: nil, status: SignatureBiometricStatus.error)
        }
        
        guard SecKeyIsAlgorithmSupported(key!.privateKey!, .sign, algorithm) else {
            print("Algorith not supported")
            return SignatureResult(signature: nil, status: SignatureBiometricStatus.error)
        }
        
        // SecKeyCreateSignature call is blocking when the used key is protected by biometry authentication.
        // If that's not the case, dispatching to a background thread isn't necessary.
        return doAsync {
            
            var error: Unmanaged<CFError>?
            let signature = SecKeyCreateSignature(
                key!.privateKey!, algorithm,
                data as CFData,
                &error
            ) as Data?
            
            guard signature != nil else {
                if error != nil {
                    let err = error!.takeRetainedValue() as Error
                    guard let nsError = err as NSError? else {
                        return SignatureResult(signature: nil, status: SignatureBiometricStatus.error)
                    }
                    
                    print("Can't sign: \(nsError.localizedDescription)")
                    
                    switch nsError.code {
                    case Int(kLAErrorPasscodeNotSet):
                        return SignatureResult(signature: nil, status: SignatureBiometricStatus.passcodeNotSet)
                    case Int(kLAErrorTouchIDNotEnrolled), Int(kLAErrorBiometryNotEnrolled):
                        return SignatureResult(signature: nil, status: SignatureBiometricStatus.notEnrolled)
                    case Int(kLAErrorTouchIDLockout), Int(kLAErrorBiometryLockout):
                        return SignatureResult(signature: nil, status: SignatureBiometricStatus.lockedOut)
                    case Int(kLAErrorBiometryNotPaired):
                        return SignatureResult(signature: nil, status: SignatureBiometricStatus.notPaired)
                    case Int(kLAErrorBiometryDisconnected):
                        return SignatureResult(signature: nil, status: SignatureBiometricStatus.disconnected)
                    case Int(kLAErrorInvalidDimensions):
                        return SignatureResult(signature: nil, status: SignatureBiometricStatus.invalidDimensions)
                    case Int(kLAErrorBiometryNotAvailable), Int(kLAErrorTouchIDNotAvailable):
                        return SignatureResult(signature: nil, status: SignatureBiometricStatus.notAvailable)
                    case Int(kLAErrorUserFallback):
                        return SignatureResult(signature: nil, status: SignatureBiometricStatus.userFallback)
                    case Int(kLAErrorAuthenticationFailed):
                        return SignatureResult(signature: nil, status: SignatureBiometricStatus.authenticationFailed)
                    case Int(kLAErrorSystemCancel), Int(kLAErrorAppCancel), Int(kLAErrorUserCancel):
                        return SignatureResult(signature: nil, status: SignatureBiometricStatus.canceled)
                    default:
                        return SignatureResult(signature: nil, status: SignatureBiometricStatus.error)
                    }
                }
                return SignatureResult(signature: nil, status: SignatureBiometricStatus.error)
            }
            
            let signedString = signature!.base64EncodedString(options: [])
            
            return SignatureResult(signature: signedString, status: SignatureBiometricStatus.success)
        }.await()
        
    }
    
    public func verify(message: String, signature: String) -> Bool {
        
        let key = keyManager.getOrCreate()
        guard key != nil else {
            print("Can't get or create key pair")
            return false
        }
        
        guard let signatureData = Data(base64Encoded: signature, options: []) else {
            print("Can't convert base64 to data")
            return false
        }
        
        guard let publicKey = key?.publicKey else {
            print("Can't get public key")
            return false
        }
        
        let algorithm: SecKeyAlgorithm = .ecdsaSignatureMessageX962SHA256
        guard SecKeyIsAlgorithmSupported(publicKey, .verify, algorithm) else {
            print("Algorithm is not supported")
            return false
        }
        
        let clearTextData = message.data(using: .utf8)!
        var error: Unmanaged<CFError>?
        guard SecKeyVerifySignature(
            publicKey,
            algorithm,
            clearTextData as CFData,
            signatureData as CFData,
            &error
        ) else {
            print("Can't verify/wrong signature")
            return false
        }
        
        return true
    }
    
}
