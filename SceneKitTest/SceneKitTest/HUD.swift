//
//  HUD.swift
//  SceneKitTest
//
//  Created by Yousef Ahmed on 8/22/19.
//  Copyright © 2019 Rajat Mittal. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import UIKit

class HUD: SKScene {
    private var scoreLabel = SKLabelNode(fontNamed: "Helvetica Neue")
    private var score = 0  // Score variable
    private var timer:Timer?  // Creates optional of type Timer
    private var timeLeft = 60  //Variable used in timer for setting amount of time left
    private var isTheGamePaused = false
    let worldNode = SKNode()
    
    override func sceneDidLoad() {
        
        // THIS IS THE CODE FREEZING THE GAME!
        let scene = HUD(fileNamed:"HUD")
        let skView = self.view as! SKView
        skView.presentScene(scene)
        
        scoreLabel.text = ""
        scoreLabel.fontSize = 65
        scoreLabel.zPosition = 150
        scoreLabel.fontColor = SKColor.blue
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY * 3/4)
        
        self.addChild(scoreLabel)  // Adds the scoreLabel to the scene
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
        
        timer?.tolerance = 0.15 // Makes the timer more efficient
        
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common) // Helps UI stay responsive even with timer
        
        /*  The timer above is now initialized using a few key properties: the timeInterval is the interval in which the timer will update, target is where the timer will be applied, selector specifies a function to run when the timer updates based on the time interval, userInfo can supply information to the selector function, and repeats allows the timer to run continuously until invalidated.
         */
        
        addChild(worldNode)
    }
    
    /*  The function below is visible in objective-c since the selector is an obj-c concept. The timeLeft variable is deprecated by 1 referencing one second passing. The label is updated, and once the timeLeft variable reaches 0, the timer is invalidated and the label is updated to reflect the game being over.
     */
    
    @objc func onTimerFires() {
        timeLeft -= 1
        scoreLabel.text = "\(timeLeft) sec left  Score: " + String(2) + "  Cars Hit: " + String(0)
        
        if timeLeft <= 0 {
            timer?.invalidate()
            timer = nil
           // gameOverScreen()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
    
    }
}
