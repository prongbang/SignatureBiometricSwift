//
//  KeyManager.swift
//  
//
//  Created by M on 23/12/2565 BE.
//

import Foundation

public protocol KeyManager {
    func create() -> KeyPair?
    func getOrCreate() -> KeyPair?
}
