
# UserDefaultsObservation

Combining UserDefaults with Observation, giving you the ability to easily create Observable UserDefaults-backed classes.

1. [Why UserDefaultsObservation?](#why-userdefaultsobservation)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Usage](#usage)
    - [Creating a class](#creating-a-class)
    - [Defining the UserDefaults Key](#defining-the-userdefaults-key)
    - [Using a custom UserDefaults suite](#using-a-custom-userdefaults-suite)
    - [Compiler Flag Dependent UserDefaults suite](#compiler-flag-dependent-userdefaults-suite)
    - [Cloud Storage with NSUbiquitousKeyValueStore](#cloud-storage-with-nsubiquitouskeyvaluestore)
    - [Supported Types](#supported-types)
    - [What happens with unsupported Types](#unsupported-types)
5. [Change Log](#change-log)
    
    
# Why UserDefaultsObservation

Most applications use UserDefaults to store some user preferences, application defaults, and other pieces of information. In the world of SwiftUI, the `@AppStorage` property wrapper was introduced. This provided access to UserDefaults and a way to invalidate a View triggering a redraw.

However, `@AppStorage` has a few limitations:
1. The initialization of it requires a string key and default value, making reuse difficult
2. It is advised against using it in non-SwiftUI code. While UserDefaults APIs are good, it is now a different method for accessing the same information.
3. Refactoring code can be cumbersome depending on how widespread your usage keys are

Wrapping UserDefaults to provide a centralized location of maintaining keys and default values is one solution. However, it does not provide the view invalidating benefits of AppStorage. There are solutions to that as well, but they are sometimes not the most elegant.
 
UserDefaultsObservation aims to solve these issues by:
1. Providing the ability to define any class as both UserDefaults-backed and Observable
2. Centralizing the definition of UserDefaults keys and their default values
3. Able to be used in both SwiftUI and non-SwiftUI code

# Requirements

* iOS 17.0+ | macOS 14.0+ | tvOS 17.0+ | watchOS 10.0+ | macCatalyst 17.0+
* Xcode 15


This package is built on Observation and Macros that are releasing in iOS 17, macOS 14.  

# Installation

## SwiftPM

File > Add Package Dependencies. Use this URL in the search box: https://github.com/tgeisse/UserDefaultsObservation

# Usage

## Creating a Class

To create a class that is UserDefaults backed, import `Foundation` and `UserDefaultsObservation`. Then mark the class with the `@ObservableUserDefaults` macro. Define variables as you normally would:

```swift
import Foundation
import UserDefaultsObservation

@ObservableUserDefaults
class MySampleClass {
    var firstUse = false
    var username: String? = nil
}
```

Should you need to ignore a variable, use the `@ObservableUserDefaultsIgnored` macro. Note: variables with accessors will be ignored as if they have the `@ObservableUserDefaultsIgnored` macro attribute attached.

```swift
@ObservableUserDefaults
class MySampleClass {
    var firstUse = false
    var username: String? = nil
    
    @ObservableUserDefaultsIgnored
    var someIgnoredProperty = "hello world"
}
```

## Defining the UserDefaults Key

A default key is created for you as `{ClassName}.{PropertyName}`. In the example above, the keys would be the following:
- "MySampleClass.firstUse"
- "MySampleClass.username"

In situations you need to control the key - e.g. refactoring or migrating existing keys - you can mark a property with the `@@UserDefaultsProperty` attribute and provide the full UserDefaults key as a parameter. As an example:

```swift
@ObservableUserDefaults
class MySampleClass {
    var firstUse = false
    var username: String? = nil
    
    @ObservableUserDefaultsIgnored
    var someIgnoredProperty = "hello world"
    
    @UserDefaultsProperty(key: "myPreviousKey")
    var existingUserDefaults: Bool = true
}
```

## Using a custom UserDefaults suite

To use a custom UserDefaults store, you can use the `@UserDefaultsStore` attribute to denote the UserDefaults store variable.

```swift
@ObservableUserDefaults
class MySampleClass {
    var firstUse = false
    var username: String? = nil
    
    @ObservableUserDefaultsIgnored
    var someIgnoredProperty = "hello world"
    
    @UserDefaultsProperty(key: "myPreviousKey")
    var existingUserDefaults: Bool = true
    
    @UserDefaultsStore
    var myStore = UserDefaults(suiteName: "MyStore.WithSuiteName.Example")
}
```

Should you need to change the store at runtime, one option is to do so with an initializer:

```swift
@ObservableUserDefaults
class MySampleClass {
    var firstUse = false
    var username: String? = nil
    
    @UserDefaultsStore
    var myStore: UserDefaults
    
    init(_ store: UserDefaults = .standard) {
        self.myStore = store
    }
}
```

## Compiler Flag Dependent UserDefaults Suite

If you would like to define the store using compiler flags, there are a few ways to accomplish this. The first is with a computed property:

```swift
@ObservableUserDefaults
class MySampleClass {
    var firstUse = false
    var username: String? = nil
    
    @ObservableUserDefaultsIgnored
    var someIgnoredProperty = "hello world"
    
    @UserDefaultsProperty(key: "myPreviousKey")
    var existingUserDefaults: Bool = true
    
    @UserDefaultsStore
    var myStore: UserDefaults {
        #if DEBUG
            return UserDefaults(suiteName: "myDebugStore.example")!
        #else
            return UserDefaults(suiteName: "myProductionStore.example")!
        #endif
    }
}
```

If computing this each time is not desired, then this is another option: 

```swift
    @UserDefaultsStore
    var myStore: UserDefaults = {
        #if DEBUG
            return UserDefaults(suiteName: "myDebugStore.example")!
        #else
            return UserDefaults(suiteName: "myProductionStore.example")!
        #endif
    }()
```

One more option is to put the compiler flag code into the initializer

```swift
    @UserDefaultsStore
    var myStore: UserDefaults
    
    init(_ store: UserDefaults = .standard) {
        #if DEBUG
            self.myStore = UserDefaults(suiteName: "myDebugStore.example")
        #else
            self.myStore = store
        #endif
    }
```

## Cloud Storage with NSUbiquitousKeyValueStore

A property can be marked for storage in NSUbiquitousKeyValueStore by using the `@CloudProperty` attribute. This attribute will sync write changes to the cloud and use UserDefaults to cache values locally. The values will be cached in the [UserDefaults store](#using-a-custom-userdefaults-suite) of the class containing the CloudProperty.

Let's take a look at syncing a user's favorite color:

```swwift
@ObservableUserDefaults
class UsersPreferences {
    @CloudProperty(key: "yourCloudKey",
                   userDefaultKey: "differentUserDefaultKey",
                   onStoreServerChange: .cloudValue,
                   onInitialSyncChange: .cloudValue,
                   onAccountChange: .cachedValue)
    var favoriteColor: String = "Green"
}
```

This displays the parameters the user can or must define. Let's review each:

- `key` - the key to be used for storing and retrieving values from NSUbiquitousKeyValueStore
- `userDefaultKey` - an optionally provided key to be used by UserDefaults for storing values locally
- `onStoreServerChange` - define the [value to use](#options-for-values-on-external-notifications) when a `NSUbiquitousKeyValueStoreServerChange` external notification is received
- `onInitialSyncChange` - define the value to use when a `NSUbiquitousKeyValueStoreInitialSyncChange` external notification is received
- `onAccountChange` - define the value to use when a `NSUbiquitousKeyValueStoreAccountChange` external notification is received

> [!TIP]
> Omitting the `userDefaultKey` parameter will use the value of the `key` paramter for UserDefaults.

### Options for Values on External Notifications

For each external notification event reason, the user can select which value to use to update the cloud property. There are currently four options available:

- `defaultValue` - this will use the default value provided. In the favorite color example above, this would be "Green"
- `cachedValue` - the value cached in UserDefaults and is previous value set on the device 
- `cloudValue` - retrieves the cloud value and stores it locally
- `ignore` - ignores the event

### Cloud Storage Quota Violation

> [!WARNING]
> This package does not take any action when the `NSUbiquitousKeyValueStoreQuotaViolationChange` external notification is received.


## Supported Types

All of the following types are supported, including their optional counterparts:
* RawRepresentable
* NSData
* Data
* NSString
* String
* NSURL
* URL
* NSDate
* Date
* NSNumber
* Bool
* Int
* Int8
* Int16
* Int32
* Int64
* UInt
* UInt8
* UInt16
* UInt32
* UInt64
* Double
* Float

* Array where Element is in the above list
* Dictionary where Key == String && Value is in the above list

## Unsupported Types

Unsupported times should throw an error during compile time. The error will be displayed as if it is in the macro, but it is likely the type that is the issue. Should this variable need to be kept on the class, then it may need to be `@ObservableUserDefaultsIgnored`.

# Change Log

## 0.5.0

**New Features and Code Organization**
* Added support for Cloud Storage through NSUbiquitousKeyValueStore
* Added new attributes that are shorter. Existing attributes that they complement are still available
* Internal code structure cleanup
* Readme updates

## 0.4.4

* Updated the Package platform versions to align with Swift Macros platform versions
* Added @available attribute to the protocol used to align with the Observation framework's platform availability
* Added visionOS

## 0.4.3

* Removed commented code that is no longer needed to keep around
* Updated Readme

## 0.4.2

* Updated to swift-syntax 509.0.0 minimum
* Small internal code updates 

## 0.4.1

* Small syntax changes

## 0.4.0
* No longer do you need to import Observation for the macro package to work
* Changes were made to macro declaration; updates were made to match

## 0.3.3
**README updates**
Included additional examples of how to use the @ObservableUserDefaultsStore property attribute

## 0.3.2
README updates

## 0.3.1
README updates

## 0.3.0

**New Features and Code Organization**
* Added @ObservableUserDefaultsStore to define a custom UserDefaults suite. No longer tied to just UserDefaults.standard
* Added @ObservableUserDefaultsIgnored to remove reuse of @ObsercationIgnored
* Moved UserDefaultsWrapper out on its own in the library instead of as a nested struct created by the macro
* Organized code structure
