//
//  SignatureManager.swift
//  
//
//  Created by M on 23/12/2565 BE.
//

import Foundation

public protocol SignatureManager {
    func sign(algorithm: SecKeyAlgorithm, data: Data) -> SignatureResult
    func sign(message: String) -> SignatureResult
    func verify(message: String, signature: String) -> Bool
}
