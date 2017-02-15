//
//  KeychainHelper.swift
//  tassarim
//
//  Created by saylanc on 24/11/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import Foundation
import KeychainAccess

class KeychainHelper {
    
    class func save(_ key: String, data: Data) {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data ] as [String : Any]
        
        SecItemDelete(query as CFDictionary)
        
        let status: OSStatus = SecItemAdd(query as CFDictionary, nil)
        if status == noErr {
            print("sat1 \(status)")
            return
        } else {
            print("sat2 \(status)")
            return
        }
    }
    
    class func delete(_ key: String) {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key
        ]
        
        let status: OSStatus = SecItemDelete(query as CFDictionary)
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
        
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        
        return status == noErr
    }
    
    
    class func load(_ key: String) -> Data? {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue,
            kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]
        
       /* var dataTypeRef :Unmanaged<AnyObject>?
        
        let status = withUnsafeMutablePointer(to: &dataTypeRef) {cfPointer -> OSStatus in
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer(cfPointer))
        }
        
        if status == noErr {
            return (dataTypeRef!.takeRetainedValue() as! Data)
        } else {
            return nil
        }*/
        //let query: [String : AnyObject] = [:]
        //set up the query
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        var data: Data?
        if status == noErr{
            data = result as? Data
            return data
        }else {
            return nil
        }
    }
    
    class func stringToNSDATA(_ string : String)->Data
    {
        let _Data = (string as NSString).data(using: String.Encoding.utf8.rawValue)
        return _Data!
        
    }
    
    class func NSDATAtoString(_ data: Data)->String
    {
        let returned_string : String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        return returned_string
    }
 }

