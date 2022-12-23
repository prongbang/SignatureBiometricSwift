//
//  SignatureBiometricManager.swift
//
//
//  Created by M on 23/12/2565 BE.
//

import Foundation

protocol SignatureBiometricManager {
    func createKeyPair(reason: String, result: @escaping (KeyPairResult) -> ())
    func sign(payload: String, result: @escaping (String?) -> ())
    func verify(payload: String, signature: String, result: @escaping (Bool) -> ())
}
