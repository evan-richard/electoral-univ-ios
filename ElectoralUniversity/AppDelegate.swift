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
import CoreLocation

private var allNodesDG = DispatchGroup()
private var imageDownloadDG = DispatchGroup()
private var lastUpdatedDG = DispatchGroup()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    static let imageCache = NSCache<NSString, UIImage>()
    static let db = Firestore.firestore()
    static let downloadNotification = Notification.Name("downloadNotification")
    static let fetchCompleteNotification = Notification.Name("fetchCompleteNotification")
    
    var dbLastUpdates: [String: Date] = [:]
    var issues: [Issue] = []
    var tweets: [Tweet] = []
    var candidates: [String: Candidate] = [:]
    var events: [Event] = []
    var states: [String: State] = [:]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        lastUpdatedDG.enter()
        getLastUpdateTimes()
        
        lastUpdatedDG.notify(queue: .main) {
            let managedContext = self.persistentContainer.viewContext
            allNodesDG.enter()
            self.downloadCandidateData(managedContext: managedContext)
            allNodesDG.enter()
            self.downloadTweetData(managedContext: managedContext)
            allNodesDG.enter()
            self.downloadIssueData(managedContext: managedContext)
            allNodesDG.enter()
            self.downloadEventData(managedContext: managedContext)
            allNodesDG.enter()
            self.downloadStateData(managedContext: managedContext)
        }
        
        allNodesDG.notify(queue: .main) {
            NotificationCenter.default.post(name: AppDelegate.fetchCompleteNotification, object: nil, userInfo: ["events": self.events, "states": self.states, "candidates": self.candidates, "tweets": self.tweets, "issues": self.issues])
            self.startDownload()
            imageDownloadDG.notify(queue: .main) {
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
            imageDownloadDG.enter()
            url = URL(string: candidate.profileImg)!
            AppDelegate.downloadImage(url: url, completion: { (profileImage: UIImage?, error: Error?) -> Void in
                if let _ = error {
                    print("Failed to download image.")
                }
                imageDownloadDG.leave()
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
    
    func getLastUpdateTimes() {
        AppDelegate.db.collection("last_updates").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.dbLastUpdates[document.documentID] = (document.data()["last_updated"] as? Timestamp)?.dateValue()
                }
            }
            lastUpdatedDG.leave()
        }
    }
    
    private func getLastUpdateTime(managedContext: NSManagedObjectContext, node: String) -> Date? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LastUpdated")
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                if (data.value(forKey: "node") as! String == node) {
                    return data.value(forKey: "timestamp") as? Date
                }
            }
        } catch {
            return nil
        }
        return nil
    }
        
    
    func downloadCandidateData(managedContext: NSManagedObjectContext) {
        let lastUpdated: Date? = getLastUpdateTime(managedContext: managedContext, node: "candidates")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Candidate")
        if ((lastUpdated != nil) && (lastUpdated! == self.dbLastUpdates["candidates"])) {
            do {
                let result = try managedContext.fetch(fetchRequest)
                for data in result as! [NSManagedObject] {
                    var responses: Dictionary<String, Int> = [:]
                    let respRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Response")
                    respRequest.predicate = NSPredicate(format: "candidate.id = %@", data.value(forKey: "id") as! String)
                    do {
                        let result = try managedContext.fetch(respRequest)
                        for data in result as! [NSManagedObject] {
                            responses[data.value(forKey: "id") as! String] = data.value(forKey: "stance") as? Int
                        }
                    } catch {
                        print("Error = \(error.localizedDescription)")
                    }
                    self.candidates[data.value(forKey: "id") as! String] = Candidate(name: data.value(forKey: "name") as! String, id: data.value(forKey: "id") as! String, screenName: data.value(forKey: "screenName") as! String, profileImg: data.value(forKey: "profileImg") as! String, bannerImg: data.value(forKey: "bannerImg") as! String, responses: responses)
                }
            } catch {
                print("Error = \(error.localizedDescription)")
            }
        } else {
            AppDelegate.db.collection("candidates").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if let candidate: Candidate = Candidate(dictionary: document.data()) {
                            self.candidates[candidate.id] = candidate
                        }
                    }
                    do {
                        let result = try managedContext.fetch(fetchRequest)
                        if (result.count > 0) {
                            
                        } else {
                            
                        }
                    } catch {
                        print("Error = \(error.localizedDescription)")
                    }
                }
                allNodesDG.leave()
            }
        }
    }
    
    func downloadTweetData(managedContext: NSManagedObjectContext) {
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
            allNodesDG.leave()
        }
    }
    
    func downloadIssueData(managedContext: NSManagedObjectContext) {
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
            allNodesDG.leave()
        }
    }
    
    func downloadEventData(managedContext: NSManagedObjectContext) {
        AppDelegate.db.collection("events").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let event: Event = Event(dictionary: document.data()) {
                        self.events.append(event)
                    }
                }
            }
            allNodesDG.leave()
        }
    }
    
    func downloadStateData(managedContext: NSManagedObjectContext) {
        AppDelegate.db.collection("states").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let state: State = State(dictionary: document.data()) {
                        self.states[state.identifier] = state
                    }
                }
            }
            allNodesDG.leave()
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

