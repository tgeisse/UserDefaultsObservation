
# UserDefaultsObservation

Combining UserDefaults with Observation, giving you the ability to easily create Observable UserDefaults-backed classes.

1. [Why UserDefaultsObservation?](#why-userdefaultsobservation)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Usage](#usage)
    - [Creating a class](#creating-a-class)
    - [Defining the UserDefaults Key](#defining-the-userdefaults-key)
    - [Supported Types](#supported-types)
    - [What happens with unsupported Types](#unsupported-types)
    
    
## Why UserDefaultsObservation

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

## Requirements

* iOS 17.0+ | macOS 14.0+ | tvOS 17.0+ | watchOS 10.0+ | macCatalyst 17.0+
* Xcode 15


This package is built on Observation and Macros that are releasing in iOS 17, macOS 14.  

## Installation

### SwiftPM

File > Add Package Dependencies. Use this URL in the search box: https://github.com/tgeisse/UserDefaultsObservation

## Usage

### Creating a Class

To create a class that is UserDefaults backed, use the `@ObservableUserDefaults` macro call. You will need to import the package and Observation as well. Define variables as you normally would

```swift
import UserDefaultsObservation
import Observation

@ObservableUserDefaults
class MySampleClass {
    var firstUse = false
    var username: String? = nil
}
```

Should you need to ignore a variable, use the `@ObservationIgnored` macro. Note: variables with accessors will be ignored as if they have the `@ObservationIgnored` macro attached.

```swift
@ObservableUserDefaults
class MySampleClass {
    var firstUse = false
    var username: String? = nil
    
    @ObservationIgnored
    var someIgnoredProperty = "hello world"
}
```

### Defining the UserDefaults Key

At this time, the key is generated for you. It will be the `ClassName_PropertyName` by default. In the example above, the keys would be the following:
- "MySampleClass_firstUse"
- "MySampleClass_username"

There are plans to add control over this in the future.

### Supported Types

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

### Unsupported Types

Unsupported times should throw an error during compile time. The error will be displayed as if it is in the macro, but it is likely the type that is the issue. Should this variable need to be kept on the class, then it may need to be `@ObservationIgnored`.
