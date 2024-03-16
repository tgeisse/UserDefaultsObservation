//
//  File.swift
//  
//
//  Created by Taylor Geisse on 3/13/24.
//

import Foundation

class UbiquitousKeyValueStoreWrapper {
    // MARK: - Typealiases
    typealias UbiquitousKVSKey              = String
    typealias UbiquitousKVSReasonKey        = Int
    typealias UbiquitousKVSUpdateCallback   = (UbiquitousKVSReasonKey) throws -> Void
    
    private var updateCallbacks: [UbiquitousKVSKey: UbiquitousKVSUpdateCallback] = [:]
    private var cachedUpdates: [UbiquitousKVSKey: [UbiquitousKVSReasonKey]] = [:]
    private var observerAdded = false
    
    // Make this a singleton
    static let shared = UbiquitousKeyValueStoreWrapper()
    private init() {
        addDidChangeExternallyNotificationObserver()
        synchronize()
    }
    
    // MARK: - Notification Registration
    func addDidChangeExternallyNotificationObserver() {
        if observerAdded { return }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ubiquitousKeyValueStoreDidChange(_:)),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: NSUbiquitousKeyValueStore.default)
        observerAdded = true
    }
    
    func synchronize() {
        if NSUbiquitousKeyValueStore.default.synchronize() == false {
            fatalError("This app was not built with the proper entitlement requests.")
        }
    }
    
    // MARK: - External Notification
    @objc func ubiquitousKeyValueStoreDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let reasonForChange = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else { return }
        guard let keys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else { return }
        
        keys.forEach { executeUpdateCallback(forKey: $0, reason: reasonForChange) }
    }
    
    private func executeUpdateCallback(forKey key: UbiquitousKVSKey, reason: UbiquitousKVSReasonKey) {
        guard let updateCallback = updateCallbacks[key] else {
            addKeyReasonToCache(forKey: key, reason: reason)
            return
        }
        
        do {
            try updateCallback(reason)
        } catch {
            addKeyReasonToCache(forKey: key, reason: reason)
        }
    }
    
    private func addKeyReasonToCache(forKey key: UbiquitousKVSKey, reason: UbiquitousKVSReasonKey) {
        cachedUpdates[key, default: []].append(reason)
    }
}
