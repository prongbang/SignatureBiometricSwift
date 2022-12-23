//
//  SignatureManager.swift
//  
//
//  Created by M on 23/12/2565 BE.
//

import Foundation

public protocol SignatureManager {
    func sign(algorithm: SecKeyAlgorithm, data: Data) -> String?
    func sign(message: String) -> String?
    func verify(message: String, signature: String) -> Bool
}
