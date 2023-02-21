//
//  AppDelegate.swift
//  ListenToMusicFiles
//
//  Created by aadeeb rashid on 10/19/22.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var managers: ManagerFactory? = ManagerFactory()
    static var sharedDelegate: AppDelegate!
    
    override init() {
        super.init()
        AppDelegate.sharedDelegate = self
    }

    static func sharedAppDelegate() -> AppDelegate {
        return AppDelegate.sharedDelegate
    }

    static func sharedManagers() -> ManagerFactory? {
        return sharedAppDelegate().managers
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        AppDelegate.sharedManagers()?.userManager.loadLibraryFromContext();
        AppDelegate.sharedManagers()?.audioManager.setupForAudioPlayOutsideOfApp()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration
    {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>)
    {

    }
    
    func applicationDidEnterBackground(_ application: UIApplication)
    {
        AppDelegate.sharedManagers()?.audioManager.updateMetaData()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication)
    {
        AppDelegate.sharedManagers()?.audioManager.updateMetaData()
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.portrait
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer =
    {
        let container = NSPersistentContainer(name: "ListenToMusicFiles")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError?
            {
                AppDelegate.sharedManagers()?.errorManager.handleError(error: error)
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext ()
    {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do
            {
                try context.save()
            }
            catch
            {
                AppDelegate.sharedManagers()?.errorManager.handleError(error: error)
            }
        }
    }

}

