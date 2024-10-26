//
//  LAContext+Extension.swift
//
//
//  Created by prongbang on 26/10/2567 BE.
//

import LocalAuthentication

extension LAContext {
    
    static var biometricsPolicyState: Data? {
        get {
            UserDefaults.standard.data(forKey: "BiometricsPolicyState")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "BiometricsPolicyState")
        }
    }
    
}
