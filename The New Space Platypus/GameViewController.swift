//
//  GameViewController.swift
//  Space Platypus Swift
//
//  Created by Andrew Paterson on 6/4/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//
// TODO: DELETE: import iAd
import UIKit
import SpriteKit
import GameKit
import AVFoundation

class GameViewController: UIViewController {

    // TODO: DELETE: var iAdBanner = ADBannerView()
    // TODO: DELETE: var bannerVisible = false
    var player = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

// TODO: DELETE: func easyGameCenterAuthentified() {
        //println("Authenticated")
    // TODO: DELETE: }
    
    // TODO: DELETE: func easyGameCenterNotAuthentified() {
        //println("Not Authenticated")
    // TODO: DELETE: }
    
    // TODO: DELETE: func bannerViewDidLoadAd(_ banner: ADBannerView!) {
       // TODO: DELETE:  if(bannerVisible == false) {
            
            // Add banner Ad to the view
         // TODO: DELETE:    if(iAdBanner.superview == nil) {
          // TODO: DELETE:       self.view?.addSubview(iAdBanner)
          // TODO: DELETE:   }
            
          // TODO: DELETE:   // Move banner into visible screen frame:
         // TODO: DELETE:    UIView.beginAnimations("iAdBannerShow", context: nil)
         // TODO: DELETE:    banner.frame = banner.frame.offsetBy(dx: 0, dy: -banner.frame.size.height)
         // TODO: DELETE:    UIView.commitAnimations()
            
        // TODO: DELETE:     bannerVisible = true
       // TODO: DELETE:  }
        
   // TODO: DELETE:  }
    
    // Hide banner, if Ad is not loaded.
   // TODO: DELETE:  func bannerView(_ banner: ADBannerView!, didFailToReceiveAdWithError error: Error!) {
    // TODO: DELETE:     if(bannerVisible == true) {
            // Move banner below screen frame:
    // TODO: DELETE:         UIView.beginAnimations("iAdBannerHide", context: nil)
   // TODO: DELETE:          banner.frame = banner.frame.offsetBy(dx: 0, dy: banner.frame.size.height)
   // TODO: DELETE:          UIView.commitAnimations()
   // TODO: DELETE:          bannerVisible = false
   // TODO: DELETE:      }
   // TODO: DELETE:
   // TODO: DELETE:  }
    
  // TODO: DELETE:   func bannerViewActionDidFinish(_ banner: ADBannerView!) {
   // TODO: DELETE:      let view = self.view as! SKView
   // TODO: DELETE:      view.presentScene(WelcomeScene(size: self.view.frame.size))
   // TODO: DELETE:      if let height = self.view?.frame.size.height {
   // TODO: DELETE:          if let width = self.view?.frame.size.width {
   // TODO: DELETE:              banner.frame = CGRect(x: 0, y: height, width: width, height: 50)
   // TODO: DELETE:              banner.frame = banner.frame.offsetBy(dx: 0, dy: banner.frame.size.height)
   // TODO: DELETE:          }
   // TODO: DELETE:      }
   // TODO: DELETE:  }
    
    override func viewWillAppear(_ animated: Bool) {

        
        
        let scene = WelcomeScene(size: self.view.frame.size)

        // Configure the view.
        let skView = self.view as! SKView
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true

        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFill

        skView.presentScene(scene)
        
   // TODO: DELETE:     if let height = self.view?.frame.size.height {
   // TODO: DELETE:          if let width = self.view?.frame.size.width {
   // TODO: DELETE:              iAdBanner.frame = CGRect(x: 0, y: height, width: width, height: 50)
    // TODO: DELETE:             iAdBanner.delegate = self
    // TODO: DELETE:             bannerVisible = false
      // TODO: DELETE:       }
      // TODO: DELETE:   }

     // TODO: DELETE:    EasyGameCenter.sharedInstance(self)
        
     // TODO: DELETE:    EasyGameCenter.showGameCenterAuthentication()
        

        try? player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "Adventure Meme", ofType: "mp3")!))
        
        player.prepareToPlay()
        
        player.numberOfLoops = -1
        player.volume = 0.15
        player.play()
    }

    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
