//
//  GameViewController.swift
//  Space Platypus Swift
//
//  Created by Andrew Paterson on 6/4/14.
//  Copyright (c) 2017 Andrew Paterson. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit
import AVFoundation

class GameViewController: UIViewController {
  
  var player = AVAudioPlayer()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
    
    
    let scene = WelcomeScene(size: self.view.frame.size)
    
    // Configure the view.
    let skView = self.view as! SKView
    
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = true
    
    /* Set the scale mode to scale to fit the window */
    scene.scaleMode = .aspectFill
    
    skView.presentScene(scene)
    
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
