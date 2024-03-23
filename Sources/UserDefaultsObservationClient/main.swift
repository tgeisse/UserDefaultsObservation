import UserDefaultsObservation
import Foundation

@ObservableUserDefaults
class MySampleClass {
    var firstUse = false
    
    @CloudStore(key: "username_key")
    var username: String? = nil
    
    @ObservableUserDefaultsProperty("myOldUserDefaultsKey")
    var olderKey = 50
    
    
    @ObservableUserDefaultsIgnored
    var myUntrackedNonUserDefaultsProperty = true

    /*
    @ObservableUserDefaultsStore
    var myStore: UserDefaults
    
    init(_ store: UserDefaults = .standard) {
        self.myStore = store
    }*/
     
}
