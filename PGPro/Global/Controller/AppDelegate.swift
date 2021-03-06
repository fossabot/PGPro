//
//  AppDelegate.swift
//  PGPro
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

import UIKit
import CoreData
import ObjectivePGP

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        window?.tintColor = UIColor.label

        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore {

            // If in simulator, create example dataset
            #if targetEnvironment(simulator)
                ExampleDataService.createExampleDataset()
                // ExampleDataService.generateLargeInput(numberOfContacts: 10)
            #endif

            UserDefaults.standard.set(true, forKey: "launchedBefore")
            UserDefaults.standard.set(0, forKey: "numRatings")
        } else {
            ContactListService.loadPersistentData()
        }

        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {

        // Check if file type is valid
        let fileExtension = url.pathExtension
        guard (fileExtension == "asc") else {
            let alertController = UIAlertController(title: "Filetype not supported!",
                                                    message: nil,
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss",
                                                    style: .default))
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            return false
        }

        // Treat file as PGP encrypted text
        var encryptedMessage = ""
        guard let window = self.window else { return true }
        do {
            encryptedMessage = try String(contentsOf: url, encoding: .ascii)
            if let tabBarController = window.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 1
            }
        } catch {
            let alertController = UIAlertController(title: "File not supported!", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
            window.rootViewController?.present(alertController, animated: true, completion: nil)
            return false
        }

        DispatchQueue.main.async {
            let actualVC = window.rootViewController?.children[1].children.first
            while !(actualVC is DecryptionTableViewController) { }
            let decryptionVC = actualVC as? DecryptionTableViewController
            if let decryptionVC = decryptionVC {
                while (decryptionVC.viewIfLoaded == nil) {  }
                decryptionVC.textView.text = encryptedMessage
            }
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationDidBecomeActive(_ application: UIApplication) { }

    func applicationWillTerminate(_ application: UIApplication) {
        PersistenceService.save()
    }

}
