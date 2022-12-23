//
//  SecKey+Extension.swift
//  
//
//  Created by M on 23/12/2565 BE.
//

import Foundation

extension SecKey {
    
    func toBase64() -> String? {
        guard let b64 = toBase64Default() else {
            return nil
        }
        
        return b64
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\n", with: "")
    }
    
    func toBase64Default() -> String? {
        var error: Unmanaged<CFError>?
        let cfdata = SecKeyCopyExternalRepresentation(self, &error)
        if cfdata == nil {
            return nil
        }
        let secKeyData: CFData = cfdata!
        let ecHeader: [UInt8] = [
            /* sequence          */ 0x30, 0x59,
            /* |-> sequence      */ 0x30, 0x13,
            /* |---> ecPublicKey */ 0x06, 0x07, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x02, 0x01, // (ANSI X9.62 public key type)
            /* |---> prime256v1  */ 0x06, 0x08, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x03, 0x01, // (ANSI X9.62 named elliptic curve)
            /* |-> bit headers   */ 0x07, 0x03, 0x42, 0x00
        ]
        var asn1 = Data()
        asn1.append(Data(ecHeader))
        asn1.append(secKeyData as Data)
        let encoded = asn1.base64EncodedString(options: .lineLength64Characters)

        return encoded
    }
    
    func toPem() -> String? {
        guard let b64 = toBase64Default() else {
            return nil
        }
        return "-----BEGIN PUBLIC KEY-----\r\n\(b64)\r\n-----END PUBLIC KEY-----\r\n"
    }
}
