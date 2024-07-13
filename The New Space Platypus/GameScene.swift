//
//  GameScene.swift
//  Space Platypus Swift
//
//  Created by Andrew Paterson on 6/5/14.
//  Copyright (c) 2017 Andrew Paterson. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit
import CoreMotion
import AudioToolbox

class GameScene: SKScene, SKPhysicsContactDelegate, TimerDelegate {
  
  var contentCreated = false
  var seconds = 0
  var stars: SKEmitterNode
  var running = true
  var invincible = false
  var hits: Int = 0 {
    didSet {
      if hits < 0 {
        hits = 0
      }
      if hits == 0 {
        let node = self.childNode(withName: "lifeBar") as! SKSpriteNode
        node.texture = SKTexture(imageNamed: "LifeBarFull")
      }
      if hits == 1 {
        let node = self.childNode(withName: "lifeBar") as! SKSpriteNode
        node.texture = SKTexture(imageNamed: "LifeBarTwo")
      }
      if hits == 2 {
        let node = self.childNode(withName: "lifeBar") as! SKSpriteNode
        node.texture = SKTexture(imageNamed: "LifeBarOne")
      }
      if hits > 2 {
        self.slowMotion = false
        self.gameOver()
      }
    }
  }
  var leaderboards: [AnyObject] = []
  var shouldAcceptFurtherCollisions = true
  var shouldMakeMoreRocks = true
  var level = 0
  var motionManager: CMMotionManager?
  var impulseSlower = false
  var timer: Timer = Timer()
  var timerLabel: SKLabelNode
  var slowMotion: Bool = false {
    willSet {
      if newValue == false {
        self.removeSlowMotion()
      }
      else {
        self.addSlowMotion()
      }
    }
  }
  
  /**
   *  Handles returning the scene to it's normal state
   *
   *  @return Void
   */
  func removeSlowMotion() {
    self.timer.removeAllActions()
    self.timer.timeScale = 1.0
    self.timer.start()
    let action = SKAction.run({
      self.enumerateChildNodes(withName: "slow", using: ({(node, stop) in
        node.alpha = node.alpha - (0.8/10)
      }))
    })
    
    let repeatStep = SKAction.repeat(SKAction.sequence([action, SKAction.wait(forDuration: 0.025)]), count: 10)
    self.run(repeatStep)
    let block: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = ({(node, stop) in
      
      if let node = node as? SKSpriteNode {
        let origional = node.physicsBody
        node.physicsBody = nil
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.categoryBitMask = origional!.categoryBitMask
        node.physicsBody?.categoryBitMask = origional!.categoryBitMask
        node.physicsBody?.contactTestBitMask = origional!.contactTestBitMask
        node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -0.75 * (self.impulseSlower ? 0.5 : 1.0) * (1.0 + (self.seconds.CGFloatValue / 100.0))))
      }
      
    })
    self.enumerateChildNodes(withName: "rock", using: block)
    self.enumerateChildNodes(withName: "life", using: block)
    self.enumerateChildNodes(withName: "gravity", using: block)
    self.enumerateChildNodes(withName: "invincible", using: block)
    self.physicsWorld.gravity = CGVector(dx: 0, dy: self.physicsWorld.gravity.dy * 20)
    
    
    
    
  }
  
  /**
   *  Handles the implementaion of slowing down the scene and overlaying a transparent node
   *
   *  @return Void
   */
  func addSlowMotion(){
    self.timer.timeScale = 8.0
    let node = SKSpriteNode(color: SKColor(white: 0.1, alpha: 0.6), size: self.size)
    node.alpha = 0.0
    node.name = "slow"
    node.anchorPoint = CGPoint.zero
    node.zPosition = 1000
    let action = SKAction.run({
      let node = self.childNode(withName: "slow") as! SKSpriteNode
      node.alpha = node.alpha + (0.8/20)
    })
    let repeatStep = SKAction.repeat(SKAction.sequence([action, SKAction.wait(forDuration: 0.05)]), count: 20)
    self.addChild(node)
    node.run(repeatStep)
    let block: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = ({(node, stop) in
      if let node = node as? SKSpriteNode {
        let origional = node.physicsBody
        node.physicsBody = nil
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.categoryBitMask = origional!.categoryBitMask
        node.physicsBody?.collisionBitMask = origional!.collisionBitMask
        node.physicsBody?.contactTestBitMask = origional!.contactTestBitMask
        node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -0.125 * (self.impulseSlower ? 0.5 : 1.0) * (1.0 + (self.seconds.CGFloatValue / 100.0))))
      }
      
      
    })
    self.enumerateChildNodes(withName: "rock", using: block)
    self.enumerateChildNodes(withName: "life", using: block)
    self.enumerateChildNodes(withName: "gravity", using: block)
    self.enumerateChildNodes(withName: "invincible", using: block)
    self.physicsWorld.gravity = CGVector(dx: 0, dy: self.physicsWorld.gravity.dy * 0.05)
    
  }
  
  override init(size: CGSize) {
    
    self.timerLabel  = SKLabelNode(fontNamed: "Helvetica")
    self.timerLabel.text = "0:00"
    self.stars = SKEmitterNode()
    super.init(size: size)
    self.stars = makeStars()
    self.addChild(self.stars)
    
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    self.stars = SKEmitterNode()
    self.timerLabel = SKLabelNode()
    super.init(coder: aDecoder)
    
  }
  
  func timerDidChangeTime(_ value: Int, valueString: String) {
    self.seconds = value
    let string = value % 60 < 10 ? "0\(value % 60)" : "\(value % 60)"
    self.timerLabel.text = "\(value / 60):\(string)"
    self.timerLabel.position = CGPoint(x: 10 + (0.5 * self.timerLabel.frame.size.width), y: self.frame.size.height - 30 - (0.5 * self.timerLabel.frame.size.height))
    
  }
  
  override func didMove(to view: SKView) {
    
    if !contentCreated {
      
      self.timer.delegate = self
      self.addChild(self.timer)
      self.timerLabel.zPosition = 500
      self.backgroundColor = SKColor.black
      self.timerLabel.fontSize = 24
      self.timerLabel.fontColor = SKColor.white
      self.timerLabel.position = CGPoint(x: 10 + (0.5 * self.timerLabel.frame.size.width), y: self.frame.size.height - 30 - (0.5 * self.timerLabel.frame.size.height))
      self.addChild(self.timerLabel)
      
      
      if motionEnabled {
        motionManager = CMMotionManager()
        motionManager!.startAccelerometerUpdates()
      }
      createSceneContent()
      contentCreated = true
      
      self.physicsWorld.contactDelegate = self
      // Minimum gravity needed to allow rocks that are collided with to continue off screen
      self.physicsWorld.gravity = CGVector(dx: 0, dy: -1.5)
      
      
      
    }
  }
  
  /**
   *  Processes the motion from the accelerometer
   *
   *  @param NSTimeInterval The time interval since the last update
   *
   *  @return Void
   */
  func processUserMotionForUpdate(_ currentTimeInterval: TimeInterval) {
    
    if self.shouldAcceptFurtherCollisions {
      let ship = self.childNode(withName: "PlatypusBody")
      let data = self.motionManager?.accelerometerData
      
      if let datas = data {
        
        let positionY: Double = Double(ship!.position.y)
        let positionX: Double = Double(ship!.position.x)
        let accelerometerX: Double = datas.acceleration.x as Double * 15.0
        let accelerometerY: Double = datas.acceleration.y as Double * 15.0
        let height: Double = Double(self.frame.maxY)
        let width: Double = Double(self.frame.maxX)
        
        let horizontalNotNegative: Bool = positionX + accelerometerX >= 0.0
        let horizontalNotPastScreen: Bool = positionX + accelerometerX <= width
        let verticalNotNegative: Bool = positionY + accelerometerY >= 0.0
        let verticalNotPastScreen: Bool = positionY + accelerometerY <= height
        
        let horizontal: Bool = horizontalNotNegative && horizontalNotPastScreen
        let vertical: Bool = verticalNotNegative && verticalNotPastScreen
        
        if horizontal && vertical {
          
          let newX = positionX + accelerometerX
          let newY = positionY + accelerometerY
          
          let newPostion = CGPoint(x: newX.CGFloatValue, y: newY.CGFloatValue)
          
          ship?.position = newPostion
          
        }
      }
    }
  }
  
  /**
   *  Creates the Scenes content
   *
   *  @return Void
   */
  func createSceneContent() {
    
    let platypus = PlatypusNode(type: platypusColor)
    platypus.position = CGPoint(x: self.frame.size.width / 2, y: 100)
    self.addChild(platypus)
    
    self.addRocks()
    self.timer.start()
    let makeRocks = SKAction.run({self.addPowerup()})
    let delay = SKAction.wait(forDuration: 10.0, withRange: 5.0)
    let sequence = SKAction.sequence([delay, makeRocks])
    let repeatStep = SKAction.repeatForever(sequence)
    
    self.run(repeatStep)
    let action = SKAction.playSoundFileNamed("scifi011.mp3", waitForCompletion: false)
    self.run(action)
    self.makeLifeBar()
    
  }
  
  /**
   *  Creates the life bar and displays it on screen
   *
   *  @return Void
   */
  func makeLifeBar() {
    
    let node = SKSpriteNode(imageNamed: "LifeBarFull")
    node.name = "lifeBar"
    if UIDevice.current.userInterfaceIdiom == .phone {
      //let width: CGFloat = self.view?.window?.frame.size.width!
      //let height: CGFloat = self.view?.window?.frame.size.height!
      if let view = self.view {
        if let window = view.window {
          let width = window.frame.width
          let height = window.frame.height
          node.position = CGPoint(x: width - 70, y: height - 30)
        }
      }
      
      
    } else {
      if let view = self.view {
        if let window = view.window {
          let width = window.frame.width
          let height = window.frame.height
          node.position = CGPoint(x: width - 70, y: height - 35)
        }
      }
      
    }
    self.addChild(node)
    
  }
  
  override func didSimulatePhysics() {
    
    let block: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = ({(node, stop) in
      if (node!.position.x) > self.frame.width + 10 || node!.position.x < -10 || node!.position.y < -10 {
        node!.removeFromParent()
      }
    })
    
    self.enumerateChildNodes(withName: "rock", using: block)
    
  }
  
  override func update(_ currentTime: TimeInterval) {
    
    if motionEnabled {
      self.processUserMotionForUpdate(currentTime)
    }
    
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    super.touchesBegan(touches, with: event)
    
    if self.slowMotion {
      self.slowMotion = false
    }
    
    if motionEnabled {
      return
    }
    
    if self.shouldAcceptFurtherCollisions {
      
      let hull = self.childNode(withName: "PlatypusBody")
      let touch: UITouch = touches.first!
      let move = SKAction.move(to: CGPoint(x: touch.location(in: self).x, y: touch.location(in: self).y + 50), duration:0.05);
      
      hull?.run(move)
      
    }
    
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    super.touchesMoved(touches, with: event)
    
    if motionEnabled {
      return
    }
    
    if self.shouldAcceptFurtherCollisions {
      
      let hull = self.childNode(withName: "PlatypusBody")
      let touch: UITouch = touches.first!
      let move = SKAction.move(to: CGPoint(x: touch.location(in: self).x, y: touch.location(in: self).y + 50), duration:0.05);
      
      hull?.run(move)
      
    }
    
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if self.shouldAcceptFurtherCollisions && !motionEnabled {
      self.slowMotion = true
    }
  }
  
  /**
   *  Creates an individual rock and applys an impulse to it
   *
   *  @return Void
   */
  func addRock() {
    let rock = SKSpriteNode(color: SKColor(red: 0.67647, green:0.51568, blue:0.29216, alpha:1.0), size: CGSize(width: 8, height: 8))
    
    let width: CGFloat = self.frame.width
    let widthAsDouble: Double = Double(width)
    let randomNum = randomNumberFunction(widthAsDouble)
    let randomNumAsCGFloat: CGFloat = CGFloat(randomNum)
    let point = CGPoint(x: randomNumAsCGFloat, y: self.frame.height)
    
    rock.position = point
    rock.name = "rock"
    rock.physicsBody = SKPhysicsBody(rectangleOf: rock.size)
    rock.physicsBody?.usesPreciseCollisionDetection = true
    rock.physicsBody?.categoryBitMask = ColliderType.rock.rawValue
    rock.physicsBody?.contactTestBitMask = ColliderType.rock.rawValue | ColliderType.shield.rawValue
    rock.physicsBody?.collisionBitMask = ColliderType.rock.rawValue | ColliderType.platypus.rawValue
    
    self.addChild(rock)
    rock.physicsBody?.applyImpulse(CGVector(dx: 0, dy: (self.slowMotion ? -0.125 : -0.75) * (self.impulseSlower ? 0.5 : 1.0) * (1.0 + (self.seconds.CGFloatValue / 65.0))))
    
    
  }
  
  /**
   *  Makes the stars in the scene background
   *
   *  @return Void
   */
  func makeStars() -> SKEmitterNode {
    
    let path = Bundle.main.path(forResource: "Stars", ofType: "sks")
    let stars: SKEmitterNode = NSKeyedUnarchiver.unarchiveObject(withFile: path!) as! SKEmitterNode
    stars.particlePosition = CGPoint(x: self.frame.midX, y: self.frame.maxY)
    stars.particlePositionRange = CGVector(dx: self.frame.width, dy: 0)
    stars.zPosition = -2
    stars.advanceSimulationTime(10.0)
    return stars
    
  }
  
  /**
   *  Creates a new action to continue adding rocks, recursively
   *
   *  @return Void
   */
  func addRocks() {
    if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
      var duration = self.slowMotion ? 1.36 - (Double(self.seconds) / 2000): 0.16 - (Double(self.seconds) / 2000)
      duration = duration > 0.075 ? duration : 0.075
      let makeRocks = SKAction.run({self.addRock()})
      let makeRocks2 = SKAction.run({self.addRocks()})
      let delay = SKAction.wait(forDuration: duration)
      let sequence = SKAction.sequence([makeRocks, delay, makeRocks2])
      self.run(sequence)
    } else {
      let duration = self.slowMotion ? 0.96 : 0.12
      let makeRocks = SKAction.run({self.addRock()})
      let makeRocks2 = SKAction.run({self.addRocks()})
      let delay = SKAction.wait(forDuration: duration)
      let sequence = SKAction.sequence([makeRocks, delay, makeRocks2])
      
      self.run(sequence)
    }
  }
  
  /**
   *  Creates a new random powerup and sets up a reaccuring action to continue making powerups
   *
   *  @return Void
   */
  func addPowerup() {
    
    var random = arc4random()
    let width: CGFloat = self.frame.width
    let widthAsDouble: Double = Double(width)
    let randomNum: Double = randomNumberFunction(widthAsDouble) as Double
    let randomNumAsCGFloat: CGFloat = randomNum.CGFloatValue
    let point = CGPoint(x: randomNumAsCGFloat, y: self.frame.height + 50)
    random = random % 3
    if random == 0 {
      let lifePowerup = SKSpriteNode(imageNamed: "healthPowerup")
      lifePowerup.position = point
      lifePowerup.name = "life"
      lifePowerup.physicsBody = SKPhysicsBody(rectangleOf: lifePowerup.size)
      lifePowerup.physicsBody?.usesPreciseCollisionDetection = true
      lifePowerup.physicsBody?.categoryBitMask = ColliderType.life.rawValue
      lifePowerup.physicsBody?.contactTestBitMask = ColliderType.platypus.rawValue
      lifePowerup.physicsBody?.collisionBitMask = ColliderType.platypus.rawValue
      lifePowerup.physicsBody?.usesPreciseCollisionDetection = true
      lifePowerup.physicsBody?.mass = 1
      if (!self.impulseSlower) {
        let vector = CGVector(dx: 0, dy: 0.0 - 3.0 - (self.level.CGFloatValue / 2.0))
        lifePowerup.physicsBody?.applyImpulse(vector)
      }
      else {
        let vector = CGVector(dx: 0, dy: -3.0)
        lifePowerup.physicsBody?.applyImpulse(vector)
      }
      self.addChild(lifePowerup)
      
      
    }
    if (random == 1) {
      let gravityPowerup = SKSpriteNode(imageNamed: "gravityPowerup")
      gravityPowerup.position = point
      gravityPowerup.name = "gravity"
      gravityPowerup.physicsBody = SKPhysicsBody(rectangleOf: gravityPowerup.size)
      gravityPowerup.physicsBody?.usesPreciseCollisionDetection = true
      gravityPowerup.physicsBody?.categoryBitMask = ColliderType.gravity.rawValue
      gravityPowerup.physicsBody?.contactTestBitMask = ColliderType.platypus.rawValue
      gravityPowerup.physicsBody?.collisionBitMask = ColliderType.platypus.rawValue
      gravityPowerup.physicsBody?.usesPreciseCollisionDetection = true
      gravityPowerup.physicsBody?.mass = 1
      if (!self.impulseSlower) {
        let vector = CGVector(dx: 0, dy: 0.0 - 3.0 - (self.level.CGFloatValue / 2.0))
        gravityPowerup.physicsBody?.applyImpulse(vector)
      }
      else {
        let vector = CGVector(dx: 0, dy: -3.0)
        gravityPowerup.physicsBody?.applyImpulse(vector)
      }
      self.addChild(gravityPowerup)
      
      
    }
    if (random == 2) {
      let invinciblePowerup = SKSpriteNode(imageNamed: "invinciblePowerup")
      invinciblePowerup.position = point
      invinciblePowerup.name = "invincible"
      invinciblePowerup.physicsBody = SKPhysicsBody(rectangleOf: invinciblePowerup.size)
      invinciblePowerup.physicsBody?.usesPreciseCollisionDetection = true
      invinciblePowerup.physicsBody?.categoryBitMask = ColliderType.shield.rawValue
      invinciblePowerup.physicsBody?.contactTestBitMask = ColliderType.platypus.rawValue
      invinciblePowerup.physicsBody?.collisionBitMask = ColliderType.platypus.rawValue
      invinciblePowerup.physicsBody?.usesPreciseCollisionDetection = true
      invinciblePowerup.physicsBody?.mass = 1
      if (!self.impulseSlower) {
        let vector = CGVector(dx: 0, dy: 0.0 - 3.0 - (self.level.CGFloatValue / 2.0))
        invinciblePowerup.physicsBody?.applyImpulse(vector)
      }
      else {
        let vector = CGVector(dx: 0, dy: -3.0)
        invinciblePowerup.physicsBody?.applyImpulse(vector)
      }
      self.addChild(invinciblePowerup)
      
    }
    
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    let bodyA = contact.bodyA
    let bodyB = contact.bodyB
    let typeA: ColliderType = ColliderType(rawValue: bodyA.categoryBitMask)!
    let typeB: ColliderType = ColliderType(rawValue: bodyB.categoryBitMask)!
    
    if (typeA == ColliderType.rock) && (typeB == ColliderType.rock) {
      bodyA.node?.addChild(self.newSpark())
      bodyB.node?.addChild(self.newSpark())
    } else if (typeA == .rock || typeB == .rock) && (typeA != .platypus && typeB != .platypus) {
      bodyA.node?.addChild(self.newSpark())
      bodyB.node?.addChild(self.newSpark())
    } else if (typeA == .rock || typeB == .rock) && (typeA == .platypus || typeB == .platypus) {
      typeA == .rock ? bodyA.node?.addChild(newSpark()) : bodyB.node?.addChild(newSpark())
      if !self.invincible {
        hits += 1
        self.userFeedback()
        if hits < 3 {
          self.handleInvincibility()
          let action = SKAction.playSoundFileNamed("Clank.mp3", waitForCompletion: false)
          self.run(action)
        } else {
          let action = SKAction.playSoundFileNamed("Grenade.mp3", waitForCompletion: false)
          self.run(action)
          self.shouldAcceptFurtherCollisions = false
          self.shouldMakeMoreRocks = false
        }
      }
    } else if (typeA == .life || typeB == .life) && (typeA == .platypus || typeB == .platypus) {
      hits -= 1
      typeA == .life ? bodyA.node?.removeFromParent() : bodyB.node?.removeFromParent()
      let action = SKAction.playSoundFileNamed("Servo Movement 02.mp3", waitForCompletion: false)
      self.run(action)
    } else if (typeA == .gravity || typeB == .gravity) && (typeA == .platypus || typeB == .platypus) {
      self.handleSlow()
      let action = SKAction.playSoundFileNamed("Servo Movement 02.mp3", waitForCompletion: false)
      self.run(action)
      typeA == .gravity ? bodyA.node?.removeFromParent() : bodyB.node?.removeFromParent()
    } else if (typeA == .shield || typeB == .shield) && (typeA == .platypus || typeB == .platypus) {
      self.handleInvincibility()
      let action = SKAction.playSoundFileNamed("Servo Movement 02.mp3", waitForCompletion: false)
      self.run(action)
      typeA == .shield ? bodyA.node?.removeFromParent() : bodyB.node?.removeFromParent()
    }
    
    
    
  }
  
  func userFeedback() {
    
    let node = SKShapeNode(rectOf: self.frame.size)
    node.fillColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.25 * CGFloat(hits))
    node.strokeColor = UIColor.red
    node.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
    self.addChild(node)
    let action = SKAction.fadeAlpha(to: 0, duration: 0.5)
    node.run(action)
    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    
  }
  
  /**
   *  Implements the functionality of the gravity powerup
   *
   *  @return Void
   */
  func handleSlow() {
    self.impulseSlower = true
    let block = SKAction.run({self.impulseSlower = false})
    let delay = SKAction.wait(forDuration: 6.0)
    let sequence = SKAction.sequence([delay, block])
    self.run(sequence)
    
    
  }
  
  /**
   *  Creates a new spark
   *
   *  @return Void
   */
  func newSpark() -> SKEmitterNode {
    let path = Bundle.main.path(forResource: "spark", ofType: "sks")
    let node: SKEmitterNode = NSKeyedUnarchiver.unarchiveObject(withFile: path!) as! SKEmitterNode
    return node
  }
  
  /**
   *  Sets the inviniciblity status and causes the platypus to fade in and out
   *
   *  @return Void
   */
  func handleInvincibility() {
    self.invincible = true
    let node = self.childNode(withName: "PlatypusBody") as! SKSpriteNode
    let fadeout = SKAction.fadeOut(withDuration: 0.25)
    let fadeIn = SKAction.fadeIn(withDuration: 0.25)
    let block = SKAction.run({self.invincible = false})
    let sequence = SKAction.sequence([fadeout, fadeIn, fadeout, fadeIn, fadeout, fadeIn, fadeout, fadeIn, fadeout,fadeIn, fadeout, fadeIn, block])
    node.run(sequence)
    
  }
  
  /**
   *  Handles the game over sequence
   *
   *  @return Void
   */
  func gameOver() {
    
    var point: CGPoint
    if let pointTwo = self.childNode(withName: "PlatypusBody")?.position {
      point = pointTwo
    }
    else {
      point = CGPoint.zero
    }
    self.timer.stop()
    self.removeAllActions()
    self.removeAllChildren()
    self.addChild(self.stars)
    self.stars.advanceSimulationTime(6.0)
    let path = Bundle.main.path(forResource: "MyExplosion", ofType: "sks")
    let node = NSKeyedUnarchiver.unarchiveObject(withFile: path!) as! SKEmitterNode
    node.position = point
    
    if seconds > recordHighScore {
      recordHighScore = seconds
    }
    
    numberOfGamesPlayed += 1
    
    averageScore = ((averageScore * Double(numberOfGamesPlayed - 1)) + Double(seconds)) / Double(numberOfGamesPlayed)
    
    timeSpentPlaying += seconds
    
    self.addChild(node)
    
    let label = SKLabelNode(fontNamed: "Helvetica")
    label.text = self.timerLabel.text
    label.fontSize = 36
    label.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
    label.isHidden = true
    label.name = "label"
    let finalBlock: () -> () = ({
      
      let scene = WelcomeScene(size: self.size)
      let transition = SKTransition.doorsCloseHorizontal(withDuration: 0.5)
      self.scene?.view?.presentScene(scene, transition: transition)
      
    })
    self.addChild(label)
    let delay = SKAction.wait(forDuration: 1.0)
    
    let actionBlock: (Int, Int) -> ()->() = {(one: Int, two: Int) -> ()->() in
      self.childNode(withName: String("label"))?.isHidden = false
      return ({()->Void in return})
    }
    
    let block = SKAction.run(actionBlock(2, 3))
    let delay2 = SKAction.wait(forDuration: 2.0)
    let block2 = SKAction.run(finalBlock)
    let sequence = SKAction.sequence([delay, block, delay2, block2])
    self.run(sequence)
  }
  
}
