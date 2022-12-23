//
//  KeychainAccessManager.swift
//  
//
//  Created by M on 23/12/2565 BE.
//

import Foundation

class KeychainAccessManager : KeychainManager {
    
    func loadKey(name: String) -> KeyPair? {
        let tag = name.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String                 : kSecClassKey,
            kSecAttrApplicationTag as String    : tag,
            kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
            kSecReturnRef as String             : true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            return nil
        }
        let privateKey = (item as! SecKey)
        
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            print("Can't get public key")
            return nil
        }
        
        return KeyPair(privateKey: privateKey, publicKey: publicKey)
    }
    
    func removeKey(name: String) {
        let tag = name.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String                 : kSecClassKey,
            kSecAttrApplicationTag as String    : tag
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    func makeAndStoreKey(name: String) throws -> KeyPair {
        removeKey(name: name)
        
        let flags: SecAccessControlCreateFlags
        if #available(iOS 11.3, *) {
            flags = [.privateKeyUsage, .biometryCurrentSet]
        } else {
            flags = [.privateKeyUsage, .touchIDCurrentSet]
        }
        let access = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            flags,
            nil
        )!
        let tag = name.data(using: .utf8)!
        let attributes: [String: Any] = [
            kSecClass as String                     : kSecClassKey,
            kSecAttrKeyType as String               : kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String         : 256,
            kSecAttrTokenID as String               : kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String : [
                kSecAttrIsPermanent as String       : true,
                kSecAttrApplicationTag as String    : tag,
                kSecAttrAccessControl as String     : access
            ]
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            print("Can't create private key")
            throw error!.takeRetainedValue() as Error
        }
        
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            print("Can't get public key")
            throw error!.takeRetainedValue() as Error
        }
        
        return KeyPair(privateKey: privateKey, publicKey: publicKey)
    }
    
}
