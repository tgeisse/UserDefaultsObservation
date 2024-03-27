import UserDefaultsObservation
import Foundation

@available(macOS 14.0, iOS 17.0, tvOS 17.0, macCatalyst 17.0, watchOS 10.0, visionOS 1.0, *)
@ObservableUserDefaults
class MySampleClass {
    var firstUse = false
    
    @ObservableUserDefaultsProperty("OldInterface")
    var oldInterface = true
    
    @CloudProperty(key: "username_key", userDefaultKey: "differentUdKey", onStoreServerChange: .cloudValue, onInitialSyncChange: .defaultValue, onAccountChange: .cachedValue)
    var username: String?
    
    @UserDefaultsProperty(key: "myOldUserDefaultsKey")
    var olderKey = 50
    
    var somethingElse: URL = URL(string: "http://google.com")!
    
    @ObservableUserDefaultsIgnored
    var myUntrackedNonUserDefaultsProperty = true

    
    @ObservableUserDefaultsStore
    var myStore: UserDefaults
    
    init(_ store: UserDefaults = .standard) {
        self.myStore = store
    }
     
}
