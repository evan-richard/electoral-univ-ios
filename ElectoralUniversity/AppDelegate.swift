//
//  AppDelegate.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 10/4/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import UIKit
import CoreData
import Firebase

private var dispatchGroup = DispatchGroup()
private var downloadGroup = DispatchGroup()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let imageCache = NSCache<NSString, UIImage>()
    static let db = Firestore.firestore()
    static let downloadNotification = Notification.Name("downloadNotification")
    
    var issues: [Issue] = []
    private var tweets: [Tweet] = []
    var candidates: [String: Candidate] = [:]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        dispatchGroup.enter()
        downloadCandidateData()
        dispatchGroup.enter()
        downloadTweetData()
        dispatchGroup.enter()
        downloadIssueData()
        
        dispatchGroup.notify(queue: .main) {
            self.startDownload()
            downloadGroup.notify(queue: .main) {
                NotificationCenter.default.post(name: AppDelegate.downloadNotification, object: nil, userInfo: nil)
            }
        }
        
        return true
    }
    
    // Lock the orientation to Portrait mode for iphones
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.model.starts(with: "iPad") {
            return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.all.rawValue)
        } else {
            return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.portrait.rawValue)
        }
    }
    
    func startDownload() {
        var url: URL
        for (_,candidate) in candidates {
            downloadGroup.enter()
            url = URL(string: candidate.profileImg)!
            AppDelegate.downloadImage(url: url, completion: { (profileImage: UIImage?, error: Error?) -> Void in
                if let _ = error {
                    print("Failed to download image.")
                }
                downloadGroup.leave()
            })
        }
    }
    
    static func downloadImage(url: URL, completion: @escaping (_ image: UIImage?, _ error: Error? ) -> Void) {
        if let cachedImage = AppDelegate.imageCache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage, nil)
        } else {
            let session = URLSession(configuration: .default)
            let request = URLRequest(url: url)
            let downloadPicTask = session.dataTask(with: request) { (data, response, error) in
                // The download has finished.
                if let e = error {
                    completion(nil, e)
                } else {
                    if let _ = response as? HTTPURLResponse {
//                        print("Downloaded profile picture with response code \(res.statusCode)")
                        if let imageData = data {
                            let image = UIImage(data: imageData)!
                            AppDelegate.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                            completion(image, nil)
                        } else {
                            print("Couldn't get image: Image is nil")
                        }
                    } else {
                        print("Couldn't get response code for some reason")
                    }
                }
            }
            downloadPicTask.resume()
        }
    }
        
    
    func downloadCandidateData() {
        AppDelegate.db.collection("candidates").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let candidate: Candidate = Candidate(dictionary: document.data()) {
                        self.candidates[candidate.id] = candidate
                    }
                }
            }
            dispatchGroup.leave()
        }
    }
    
    func downloadTweetData() {
        AppDelegate.db.collection("tweets").order(by: "timestamp", descending: true).limit(to: 50).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let tweet: Tweet = Tweet(dictionary: document.data()) {
                        self.tweets.append(tweet)
                    }
                }
                NotificationCenter.default.post(name: FeedViewController.tweetNotification, object: nil, userInfo:["tweets": self.tweets])
            }
            dispatchGroup.leave()
        }
    }
    
    func downloadIssueData() {
        AppDelegate.db.collection("issues").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let issue: Issue = Issue(dictionary: document.data()) {
                        self.issues.append(issue)
                    }
                }
                self.issues.shuffle()
            }
            dispatchGroup.leave()
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "ElectoralUniversity")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

