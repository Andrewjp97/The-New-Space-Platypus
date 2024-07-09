//
//  OptionsScene.swift
//  Space Platypus Swift
//
//  Created by Andrew Paterson on 6/5/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit

class OptionsScene: SKScene {

    /**
    *  Value of whether or not the scene content has been created yet
    */
    var contentCreated: Bool = false

    override func didMove(to view: SKView) {

        if !self.contentCreated {
            self.makeStars()
            self.backgroundColor = SKColor.black
            

            let buttonTuple = self.createButton()
            self.addChild(buttonTuple.button)
            buttonTuple.text.name = "text"
            self.addChild(buttonTuple.text)

            self.addChild(self.createBackButton())
            
            let avgLable = SKLabelNode(text: String("Average Score " + String(format: "%d", (averageScore - (averageScore.truncatingRemainder(dividingBy: 60))) / 60) + ":" + String(format: "%02.1f", averageScore.truncatingRemainder(dividingBy: 60))))
            avgLable.fontName = "Helvetica"
            avgLable.fontColor = SKColor.white
            avgLable.fontSize = 20
            avgLable.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 90)
            self.addChild(avgLable)
            
            let gamesPlayedLabel = SKLabelNode(text: String("Games Played " + String(format: "%d", numberOfGamesPlayed)))
            gamesPlayedLabel.fontName = "Helvetica"
            gamesPlayedLabel.fontColor = SKColor.white
            gamesPlayedLabel.fontSize = 20
            gamesPlayedLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 120)
            self.addChild(gamesPlayedLabel)
            
            let scoreLabel = SKLabelNode(text: String("High Score " + String(format: "%d:", (recordHighScore - (recordHighScore % 60)) / 60) + String(format: "%2d", recordHighScore % 60)))
            scoreLabel.fontSize = 20
            scoreLabel.fontColor = SKColor.white
            scoreLabel.fontName = "Helvetica"
            scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 150)
            self.addChild(scoreLabel)
            
            let timeLabel = SKLabelNode(text: String("Time Spent Playing " + String(format: "%d", (timeSpentPlaying - (timeSpentPlaying % 60)) / 60) + String(format: ":%2d", timeSpentPlaying % 60)))
            timeLabel.fontName = "Helvetica"
            timeLabel.fontSize = 20
            timeLabel.fontColor = SKColor.white
            timeLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 180)
            self.addChild(timeLabel)
            
            self.contentCreated = true
        }

    }

    /**
    *  Creates a fully formed instance of a back button text label
    *
    *  @return The fully formed back button label
    */
    func createBackButton() -> SKLabelNode {
        
        let backButton = SKLabelNode(fontNamed: "Helvetica")
        backButton.text = "Back"
        backButton.name = "back"
        backButton.fontColor = SKColor.white
        backButton.fontSize = 24
        backButton.position = CGPoint(x: 10 + (0.5 * backButton.frame.size.width), y: self.frame.maxY - 20 - (0.5 * backButton.frame.size.height))
        
        return backButton
        
    }
    
    /**
    *  A Function to create a large button that's color dpends upon the global motion variable and whose text depends upon the global motion variable
    *
    *  @return The button portion of the button
    *  @return The text portion of the button
    */
    func createButton() -> (button: SKSpriteNode, text: SKLabelNode) {
        
        // If motion is enabled, make the button green.  Otherwise, make it red.

        let node = SKSpriteNode(color: motionEnabled ? SKColor.green : SKColor.red,size: CGSize(width: 250, height: 100))
        node.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        node.name = "button"
        
        let text = SKLabelNode(fontNamed: "Helvetica")
        text.text = motionEnabled ? "Motion Control Enabled" : "Motion Control Disabled"
        text.fontColor = SKColor.white
        text.zPosition = node.zPosition + 1
        text.fontSize = 20
        text.name = "text"
        text.position = node.position
        text.position.y = text.position.y - 10
        
        return (node, text)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        let block: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = ({(node, stop) in
            let touch = touches.first!
            if (node?.contains(touch.location(in: self)))! {
                node?.removeFromParent()
                let name = "text"
                var sprite: SKNode
                if let tempSprite = self.childNode(withName: name) {
                    sprite = tempSprite
                }
                else {
                    sprite = SKNode()
                }
                let arr = [sprite]
                self.removeChildren(in: arr)

                motionEnabled = !motionEnabled

                let newNode = SKSpriteNode(color: motionEnabled ? SKColor.green : SKColor.red,
                    size: CGSize(width: 250, height: 100))
                newNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                newNode.name = "button"

                let text = SKLabelNode(fontNamed: "Helvetica")
                text.text = motionEnabled ? "Motion Control Enabled" : "Motion Control Disabled"
                text.fontColor = SKColor.white
                text.zPosition = newNode.zPosition + 1
                text.fontSize = 20
                text.name = "text"
                text.position = (node?.position)!
                text.position.y = text.position.y - 10

                self.addChild(text)
                self.addChild(newNode)
                return

            }

            })

        self.enumerateChildNodes(withName: "button", using: block)

        let backButtonBlock: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = ({(node, stop) in
            let touch = touches.first!
            if (node?.contains(touch.location(in: self)))! {
                let transition = SKTransition.doorsCloseVertical(withDuration: 0.5)
                self.scene?.view?.presentScene(WelcomeScene(size: self.size), transition: transition)
            }
            })

        self.enumerateChildNodes(withName: "back", using: backButtonBlock)


    }

    /**
    *  Creates The Stars in the background
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
