//
//  KeychainManager.swift
//  
//
//  Created by M on 23/12/2565 BE.
//

import Foundation

public protocol KeychainManager {
    func loadKey(name: String) -> KeyPair?
    func removeKey(name: String)
    func makeAndStoreKey(name: String) throws -> KeyPair
}
