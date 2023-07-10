import UserDefaultsObservation
import Observation
import Foundation

@ObservableUserDefaults
class MySampleClass {
    var firstUse = false
    var username: String? = nil
    
    @ObservableUserDefaultsProperty("myOldUserDefaultsKey")
    var olderKey = 50
    
    @ObservableUserDefaultsIgnored
    var myUntrackedNonUserDefaultsProperty = true
    
    @ObservableUserDefaultsStore
    var myStore: UserDefaults
    
    init(_ store: UserDefaults = .standard) {
        self.myStore = store
    }
}
