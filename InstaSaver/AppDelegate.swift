//
//  AppDelegate.swift
//  InstaSaver
//
//  Created by Кирилл on 19.10.2020.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow? 
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
		
		window = UIWindow(frame: UIScreen.main.bounds)
		let navVC = UINavigationController(rootViewController: FeedVC())
		navVC.isNavigationBarHidden = true
		window?.rootViewController = navVC
		window?.makeKeyAndVisible()
		return true
	}

}
