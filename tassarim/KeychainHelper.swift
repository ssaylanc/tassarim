//
//  KeychainHelper.swift
//  tassarim
//
//  Created by saylanc on 24/11/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import Foundation

class KeychainHelper {
    
    class func save(key: String, data: NSData) {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data ]
        
        SecItemDelete(query as CFDictionaryRef)
        
        let status: OSStatus = SecItemAdd(query as CFDictionaryRef, nil)
        if status == noErr {
            return
        } else {
            return
        }
    }
    
    class func delete(key: String) {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key
        ]
        
        let status: OSStatus = SecItemDelete(query as CFDictionaryRef)
        if status == noErr {
            return
        } else {
            print(status)
            return
        }
    }
    
    class func clear() -> Bool {
        let query = [
            kSecClass as String: kSecClassGenericPassword
        ]
        
        let status: OSStatus = SecItemDelete(query as CFDictionaryRef)
        
        return status == noErr
    }
    
    
    class func load(key: String) -> NSData? {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue,
            kSecMatchLimit as String  : kSecMatchLimitOne ]
        
        var dataTypeRef :Unmanaged<AnyObject>?
        
        let status: OSStatus = withUnsafeMutablePointer(&dataTypeRef) { SecItemCopyMatching(query as CFDictionaryRef, UnsafeMutablePointer($0)) }
        
        if status == noErr {
            return (dataTypeRef!.takeRetainedValue() as! NSData)
        } else {
            return nil
        }
    }
    
    class func stringToNSDATA(string : String)->NSData
    {
        let _Data = (string as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        return _Data!
        
    }
    
    class func NSDATAtoString(data: NSData)->String
    {
        let returned_string : String = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
        return returned_string
    }
    
}