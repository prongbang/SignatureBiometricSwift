//
//  KeyPair.swift
//  
//
//  Created by M on 23/12/2565 BE.
//

import Foundation
import CommonCrypto

public struct KeyPair {
    public let privateKey: SecKey?
    public let publicKey: SecKey?
}
