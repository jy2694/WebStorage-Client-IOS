import SwiftUI

struct UserDefaultsManager{
    @UserDefaultsWrapper(key: "userdata", defaultValue: nil)
    static var userData: UserData?
}
