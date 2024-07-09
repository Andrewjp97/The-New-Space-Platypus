//
//  WelcomeScene.swift
//  Space Platypus Swift
//
//  Created by Andrew Paterson on 6/4/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//

import SpriteKit
import GameKit
import iAd
import AudioToolbox
import AVFoundation

/**
*  The enumeration for the different menu item types
*/
enum menuItemType: Int {
    case kMenuItemTypePlay = 1,//Play Butten
    kMenuItemTypeCustomize,  //Customize Button
//   // TODO: DELETE:  kMenuItemTypeScores,  //Scores Button, brings up game center view
////    kMenuItemTypeAchievements,  //Achievments Button, brings up game center view
   kMenuItemTypeOptions,  //Options Button
    kMenuItemTypeInvalid  //Touch is outside valid range
}

enum identifierString: String {
    case general = "com.patersontech.combinedScores",
    phoneOnly = "co.patersontech.iPhone",
    padOnly = "co.patersontech.iPad",
    motion = "co.patersontech.combinedMotion",
    motionPhoneOnly = "co.patersontech.iPhoneMotion",
    motionPadOnly = "co.patersontech.iPadMotion"
}

/**
*  The enumeration for the collision types
*/
enum ColliderType: UInt32 {
    case rock = 1
    case life = 2
    case platypus = 4
    case gravity = 8
    case shield = 16
}


var lastRandom: Double = 0

/**
*  A random number generator
*
*  @param Double The Maximum allowable value
*
*  @return The random number
*/
func randomNumberFunction(_ max: Double) -> Double {
    if lastRandom == 0 {
        lastRandom = Date.timeIntervalSinceReferenceDate
    }
    let newRand =  ((lastRandom * Double.pi) * 11048.6954).truncatingRemainder(dividingBy: max)
    lastRandom = newRand
    return newRand
}

class WelcomeScene: SKScene, SKPhysicsContactDelegate {
    
    var contentCreated: Bool = false
    var player: AVAudioPlayer = AVAudioPlayer()
   
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    
    
    
    override func didMove(to view: SKView) {
                
        if !contentCreated {
            
            self.createSceneContent()
            contentCreated = true
            
            UIApplication.shared.statusBarStyle = .lightContent
            self.view?.isUserInteractionEnabled = true
            
            self.physicsWorld.contactDelegate = self
            
        }
        
        // Prepare banner Ad
        
        
        
        
        
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        let touch = touches.first!
        let point = touch.location(in: self)
        
        let menuItemType = whatMenuItemTypeIsAtPoint(point)
        
        switch menuItemType {
            
        case .kMenuItemTypePlay:
            let helloNode = self.childNode(withName: "HelloNode")
            if helloNode != nil {
                helloNode?.name = nil
                let zoom = SKAction.scale(to: 0.05, duration: 0.25)
                let fade = SKAction.fadeOut(withDuration: 0.25)
                let remove = SKAction.removeFromParent()
                let sequence = SKAction.sequence([zoom, fade, remove])
                helloNode?.run(sequence, completion: ({
                    let scene = GameScene(size: self.size)
                    let doors = SKTransition.doorsOpenVertical(withDuration: 0.25)
                    self.view?.presentScene(scene, transition: doors)
                }))
            }
        case .kMenuItemTypeCustomize:
            let scene = CustomizeScene(size: self.size,
                platypusTypes: [.kPlatypusColorDefault, .kPlatypusColorRed, .kPlatypusColorYellow,
                    .kPlatypusColorGreen, .kPlatypusColorPurple, .kPlatypusColorPink,
                    .kPlatypusColorDareDevil, .kPlatypusColorSanta, .kPlatypusColorElf,
                    .kPlatypusColorChirstmasTree, .kPlatypusColorRaindeer, .kPlatypusColorFire])
            
            let doors = SKTransition.doorsOpenVertical(withDuration: 0.5)
            self.view?.presentScene(scene, transition: doors)
     // TODO: DELETE:    case .kMenuItemTypeScores:
         // TODO: DELETE:    EasyGameCenter.showGameCenterLeaderboard(completion: identifierString.general.rawValue)
        // TODO: DELETE: case .kMenuItemTypeAchievements:
         // TODO: DELETE:        self.showAchievements()
            case .kMenuItemTypeOptions:
                let scene = OptionsScene(size: self.size)
                let doors = SKTransition.doorsOpenVertical(withDuration: 0.5)
                self.view?.presentScene(scene, transition: doors)
            case .kMenuItemTypeInvalid:
                return

        }

    }

    /**
    *  Checks for rocks offscreen and removes them
    *
    *  @return Void
    */
    override func didSimulatePhysics() {

        let completionBlock: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = {incoming, stop in

            if let node = incoming {

                if node.position.y < 0 || node.position.y > self.frame.maxY + 100 || node.position.x < 0 || node.position.x > self.frame.maxX {

                    node.removeFromParent()

                }
            }
        }

        self.enumerateChildNodes(withName: "rock", using: completionBlock)

    }

// // TODO: DELETE:    /**
//    *  The Game Center Delegate Callback Method: Called when the controller is dismissed
//    *
//    *  @param GKGameCenterViewController! The controller being dismissed
//    *
//    *  @return Void
//    */
//    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController!) {
//
//        self.view?.window?.rootViewController?.dismiss(animated: true, completion: nil)
//
//    }

    /**
    *  Creates the scene content
    *
    *  @return Void
    */
    func createSceneContent() {

        self.backgroundColor = SKColor.black
        self.scaleMode = SKSceneScaleMode.aspectFit

        self.makeStars()
        self.makeMenuNodes()
        
        let platypus = PlatypusNode(type: platypusColor)
        platypus.position  = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 100)
        self.addChild(platypus)
        
        self.playSpaceship()
        self.addRocks()

    }

    /**
    *  Runs a sequence of actions that move the platypus around on the scene
    *
    *  @return Void
    */
    func playSpaceship() {

        let action1 = SKAction.move(by: CGVector(dx: 85, dy: 10.0), duration: 0.5)
        let action2 = SKAction.move(by: CGVector(dx: -50.0, dy: -50.0), duration: 1.0)
        let action3 = SKAction.move(by: CGVector(dx: -130.0, dy: -50.0), duration: 0.75)
        let action4 = SKAction.move(by: CGVector(dx: -5.0, dy: 30.0), duration: 0.75)
        let action5 = SKAction.move(by: CGVector(dx: 75.0, dy: 20.0), duration: 0.5)
        let action6 = SKAction.move(by: CGVector(dx: 35.0, dy: 25.0), duration: 1.0)
        let action7 = SKAction.move(by: CGVector(dx: 10.0, dy: -10.0), duration: 0.5)
        let action8 = SKAction.move(by: CGVector(dx: 55.0, dy: 50.0), duration: 0.25)
        let sequence = SKAction.sequence([action1, action2, action3, action4,
                                          action5, action6, action7, action6,
                                          action5, action4, action3, action2, action8])
        let repeatStep = SKAction.repeatForever(sequence)

        let platypus = self.childNode(withName: "PlatypusBody")
        platypus?.run(repeatStep)
        
    }

    /**
    *  Creates and adds a rock to the scene at a random point along the top of the screen and applies an impulse to it
    *
    *  @return Void
    */
    func addRock() {
        let rock = SKSpriteNode(color: SKColor(red: 0.67647, green:0.51568, blue:0.29216, alpha:1.0), size: CGSize(width: 8, height: 8))

        let width: CGFloat = self.frame.width
        let widthAsDouble: Double = Double(width)
        let randomNum = randomNumberFunction(widthAsDouble)
        let randomNumAsCGFloat: CGFloat = randomNum.CGFloatValue
        let point = CGPoint(x: randomNumAsCGFloat, y: self.frame.height)

        rock.position = point
        rock.name = "rock"
        rock.physicsBody = SKPhysicsBody(rectangleOf: rock.size)
        rock.physicsBody?.usesPreciseCollisionDetection = true
        rock.physicsBody?.categoryBitMask = ColliderType.rock.rawValue
        rock.physicsBody?.contactTestBitMask = ColliderType.rock.rawValue | ColliderType.shield.rawValue
        rock.physicsBody?.collisionBitMask = ColliderType.rock.rawValue | ColliderType.platypus.rawValue
        self.addChild(rock)
        rock.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -0.75))


    }

    /**
    *  Creates the stars in the scene's background
    *
    *  @return Void
    */
    func makeStars() {

        let path = Bundle.main.path(forResource: "Stars", ofType: "sks")
        let stars: SKEmitterNode = NSKeyedUnarchiver.unarchiveObject(withFile: path!) as! SKEmitterNode
        stars.particlePosition = CGPoint(x: self.frame.midX, y: self.frame.maxY)
        stars.particlePositionRange = CGVector(dx: self.frame.width, dy: 0)
        stars.zPosition = -2
        self.addChild(stars)
        stars.advanceSimulationTime(10.0)

    }

    /**
    *  Creates the menu nodes for the scene
    *
    *  @return Void
    */
    func makeMenuNodes() {

        let helloNode = SKLabelNode()
        helloNode.fontName = "Menlo-BoldItalic"
        helloNode.text = "Space Platypus"
        helloNode.fontSize = 32
        helloNode.position = CGPoint(x: self.frame.midX + 8, y: self.frame.midY + 57)
        helloNode.name = "HelloNode"
        helloNode.zPosition = 19
        helloNode.fontColor = SKColor.darkGray
        
        let helloNode111 = SKLabelNode()
        helloNode111.fontName = "Menlo-BoldItalic"
        helloNode111.text = "The New"
        helloNode111.fontSize = 36
        helloNode111.position = CGPoint(x: self.frame.midX - 70, y: self.frame.midY + 96)
        helloNode111.name = "HelloNode"
        helloNode111.zPosition = 19
        helloNode111.fontColor = SKColor.darkGray
        self.addChild(helloNode111)
        
        let helloNode1111 = SKLabelNode()
        helloNode1111.fontName = "Menlo-BoldItalic"
        helloNode1111.text = "The New"
        helloNode1111.fontSize = 36
        helloNode1111.position = CGPoint(x: self.frame.midX - 73, y: self.frame.midY + 99)
        helloNode1111.name = "HelloNode"
        helloNode1111.zPosition = 19
        self.addChild(helloNode1111)

        let helloNode1 = SKLabelNode()
        helloNode1.fontName = "Menlo-BoldItalic"
        helloNode1.text = "Space Platypus"
        helloNode1.fontSize = 32
        helloNode1.position = CGPoint(x: self.frame.midX + 5, y: self.frame.midY + 60)
        helloNode1.name = "HelloNode"
        helloNode1.zPosition = 20

        let playNode = SKLabelNode()
        playNode.fontName = "Helvetica"
        playNode.text = "Play"
        playNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 0)
        playNode.fontColor = SKColor.red
        playNode.zPosition = 20
        
        let playBox = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 5)
        playBox.strokeColor = SKColor.red
        playBox.position = playNode.position
        playBox.position = CGPoint(x: playBox.position.x, y: playBox.position.y + 10)
        self.addChild(playBox)
        playBox.name = "playBox"

        let customizeNode = SKLabelNode()
        customizeNode.fontName = "Helvetica"
        customizeNode.text = "Customize"
        customizeNode.fontColor = SKColor.yellow
        customizeNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 62.5)
        customizeNode.zPosition = 20
        
        let customizeBox = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 5)
        customizeBox.strokeColor = SKColor.yellow
        customizeBox.position = customizeNode.position
        customizeBox.position = CGPoint(x: customizeBox.position.x, y: customizeBox.position.y + 10)
        self.addChild(customizeBox)
        customizeBox.name = "customizeBox"

//        var scoreNode = SKLabelNode()
//        scoreNode.fontName = "Helvetica"
//        scoreNode.text = "Scores"
//        scoreNode.fontColor = SKColor.greenColor()
//        scoreNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 108)
//        scoreNode.zPosition = 20
//
//        var achievementNode = SKLabelNode()
//        achievementNode.fontName = "Helvetica"
//        achievementNode.text = "Achievements"
//        achievementNode.fontColor = SKColor.blueColor()
//        achievementNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 144)
//        achievementNode.zPosition = 20

        let optionsNode = SKLabelNode()
        optionsNode.fontName = "Helvetica"
        optionsNode.text = "Options"
        optionsNode.fontColor = SKColor.green
        optionsNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 125)
        optionsNode.zPosition = 20

        let optionsBox = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 5)
        optionsBox.strokeColor = SKColor.green
        optionsBox.position = optionsNode.position
        optionsBox.position = CGPoint(x: optionsBox.position.x, y: optionsBox.position.y + 10)
        self.addChild(optionsBox)
        optionsBox.name = "optionsBox"
//        
//       TODO: DELETE: let scoreNode = SKLabelNode()
//        scoreNode.fontName = "Helvetica"
//        scoreNode.text = "Scores"
//        scoreNode.fontColor = SKColor.purple
//        scoreNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 187.5)
//        scoreNode.zPosition = 20
//        self.addChild(scoreNode)
        
//        let scoreBox = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 5)
//     // TODO: DELETE:    scoreBox.strokeColor = SKColor.purple
//        scoreBox.position = scoreNode.position
//        scoreBox.position = CGPoint(x: scoreBox.position.x, y: scoreBox.position.y + 10)
//        self.addChild(scoreBox)
//        scoreBox.name = "scoreBox"
        
        self.addChild(optionsNode)
//        self.addChild(achievementNode)
//        self.addChild(scoreNode)
        self.addChild(customizeNode)
        self.addChild(playNode)
        self.addChild(helloNode1)
        self.addChild(helloNode)

    }

    /**
    *  Shows the Game Center Leaderboards
  // TODO: DELETE:   *
    *  @return Void
    */
//    func showLeaderboard() {
//
//        let controller = GKGameCenterViewController()
//        controller.gameCenterDelegate = self;
//        controller.viewState = .leaderboards
//        self.view?.window?.rootViewController?.present(controller, animated: true, completion: nil)
//
//    }

//  // TODO: DELETE:   /**
//    *  Shows the Game Center Achievments
//    *
//    *  @return Void
//    */
//    func showAchievements() {
//
//        let controller = GKGameCenterViewController()
//        controller.gameCenterDelegate = self
//        controller.viewState  = .achievements
//        self.view?.window?.rootViewController?.present(controller, animated: true, completion: nil)
//
//    }

    /**
    *  Creates the falling rocks in the scene: creates a repeating action to make rocks
    *
    *  @return Void
    */
    func addRocks() {
        
            let duration = 0.10
            let makeRocks = SKAction.run({self.addRock()})
            let delay = SKAction.wait(forDuration: duration)
            let sequence = SKAction.sequence([makeRocks, delay])
            let repeatStep = SKAction.repeatForever(sequence)

            self.run(repeatStep)
        
    }

    /**
    *  Determines what, if any menu item is at the given point
    *
    *  @param CGPoint The point to check
    *
    *  @return The type of menu item present, returns kMenuItemTypeInvalid if no menu item is present at the given point
    */
//    func whatMenuItemTypeIsAtPoint(point: CGPoint) -> menuItemType {
//
//        let midScreenY = CGRectGetMidY(self.frame)
//        
//        if point.y > (midScreenY - 75) && point.y < (midScreenY - 25) {
//            return .kMenuItemTypePlay
//        } else if point.y > (midScreenY - 137.5) && point.y < (midScreenY - 87.5) {
//            return .kMenuItemTypeCustomize
////        } else if point.y > (midScreenY - 126) && point.y < (midScreenY - 90) {
////            return .kMenuItemTypeScores
////        } else if point.y > (midScreenY - 162) && point.y < (midScreenY - 126) {
////            return .kMenuItemTypeAchievements
//        } else if point.y > (midScreenY - 175) && point.y < (midScreenY - 137.6) {
//            return .kMenuItemTypeOptions
//        } else {
//            return .kMenuItemTypeInvalid
//        }
//    }

    func whatMenuItemTypeIsAtPoint(_ point: CGPoint) -> menuItemType {
        
        if self.childNode(withName: "playBox")!.contains(point) {
            return .kMenuItemTypePlay
        }
        else if self.childNode(withName: "customizeBox")!.contains(point) {
            return .kMenuItemTypeCustomize
        }
        else if self.childNode(withName: "optionsBox")!.contains(point) {
            return .kMenuItemTypeOptions
        }
        // TODO: DELETE: else if self.childNode(withName: "scoreBox")!.contains(point) {
        // TODO: DELETE:     return .kMenuItemTypeScores
       // TODO: DELETE:  }
        else {
            return .kMenuItemTypeInvalid
        }
        
    }
    
}












