//
//  User.swift
//  Deals
//
//  Created by Sirajudheen on 17/07/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

class User: NSObject, NSCoding {
    
    var token : String?
    var firstName : String?
    var lastName : String?
    var email : String?
    var phoneNumber : String?
    var photo : String?
    var provider : String?
    
    override init() {
        super.init()
    }
    
    required init(coder aDecoder:NSCoder){
        self.token = aDecoder.decodeObject(forKey: "token") as? String
        self.firstName = aDecoder.decodeObject(forKey: "firstName") as? String
        self.lastName = aDecoder.decodeObject(forKey: "lastName") as? String
        self.email = aDecoder.decodeObject(forKey: "email") as? String
        self.phoneNumber = aDecoder.decodeObject(forKey: "phoneNumber") as? String
        self.photo = aDecoder.decodeObject(forKey: "photo") as? String
        self.provider = aDecoder.decodeObject(forKey: "provider") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.token, forKey: "token")
        aCoder.encode(self.firstName, forKey: "firstName")
        aCoder.encode(self.lastName, forKey: "lastName")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.phoneNumber, forKey: "phoneNumber")
        aCoder.encode(self.photo, forKey: "photo")
        aCoder.encode(self.provider, forKey: "provider")
    }
    
    class func userObjectWithProperties(properties : [String : Any]) -> User {
        let requiredUser = User()
        if let token = properties["token"] as? String {
            requiredUser.token = token
        }
        if let firstName = properties["first_name"] as? String  {
            requiredUser.firstName = firstName
        }
        if let lastName = properties["last_name"] as? String  {
            requiredUser.lastName = lastName
        }
        if let email = properties["email"] as? String  {
            requiredUser.email = email
        }
        if let photo = properties["photo"] as? String  {
            requiredUser.photo = photo
        }
        if let provider = properties["provider"] as? String  {
            requiredUser.provider = provider
        }
        if let phoneNumber = properties["phone_number"] as? String  {
            requiredUser.phoneNumber = phoneNumber
        }
        return requiredUser
    }
    
    func saveToUserDefaults() {
        let filename = NSHomeDirectory() + "/Documents/profile.bin"
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        do {
            try data.write(to: URL(fileURLWithPath: filename))
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    class func getProfile() -> User?{
        if let data = NSData(contentsOfFile: NSHomeDirectory() + "/Documents/profile.bin" ){
            let unarchiveProfile = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! User
            return unarchiveProfile
        } else{
            return nil
        }
    }
    
    class func deleteProfile() {
        do {
            try FileManager.default.removeItem(atPath: NSHomeDirectory() + "/Documents/profile.bin")
        } catch {
                
        }
    }
}
