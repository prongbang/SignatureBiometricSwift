//
//  KeyPair.swift
//  
//
//  Created by M on 23/12/2565 BE.
//

import Foundation
import CommonCrypto

public struct KeyPair {
    let privateKey: SecKey?
    let publicKey: SecKey?
}
