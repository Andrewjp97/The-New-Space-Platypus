//
//  PlatypusNode.swift
//  Space Platypus
//
//  Created by Andrew Paterson on 6/21/14.
//  Copyright (c) 2014 Karl Paterson. All rights reserved.
//

import UIKit
import SpriteKit

class PlatypusNode: SKSpriteNode {
  
  /**
   *  The Type of the Platypus, is an optional value
   */
  var type: kPlatypusColor?
  
  override init(texture: SKTexture!, color: UIColor, size: CGSize) {
    super.init(texture: texture, color: color, size: size)
  }
  
  /**
   *  Designated Initializer for a PlatypusNode
   *
   *  @param The Type of PlatypusNode to be made, changes the image displayed and any special effects
   */
  init(type: kPlatypusColor) {
    
    super.init(texture: nil, color: UIColor.clear, size: CGSize.zero)
    self.texture = SKTexture(imageNamed: imageNameForPlatypusColor(type))
    if let texture = self.texture {
      self.size = texture.size()
    }
    self.type = type
    
    self.name = "PlatypusBody"
    
    self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
    self.physicsBody?.isDynamic = false
    self.physicsBody?.contactTestBitMask = ColliderType.rock.rawValue | ColliderType.life.rawValue
    self.physicsBody?.categoryBitMask = ColliderType.platypus.rawValue
    self.physicsBody?.collisionBitMask = ColliderType.rock.rawValue
    
    if type == kPlatypusColor.kPlatypusColorFire {
      
      let path = Bundle.main.path(forResource: "bodyOnFire", ofType: "sks")
      let flame: SKEmitterNode = NSKeyedUnarchiver.unarchiveObject(withFile: path!) as! SKEmitterNode
      flame.position = self.position
      flame.zPosition = 9
      self.addChild(flame)
      
    }
    
    let eyeOne = newEye()
    eyeOne.position = CGPoint(x: -10, y: 16)
    eyeOne.zPosition = 100
    self.addChild(eyeOne)
    
    let eyeTwo = newEye()
    eyeTwo.position = CGPoint(x: 10, y: 16)
    eyeTwo.zPosition = 100
    self.addChild(eyeTwo)
    
    let path = Bundle.main.path(forResource: "MyParticle", ofType: "sks")
    let exhaust: SKEmitterNode = NSKeyedUnarchiver.unarchiveObject(withFile: path!) as! SKEmitterNode
    exhaust.position = CGPoint(x: 0, y: -32)
    self.addChild(exhaust)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(texture: nil, color: UIColor.clear, size: CGSize.zero)
  }
  
  /**
   *  Creates a new eye, complete with blinking animation action
   *
   *  @return An SKSpriteNode that is an eye and blinks
   */
  func newEye() -> SKSpriteNode {
    
    let textures = [SKTexture(imageNamed: "EyeOpen"),
                    SKTexture(imageNamed: "EyeBlinking1"),
                    SKTexture(imageNamed: "EyeBlinking2"),
                    SKTexture(imageNamed: "EyeBlinking3"),
                    SKTexture(imageNamed: "EyeBlinking4"),
                    SKTexture(imageNamed: "EyeBlinking5"),
                    SKTexture(imageNamed: "EyeBlinking6"),
                    SKTexture(imageNamed: "EyeBlinking7"),
                    SKTexture(imageNamed: "EyeBlinking8"),
                    SKTexture(imageNamed: "EyeBlinking9"),
                    SKTexture(imageNamed: "EyeBlinking10"),
                    SKTexture(imageNamed: "EyeBlinking11"),
                    SKTexture(imageNamed: "EyeBlinking12"),
                    SKTexture(imageNamed: "EyeBlinking13"),
                    SKTexture(imageNamed: "EyeBlinking14"),
                    SKTexture(imageNamed: "EyeBlinking15"),
                    SKTexture(imageNamed: "EyeBlinking16"),
                    SKTexture(imageNamed: "EyeBlinking17"),
                    SKTexture(imageNamed: "EyeBlinking18"),
                    SKTexture(imageNamed: "EyeBlinking19")]
    
    let light = SKSpriteNode(imageNamed: "EyeOpen")
    
    let blinkClose = SKAction.animate(with: textures, timePerFrame: 0.005)
    
    let blink = SKAction.sequence([blinkClose, SKAction.wait(forDuration: 0.025),
                                   blinkClose.reversed(), SKAction.wait(forDuration: 3.0)])
    
    let blinkForever = SKAction.repeatForever(blink)
    
    light.run(blinkForever)
    
    return  light
    
  }
  
}
