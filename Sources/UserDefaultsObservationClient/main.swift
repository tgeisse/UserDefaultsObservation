import UserDefaultsObservation
import Observation
import Foundation

@ObservableUserDefaults
class MySampleClass {
    var firstUse = false
    var username: String? = nil
    
    @ObservableUserDefaultsProperty("myOldUserDefaultsKey")
    var olderKey = 50
    
    @ObservationIgnored
    var myUntrackedNonUserDefaultsProperty = true
}
