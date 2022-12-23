//
//  BiometricSignatureManager.swift
//  
//
//  Created by M on 23/12/2565 BE.
//

import Foundation
import CommonCrypto

class BiometricSignatureManager : SignatureManager {
    
    private let keyManager: KeyManager
    private let keyConfig: KeyConfig
    
    public init(keyManager: KeyManager, keyConfig: KeyConfig) {
        self.keyManager = keyManager
        self.keyConfig = keyConfig
    }
    
    func sign(message: String) -> String? {
        return sign(
            algorithm: .ecdsaSignatureMessageX962SHA256,
            data: message.data(using: .utf8)!
        )
    }
    
    func sign(algorithm: SecKeyAlgorithm, data: Data) -> String? {
        
        let key = keyManager.getOrCreate()
        guard key != nil else {
            return nil
        }
        
        guard SecKeyIsAlgorithmSupported(key!.privateKey!, .sign, algorithm) else {
            print("Algorith not supported")
            return nil
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
                print("Can't sign: \((error!.takeRetainedValue() as Error).localizedDescription)")
                return nil
            }
            
            let signedString = signature!.base64EncodedString(options: [])
            
            return signedString
        }.await()
        
    }
    
    func verify(message: String, signature: String) -> Bool {
        
        let key = keyManager.getOrCreate()
        guard key != nil else {
            return false
        }
        
        guard let signatureData = Data(base64Encoded: signature, options: []) else {
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
