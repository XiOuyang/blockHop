//
//  GameScene.swift
//  Block Hop
//
//  Created by Xi Stephen Ouyang on 7/5/16.
//  Copyright (c) 2016 Make School. All rights reserved.
//

import SpriteKit


class GameScene: SKScene , SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    var computer: SKSpriteNode!
    var wall: SKSpriteNode!
    var leftPlayer: Bool = false
    var leftComp: Bool = false
    var ground: SKSpriteNode!
    var timer : NSTimer!
    var time : SKLabelNode!
    var gameTimer = 30
    var win : SKLabelNode!
    var lose : SKLabelNode!
    var instructions : SKLabelNode!
    var restart : MSButtonNode!
    var gameOver : Bool = false
    
    var blockColor: [UIColor] = [UIColor.clearColor(), UIColor.cyanColor(), UIColor.magentaColor(), UIColor.purpleColor(), UIColor.greenColor(), UIColor.orangeColor()]
    
    override func didMoveToView(view: SKView) {
        /* Set up your scene here */
        player = self.childNodeWithName("player") as! SKSpriteNode
        computer = self.childNodeWithName("computer") as! SKSpriteNode
        wall = self.childNodeWithName("wall") as! SKSpriteNode
        ground = self.childNodeWithName("ground") as! SKSpriteNode
        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: false)
        time = self.childNodeWithName("time") as! SKLabelNode
        win = self.childNodeWithName("win") as! SKLabelNode
        lose = self.childNodeWithName("lose") as! SKLabelNode
        instructions = self.childNodeWithName("instructions") as! SKLabelNode
        restart = self.childNodeWithName("Restart") as! MSButtonNode
        physicsWorld.contactDelegate = self
        
        win.alpha = 0
        lose.alpha = 0
        restart.alpha = 0
        
        restart.selectedHandler = {
            
            let skView = self.view as SKView!
            let scene = GameScene(fileNamed: "GameScene") as GameScene!
            scene.scaleMode = .AspectFill
            skView.presentScene(scene)
        }
        
        let updateTime = SKAction.runBlock {
            
            self.time.text = String(self.gameTimer)
            self.gameTimer -= 1
            if self.gameTimer <= 26 {
                self.instructions.alpha = 0
            }
            
            if self.time.text == "0" {
                self.lose.alpha = 1
                self.restart.alpha = 1
                self.time.alpha = 0
                self.gameOver = true
            }
            
        }
        let waitTime = SKAction.waitForDuration(1)
        
        let timeSequence = SKAction.sequence([waitTime, updateTime])
        let repeatForeva = SKAction.repeatActionForever(timeSequence)
        runAction(repeatForeva, withKey: "timeAction")
        
        //print(computer.position.y)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if gameOver { return }
        /* Called when a touch begins */
        
        if leftPlayer {
            /* if we hit wall, then jump left */
            player.physicsBody?.velocity = CGVectorMake(0, 0)
            player.physicsBody?.applyImpulse(CGVectorMake(30, 350))
        }
        else {
            /* jump right */
            player.physicsBody?.velocity = CGVectorMake(0, 0)
            player.physicsBody?.applyImpulse(CGVectorMake(-30, 350))
        }
    }
    
    func timerCallback() {
        if gameOver { return }
        
        if leftComp {
            /* if we hit wall, then jump left */
            computer.physicsBody?.velocity = CGVectorMake(0, 0)
            computer.physicsBody?.applyImpulse(CGVectorMake(-20, 100))
        }
        else {
            /* jump right */
            computer.physicsBody?.velocity = CGVectorMake(0, 0)
            computer.physicsBody?.applyImpulse(CGVectorMake(20, 100))
        }
        NSTimer.scheduledTimerWithTimeInterval(Double(arc4random_uniform(UInt32(5))), target: self, selector: #selector(timerCallback), userInfo: nil, repeats: false)
    }
    
    override func update(currentTime: CFTimeInterval) {
        if gameOver { return }
        /* Called before each frame is rendered */
        let velocityY = player.physicsBody?.velocity.dy ?? 0
        
        if velocityY > 400 {
            player.physicsBody?.velocity.dy = 400
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        /*get references to bodies involved in collision */
        let contactA: SKPhysicsBody = contact.bodyA
        let contactB: SKPhysicsBody = contact.bodyB
        
        /* get reference to physics body parent nodes */
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        /* if we hit the wall */
        if (nodeA.name == "wall" && nodeB.name == "computer") || (nodeA.name == "computer" && nodeB.name == "wall") {
            leftComp = !leftComp
        }
        
        if (nodeA.name == "wall" && nodeB.name == "player") || (nodeA.name == "player" && nodeB.name == "wall") {
            leftPlayer = !leftPlayer
        }
        
        if(nodeA.name == "ground" && nodeB.name == "computer") || (nodeA.name == "computer" && nodeB.name == "ground") {
            if leftComp {
                computer.physicsBody?.applyImpulse(CGVectorMake(CGFloat(arc4random_uniform(UInt32(40))), CGFloat(arc4random_uniform(UInt32(120)))))
            } else {
                computer.physicsBody?.applyImpulse(CGVectorMake(-30, 110))
            }
        }
        
        if (nodeA.name == "computer" && nodeB.name == "player") {
            
            if nodeA.position.y > nodeB.position.y + nodeB.frame.height {
                print("red1 on top")
                let newFrame = CGRect(x: nodeB.position.x, y: nodeB.position.y, width: nodeB.frame.width - 10, height: nodeB.frame.height)
                newPlayerSize = newFrame
            } else if nodeA.position.y + (nodeB.frame.height/2) < nodeB.position.y - (nodeB.frame.height/2) {
                print("blue1 on top")
                gameTimer = 30
                let newFrame = CGRect(x: nodeA.position.x, y: nodeA.position.y, width: nodeA.frame.width - 10, height: nodeA.frame.height)
                newCompSize = newFrame
            }
        }
        else if nodeB.name == "computer" && nodeA.name == "player" {
            
            if nodeB.position.y > nodeA.position.y + nodeA.frame.height {
                print("red2 on top")
                let newFrame = CGRect(x: nodeA.position.x, y: nodeA.position.y, width: nodeA.frame.width - 10, height: nodeA.frame.height)
                newPlayerSize = newFrame
            } else if nodeB.position.y + (nodeA.frame.height/2) < nodeA.position.y - (nodeA.frame.height/2) {
                print("blue2 on top")
                gameTimer = 30
                let newFrame = CGRect(x: nodeB.position.x, y: nodeB.position.y, width: nodeB.frame.width - 10, height: nodeB.frame.height)
                newCompSize = newFrame
            }
        }
    }
    
    
    // MARK: Handle block resizing
    
    // TODO: Fix terrible bugs...
    // TODO: add variable to handle instant death
    
    /* initialize player and computer frames */
    var newPlayerSize : CGRect? = nil
    var newCompSize : CGRect? = nil
    
    override func didSimulatePhysics() {
        
        let random = Int(arc4random_uniform(UInt32(6)))
        let color : UIColor = blockColor[random]
        
        /* if newPlayerSize contains value other than nil, run  code */
        if let newPlayerSize = newPlayerSize {
            player.removeFromParent()
            
            
            if newPlayerSize.size.width > 1 {
                /* create new player block */
                player = SKSpriteNode(color: color, size: newPlayerSize.size)
                player.physicsBody = SKPhysicsBody(rectangleOfSize: newPlayerSize.size)
                player.name = "player"
                //player.physicsBody?.collisionBitMask = 4294967295
                player.physicsBody?.categoryBitMask = 2
                player.physicsBody?.contactTestBitMask = 3
                player.physicsBody?.allowsRotation = false
                player.anchorPoint = CGPointMake(0.5, 0.5)
                
                if newPlayerSize.size.width < player.frame.width/2{
                    player.physicsBody?.mass = 0.3
                } else {
                    player.physicsBody?.mass = 0.2
                }
                /* respawns at center*/
                player.position = CGPointMake(ground.frame.width/2, newPlayerSize.origin.y)
                addChild(player)
            } else {
                player.removeAllActions()
                computer.removeAllActions()
                self.lose.alpha = 1
                self.restart.alpha = 1
                self.time.alpha = 0
                gameOver = true
                
            }
            self.newPlayerSize = nil
        }
        
        
        
        if let newCompSize = newCompSize {
            //print(newCompSize, newCompSize.origin)
            computer.removeFromParent()
            if newCompSize.size.width > 1 {
                computer = SKSpriteNode(color: color, size: newCompSize.size)
                computer.physicsBody = SKPhysicsBody(rectangleOfSize: newCompSize.size)
                computer.name = "computer"
                //computer.physicsBody?.collisionBitMask = 4294967295
                computer.anchorPoint = CGPointMake(0.5, 0.5)
                computer.physicsBody?.categoryBitMask = 2
                computer.physicsBody?.contactTestBitMask = 3
                computer.physicsBody?.allowsRotation = false
                if newCompSize.size.width < player.frame.width{
                    computer.physicsBody?.mass = 0.1
                } else {
                    computer.physicsBody?.mass = 0.16
                }
                computer.position = CGPointMake(ground.frame.width/2, newCompSize.origin.y)
                addChild(computer)
            } else {
                player.removeAllActions()
                computer.removeAllActions()
                self.win.alpha = 1
                self.restart.alpha = 1
                self.time.alpha = 0
                gameOver = true
            }
            self.newCompSize = nil
        }
    }
}