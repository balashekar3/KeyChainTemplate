//
//  KeyChainManager.swift
//  KeyChainTemplate
//
//  Created by Balashekar Vemula on 06/03/23.
//

import Foundation
import Security

// Arguments for the keychain queries
let kSecClassValue = NSString(format: kSecClass)
let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
let kSecValueDataValue = NSString(format: kSecValueData)
let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
let kSecAttrServiceValue = NSString(format: kSecAttrService)
let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
let kSecReturnDataValue = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)

/// Class for KeychainUtility to store and retrieve data from Keychain
open class KeyChain: NSObject { 
    
    /// Function to update data in keychain.
    ///
    /// - Parameters:
    ///   - service: service name provided by the user
    ///   - account: account name provided by the user
    ///   - data: Data to be updated in keychain for provided account and service
    /// - Returns: OSStatus
    public static func updateData(service: String, account: String, data: Data) -> OSStatus {
        
        // Instantiate a new default keychain query
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, account],
                                                                     forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue])
        
        let status = SecItemUpdate(keychainQuery as CFDictionary, [kSecValueDataValue: data] as CFDictionary)
        
        // Always check the status
        if status != errSecSuccess {
            if let err = SecCopyErrorMessageString(status, nil) {
                print("Write failed: \(err)")
            }
        }
        return status
    }
    
    /// Function to remove data from keychain for provided account and service.
    ///
    /// - Parameters:
    ///   - service: service name for which data is to be removed
    ///   - account: account name for which data is to be removed
    /// - Returns: OSStatus
    public static func removeData(service: String, account: String) -> OSStatus {
        
        // Instantiate a new default keychain query
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, account],
                                                                     forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue])
        
        // Delete any existing items
        let status = SecItemDelete(keychainQuery as CFDictionary)
        
        // Always check the status
        if status != errSecSuccess {
            if let err = SecCopyErrorMessageString(status, nil) {
                print("Remove failed: \(err)")
            }
        }
        return status
    }
    
    /// Function to save data in keychain for provided account and service.
    ///
    /// - Parameters:
    ///   - service: service name for which data is to be saved
    ///   - account: account name for which data is to be saved
    ///   - data: data to be saved
    /// - Returns: OSStatus
    public static func saveData(service: String, account: String, data: Data) -> OSStatus {
        // Instantiate a new default keychain query
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, account, data],
                                                                     forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])
        
        // Add the new keychain item
        let status = SecItemAdd(keychainQuery as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            return KeyChain.updateData(service: service, account: account, data: data)
        }
            
            // Always check the status
        else if status != errSecSuccess {
            if let err = SecCopyErrorMessageString(status, nil) {
                print("Write failed: \(err)")
            }
        }
        return status
    }
    
    /// Function to fetch data from keychain for provided account and service.
    ///
    /// - Parameters:
    ///   - service: service name for which data is to be fetched
    ///   - account: account name for which data is to be fetched
    /// - Returns: Data stored in keychain for provided account and service
    public static func loadData(service: String, account: String) -> Data? {
        
        // Instantiate a new default keychain query
        // Tell the query to return a result
        // Limit our results to one item
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, account, kCFBooleanTrue!, kSecMatchLimitOneValue],
                                                                     forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])
        
        var dataTypeRef: AnyObject?
        
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var contentsOfKeychain: Data?
        
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data {
                contentsOfKeychain = retrievedData
            }
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
        }
        
        return contentsOfKeychain
    }
}

/// Convert String to Data
extension String {
    func toData() -> Data {
        return Data(self.utf8)
    }
}

/// Convert Data to String
extension Data {
    func toString() -> String {
        return String(decoding: self, as: UTF8.self)
    }
}
