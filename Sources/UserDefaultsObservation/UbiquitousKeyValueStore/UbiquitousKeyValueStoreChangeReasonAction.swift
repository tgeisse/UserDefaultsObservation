//
//  File.swift
//  
//
//  Created by Taylor Geisse on 3/15/24.
//

import Foundation

public enum UbiquitousKeyValueStoreChangeReasonAction: String {
    case defaultValue
    case cachedValue
    case cloudValue
    case ignore
}
