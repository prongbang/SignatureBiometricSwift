//
//  SignatureBiometricManager.swift
//
//
//  Created by M on 23/12/2565 BE.
//

import Foundation

public protocol SignatureBiometricManager {
    func createKeyPair(reason: String, result: @escaping (KeyPairResult) -> ())
    func sign(payload: String, result: @escaping (SignatureResult) -> ())
    func verify(reason: String, payload: String, signature: String, result: @escaping (VerifyResult) -> ())
    func biometricsChanged() -> Bool
    func biometricsPolicyStateReset()
}
