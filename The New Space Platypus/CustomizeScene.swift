//
//  CustomizeScene.swift
//  Space Platypus Swift
//
//  Created by Andrew Paterson on 6/5/14.
//  Copyright (c) 2017 Andrew Paterson. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit



class CustomizeScene: SKScene {
  
  /**
   *  The Child of the customize scene: an optional value
   */
  var child: CustomizeScene?
  /**
   *  The Parent of the customize scene: an optional value
   */
  var parentScene: CustomizeScene?
  /**
   *  An array of platypus types
   */
  var platypusTypes: [kPlatypusColor] = []
  /**
   *  Whether the scene's content has been created yet
   */
  var contentCreated: Bool = false
  
  /**
   *  The designated initializer for a customize scene: recursize: creates as many children as necessary to hold all the platypus types passed in and links them together
   *
   *  @param CGSize            The size of the scene
   *  @param [kPlatypusColor]  An array of platypus colors
   *  @param CustomizeScene?   The scenes parrent if it has one
   *
   *  @return Void
   */
  init(size: CGSize, platypusTypes: [kPlatypusColor], parent: CustomizeScene? = nil) {
    
    
    // Call Superclass initializer
    super.init(size: size)
    
    
    // If the parent optional has a value, unwrap it and assign it to self
    if parent != nil {
      self.parentScene = parent!
    }
    
    
    // If there are more than 6 types of platypus to display, count out the first six and keep them
    // then send the rest to a new instance and call it our child.  (Like a doubly linked list data structure)
    if platypusTypes.count > 6
    {
      var subarray: [kPlatypusColor] = []
      var counter: Int = 0
      for platypusType in platypusTypes {
        if counter < 6 {
          counter += 1
          self.platypusTypes.append(platypusType)
        } else {
          subarray.append(platypusType)
          counter += 1
        }
      }
      
      self.child = CustomizeScene(size: size, platypusTypes: subarray, parent: self)
      
    } else {
      self.platypusTypes = platypusTypes
    }
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func didMove(to view: SKView) {
    if !self.contentCreated {
      self.layoutPlatapi()
      self.backgroundColor = SKColor.black
      self.makeStars()
      
      let arrowTuple = self.makeAppropriateArrows()
      if let right = arrowTuple.rightArrow {
        self.addChild(right)
      }
      if let left = arrowTuple.leftArrow {
        self.addChild(left)
      }
      
      self.contentCreated = true
    }
  }
  
  /**
   *  Creates the correct arrows depending upon whether or not the scene has a parent or child scene
   *
   *  @return The right arrow as an optional value
   *  @return The left arrow as an optional value
   */
  func makeAppropriateArrows() -> (rightArrow: SKSpriteNode?, leftArrow: SKSpriteNode?) {
    var rightArrow: SKSpriteNode?
    var leftArrow: SKSpriteNode?
    
    if self.child != nil {
      let node = SKSpriteNode(imageNamed: "rightArrow")
      node.position = CGPoint(x: self.frame.midX + 100, y: 80)
      if UIDevice.current.userInterfaceIdiom == .pad {
        node.position = CGPoint(x: self.frame.midX + 100, y: 300)
      }
      node.name = "rightArrow"
      rightArrow = node
      
    }
    
    if self.parentScene != nil {
      let node = SKSpriteNode(imageNamed: "leftArrow")
      node.position = CGPoint(x: self.frame.midX - 100, y: 80)
      if UIDevice.current.userInterfaceIdiom == .pad {
        node.position = CGPoint(x: self.frame.midX - 100, y: 300)
      }
      node.name = "leftArrow"
      leftArrow = node
    }
    
    return (rightArrow, leftArrow)
  }
  
  /**
   *  Iterates over the platypusTypes array and lays out each platypus.
   *
   *  @return Void
   */
  func layoutPlatapi() {
    var index = 0
    for type in self.platypusTypes {
      let node: SKSpriteNode = PlatypusNode(type: type)
      switch index {
      case 0:
        node.position = CGPoint(x: self.frame.midX-80, y: self.frame.midY + 150)
      case 1:
        node.position = CGPoint(x: self.frame.midX+80, y: self.frame.midY + 150)
      case 2:
        node.position = CGPoint(x: self.frame.midX-80, y: self.frame.midY + 30)
      case 3:
        node.position = CGPoint(x: self.frame.midX+80, y: self.frame.midY + 30)
      case 4:
        node.position = CGPoint(x: self.frame.midX-80, y: self.frame.midY - 90)
      case 5:
        node.position = CGPoint(x: self.frame.midX+80, y: self.frame.midY - 90)
      default:
        node.position = CGPoint.zero
      }
      self.addChild(node)
      index += 1
    }
    
    let node = SKLabelNode(fontNamed: "Helvetica")
    node.text = "Back"
    node.name = "back"
    node.fontColor = SKColor.white
    node.fontSize = 24
    node.position = CGPoint(x: 10 + (0.5 * node.frame.size.width), y: self.frame.maxY - 30 - (0.5 * node.frame.size.height))
    if UIDevice.current.userInterfaceIdiom == .pad {
      node.position = CGPoint(x: 20 + (0.5 * node.frame.size.width), y: self.frame.maxY - 40 - (0.5 * node.frame.size.height))
    }
    self.addChild(node)
    
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    self.enumerateChildNodes(withName: "PlatypusBody", using: {(node, stop) in
      let touch = touches.first!
      if (node.contains(touch.location(in: self))) {
        self.highlightNode(node as! PlatypusNode)
        return
      }
    })
    
    let leftArrowBlock: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = ({(node, stop) in
      let touch = touches.first!
      if (node?.contains(touch.location(in: self)))! {
        let transition = SKTransition.push(with: SKTransitionDirection.right, duration: 0.25)
        self.scene?.view!.presentScene(self.parentScene!, transition: transition)
        return
      }
    })
    
    self.enumerateChildNodes(withName: "leftArrow", using: leftArrowBlock)
    
    let rightArrowBlock: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = ({(node, stop) in
      let touch = touches.first!
      if (node?.contains(touch.location(in: self)))! {
        let transition = SKTransition.push(with: SKTransitionDirection.left, duration: 0.25)
        self.scene?.view!.presentScene(self.child!, transition: transition)
        return
      }
    })
    
    self.enumerateChildNodes(withName: "rightArrow", using: rightArrowBlock)
    
    let backButtonBlock: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = ({(node, stop) in
      let touch = touches.first!
      if (node?.contains(touch.location(in: self)))! {
        let transition = SKTransition.doorsCloseVertical(withDuration: 0.5)
        self.scene?.view!.presentScene(WelcomeScene(size: self.size), transition: transition)
      }
    })
    
    self.enumerateChildNodes(withName: "back", using: backButtonBlock)
  }
  
  /**
   *  Highlights a specific platypus node to queue the user into their selection
   *
   *  @param PlatypusNode The Node to be highlighted
   *
   *  @return Void
   */
  func highlightNode(_ node: PlatypusNode) {
    if let color = node.type {
      platypusColor = color
    }
    if let node = self.child {
      node.unhighlightAnyNodes(true)
    }
    if let node = self.parentScene {
      node.unhighlightAnyNodes(false)
    }
    let block: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = ({ (node, stop) in node!.removeFromParent() })
    self.enumerateChildNodes(withName: "selection", using: block)
    let selection = SKSpriteNode(imageNamed: "BackgroundSelected")
    selection.name = "selection"
    selection.position = node.position
    selection.position.y = selection.position.y - 20
    selection.zPosition = node.zPosition - 1
    self.addChild(selection)
  }
  
  /**
   *  Ensures that all children / parents deselect thier platypus when a new one is selected
   *
   *  @param Bool Should send message to children, otherwise it will be sent to parents
   *
   *  @return Void
   */
  func unhighlightAnyNodes(_ sendToChild: Bool) {
    let block: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = ({(node, stop) in node!.removeFromParent() })
    self.enumerateChildNodes(withName: "selection", using: block)
    // Recursion: if this message came from a parent, we want to send it down the chain of children
    if sendToChild {
      if let node = self.child {
        node.unhighlightAnyNodes(true)
      }
    }   // Otherwise we want to send it up the chain of parents
    else {
      if let node = self.parentScene {
        node.unhighlightAnyNodes(false)
      }
    }
    
  }
  
  /**
   *  Makes the stars in the background
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
  
}


