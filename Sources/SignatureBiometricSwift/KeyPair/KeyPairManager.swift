//
//  KeyPairManager.swift
//  
//
//  Created by M on 23/12/2565 BE.
//

import Foundation
import CommonCrypto

public class KeyPairManager : KeyManager {
    
    private let keychainManager: KeychainManager
    private let keyConfig: KeyConfig
    private var keyPair: KeyPair?
    
    public init(keyConfig: KeyConfig, keychainManager: KeychainManager) {
        self.keyConfig = keyConfig
        self.keychainManager = keychainManager
    }
    
    public func create() -> KeyPair? {
        let key = keychainManager.loadKey(name: keyConfig.name)
        guard key == nil else {
            return key
        }
        
        do {
            keyPair = try keychainManager.makeAndStoreKey(name: keyConfig.name)
            return keyPair
        } catch let error {
            print("Can't create key pair : \(error.localizedDescription)")
        }
        
        return nil
    }
    
    public func getOrCreate() -> KeyPair? {
        guard keyPair == nil else {
            return keyPair
        }
        
        keyPair = self.create()
        guard keyPair != nil else {
            print("Can't create key pair")
            return nil
        }
        
        return keyPair
    }
    
}

