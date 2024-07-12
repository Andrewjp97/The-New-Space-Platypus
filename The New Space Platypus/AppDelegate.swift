//
//  AppDelegate.swift
//  The New Space Platypus
//
//  Created by Andrew Paterson on 4/27/15.
//  Copyright (c) 2017 Andrew Paterson. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit


/**
 *  The Extension on Double that defines a property CGFloatValue
 */
extension Double {
  /**
   *  The number as a CGFloat
   */
  var CGFloatValue: CGFloat {
    get {
      return CGFloat(self)
    }
  }
}

/**
 *  The Extension on Int that defines a property CGFloatValue
 */
extension Int {
  /**
   *  The number as a CGFloat
   */
  var CGFloatValue: CGFloat {
    get {
      return CGFloat(self)
    }
  }
}

/**
 *  The Enumeration Defining the Types of Platypus
 */
enum kPlatypusColor: Int {
  case kPlatypusColorDefault = 1,
       kPlatypusColorRed,
       kPlatypusColorYellow,
       kPlatypusColorGreen,
       kPlatypusColorPurple,
       kPlatypusColorPink,
       kPlatypusColorDareDevil,
       kPlatypusColorSanta,
       kPlatypusColorElf,
       kPlatypusColorChirstmasTree,
       kPlatypusColorRaindeer,
       kPlatypusColorFire
}

/**
 *  Converts a Platypus Type into an image name
 *
 *  @param kPlatypusColor The Platypus Type you want an image name for
 *
 *  @return The image name for the given platypus type
 */
func imageNameForPlatypusColor(_ color: kPlatypusColor) -> String {
  switch color {
  case .kPlatypusColorDefault:
    return "hullImage"
  case .kPlatypusColorRed:
    return "redHull"
  case .kPlatypusColorGreen:
    return "greenHull"
  case .kPlatypusColorPink:
    return "pinkHull"
  case .kPlatypusColorPurple:
    return "purpleHull"
  case .kPlatypusColorYellow:
    return "yellowHull"
  case .kPlatypusColorDareDevil:
    return "daredevilhull"
  case .kPlatypusColorSanta:
    return "santaPlatypus"
  case .kPlatypusColorElf:
    return "elfPlatypus"
  case .kPlatypusColorChirstmasTree:
    return "christmastreeplatypus"
  case .kPlatypusColorRaindeer:
    return "raindeerPlatypus"
  case .kPlatypusColorFire:
    return "firePlatypus"
  }
  
}

/**
 *  Converts a Platypus Type to the name used to store preferences in NSUserDefaults
 *
 *  @param kPlatypusColor The Platypus Type for which you would like the defaults value
 *
 *  @return The Value for NSUser Defaults for the given platypus type
 */
func stringForPlatypusType(_ type: kPlatypusColor) -> String {
  switch type {
  case .kPlatypusColorDefault:
    return "default"
  case .kPlatypusColorRed:
    return "red"
  case .kPlatypusColorGreen:
    return "green"
  case .kPlatypusColorPink:
    return "pink"
  case .kPlatypusColorPurple:
    return "purple"
  case .kPlatypusColorYellow:
    return "yellow"
  case .kPlatypusColorDareDevil:
    return "dareDevil"
  case .kPlatypusColorSanta:
    return "santa"
  case .kPlatypusColorElf:
    return "elf"
  case .kPlatypusColorChirstmasTree:
    return "tree"
  case .kPlatypusColorRaindeer:
    return "raindeer"
  case .kPlatypusColorFire:
    return "fire"
  }
}

/**
 *  The Global Platypus Color: Auto updates NSUserDefaults upon setting
 */
var platypusColor: kPlatypusColor = .kPlatypusColorDefault{
  didSet{
    UserDefaults.standard.set(stringForPlatypusType(platypusColor), forKey: "platypusColor")
  }
}

/**
 *  The Global Determination of wheter or not motion control is enabled: Auto updates NSUserDefaults upon setting
 */
var motionEnabled: Bool = false {
  didSet {
    UserDefaults.standard.set(motionEnabled, forKey: "motion")
  }
}

var recordHighScore: Int = 0 {
  didSet {
    UserDefaults.standard.set(recordHighScore, forKey: "recordHighScore")
  }
}

var numberOfGamesPlayed: Int = 0 {
  didSet {
    UserDefaults.standard.set(numberOfGamesPlayed, forKey: "numberOfGamesPlayed")
  }
}

var averageScore: Double = 0.0 {
  didSet {
    UserDefaults.standard.set(averageScore, forKey: "averageScore")
  }
}
var timeSpentPlaying: Int = 0 {
  didSet {
    UserDefaults.standard.set(timeSpentPlaying, forKey: "timeSpentPlaying")
  }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  override init() {
    
    // Get Stored Values from NSUserDefaults
    
    motionEnabled = UserDefaults.standard.bool(forKey: "motion")
    
    recordHighScore = UserDefaults.standard.integer(forKey: "recordHighScore")
    
    numberOfGamesPlayed = UserDefaults.standard.integer(forKey: "numberOfGamesPlayed")
    
    averageScore = UserDefaults.standard.double(forKey: "averageScore")
    
    timeSpentPlaying = UserDefaults.standard.integer(forKey: "timeSpentPlaying")
    
    if let colorString:NSString = UserDefaults.standard.object(forKey: "platypusColor") as? NSString {
      switch colorString {
      case "red":
        platypusColor = .kPlatypusColorRed
      case "yellow":
        platypusColor = .kPlatypusColorYellow
      case "green":
        platypusColor = .kPlatypusColorGreen
      case "pink":
        platypusColor = .kPlatypusColorPink
      case "purple":
        platypusColor = .kPlatypusColorPurple
      case "dareDevil":
        platypusColor = .kPlatypusColorDareDevil
      case "santa":
        platypusColor = .kPlatypusColorSanta
      case "elf":
        platypusColor = .kPlatypusColorElf
      case "tree":
        platypusColor = .kPlatypusColorChirstmasTree
      case "fire":
        platypusColor = .kPlatypusColorFire
      case "raindeer":
        platypusColor = .kPlatypusColorRaindeer
      default:
        platypusColor = .kPlatypusColorDefault
      }
    } else {
      platypusColor = .kPlatypusColorDefault
    }
    
    
    super.init()
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    return true
  }
  
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  
}
