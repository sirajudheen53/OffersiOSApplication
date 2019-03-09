//
//  AppDelegate.swift
//  Test
//
//  Created by qbuser on 15/05/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit
import GoogleSignIn
import CoreLocation
import FBSDKCoreKit
import Firebase
import Crashlytics
import Fabric
import UserNotifications
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, CLLocationManagerDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    var currentLocation : CLLocation?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        NSLog("appliction %@", "opened")
        // Check if launched from notification
        let notificationOption = launchOptions?[.remoteNotification]
        
        // 1
        if let notification = notificationOption as? [String: AnyObject] {
            NSLog("Notification\n\n\n\n--------%@------\n\n\n\n", notification)
            
            print()
            if let aps = notification["aps"] as? [String : Any] {
                if let category = aps["category"] as? String, category == "DEAL_NOTIFICATION", let deal_id = notification["deal_id"] {

                    let detailsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DealDetailsView") as! DealDetailsViewController
                    detailsViewController.dealId = Int(deal_id as! String)
                    if let rootViewController = window?.rootViewController {
                        NSLog("Notification\n\n\n\nhahahahahaIn root view")
                        rootViewController.present(detailsViewController, animated: false, completion: nil)
                    }
                }
            }
        }
        
        setApplicationLocationSettings()
       
        setSocialLoginTokens(application: application, launchOptions: launchOptions)
        
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
        registerForPushNotifications()
        
        UserDefaults.standard.set("Qatar", forKey: "SelectedLocation")

        setApplicationTheme()
        
        return true
    }
    
    func setSocialLoginTokens(application: UIApplication, launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        GIDSignIn.sharedInstance().clientID = "575363958117-8tm13saonriclsrvmithkb3fhvrtk9s7.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func setApplicationLocationSettings() {
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            UserDefaults.standard.set(true, forKey: "UserAuthorizationForLocation")
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
        } else {
            UserDefaults.standard.set(false, forKey: "UserAuthorizationForLocation")
        }
    }
    
    func setApplicationTheme() {
        UITabBar.appearance().barTintColor = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 0.82)
        UINavigationBar.appearance().backgroundColor = UIColor.white
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().largeTitleTextAttributes =
            [NSAttributedStringKey.font: Constants.boldProDisplayWithSize(size: 32.0)]
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication =  options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
        
        let googleHandler = GIDSignIn.sharedInstance().handle(
            url,
            sourceApplication: sourceApplication,
            annotation: annotation )
        
        let facebookHandler = FBSDKApplicationDelegate.sharedInstance().application (
            app,
            open: url,
            sourceApplication: sourceApplication,
            annotation: annotation )
        
        return googleHandler || facebookHandler
    }

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self

        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current() // 1
            .requestAuthorization(options: [.alert, .sound, .badge]) { // 2
                granted, error in
                print("Permission granted: \(granted)") // 3
        }
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            //Handle Error
            print("\(error.localizedDescription)")
        } else {
            print(user.authentication.idToken)
            
            BaseWebservice.performRequest(function: WebserviceFunction.login, requestMethod: .post, params: ["id_token" : user.authentication.idToken as AnyObject, "provider" : "google" as AnyObject], headers: nil) { (response, error) in
                if let response = response as? [String : Any] {
                    if let status = response["status"] as? String {
                        if status == "success" {
                            if let userProperties = response["user"] as? [String : Any] {
                                let userObject = User.userObjectWithProperties(properties: userProperties)
                                userObject.saveToUserDefaults()
                                NotificationCenter.default.post(name: NSNotification.Name("userLoggedIn"), object: userProperties)
                            } else {
                                //Handle Error
                            }
                        } else {
                            //Handle Error
                        }
                    } else {
                        //Handle Error
                    }
                } else {
                    //Handle Error
                }
            }
        }
    }

    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Location Manager Delegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        UserDefaults.standard.set(true, forKey: "UserAuthorizationForLocation")

        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        DispatchQueue.main.async {
            self.currentLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
            NotificationCenter.default.post(name: NSNotification.Name("locationUpdated"), object: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        UserDefaults.standard.set(false, forKey: "UserAuthorizationForLocation")
        NotificationCenter.default.post(name: NSNotification.Name("locationUpdated"), object: nil)
        

    }
    
    func sendFCMTokenToServer(fcmToken : String) {
        if let token = User.getProfile()?.token {
            let tokenHeader = ["Authorization" : "Token \(token)"]
            BaseWebservice.performRequest(function: WebserviceFunction.registerToken, requestMethod: .post, params: ["token" : fcmToken as AnyObject], headers: tokenHeader) { (response, error) in
                guard let _ = error else {
                    if let response = response as? [String : String] {
                        if response["status"] == "success" {
                            UserDefaults.standard.set(fcmToken, forKey: "FCMToken")
                        }
                    }
                    return
                }
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        if let currentToken = UserDefaults.standard.value(forKey: "FCMToken") as? String {
            if currentToken != fcmToken {
                sendFCMTokenToServer(fcmToken: fcmToken)
            }
        } else {
            sendFCMTokenToServer(fcmToken: fcmToken)
        }
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        Messaging.messaging().appDidReceiveMessage(userInfo)

        if let aps = userInfo["aps"] as? [String : Any] {
            if let category = aps["category"] as? String, category == "DEAL_NOTIFICATION", let deal_id = userInfo["deal_id"] as? Int {
                NotificationCenter.default.post(name: NSNotification.Name("notificationDealRecieved"), object: ["deal_id":deal_id as AnyObject])
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
         Messaging.messaging().appDidReceiveMessage(userInfo)
        
        if let aps = userInfo["aps"] as? [String : Any] {
            if let category = aps["category"] as? String, category == "DEAL_NOTIFICATION", let deal_id = userInfo["deal_id"] {
                NotificationCenter.default.post(name: NSNotification.Name("notificationDealRecieved"), object: ["deal_id":deal_id as AnyObject])
            }

        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
}


