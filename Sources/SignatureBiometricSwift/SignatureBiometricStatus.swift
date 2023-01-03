//
//  SignatureBiometricError.swift
//  
//
//  Created by M on 3/1/2566 BE.
//

import Foundation

public class SignatureBiometricStatus {
    public static let success = "success"
    public static let error = "Error"
    public static let passcodeNotSet = "PasscodeNotSet"
    public static let notEnrolled = "NotEnrolled"
    public static let lockedOut = "LockedOut"
    public static let notPaired = "NotPaired"
    public static let disconnected = "Disconnected"
    public static let invalidDimensions = "InvalidDimensions"
    public static let notAvailable = "NotAvailable"
    public static let userFallback = "UserFallback"
    public static let authenticationFailed = "AuthenticationFailed"
    public static let canceled = "Canceled"
    public static let notEvaluatePolicy = "NotEvaluatePolicy"
}
