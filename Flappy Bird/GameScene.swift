//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Jonathan Deehan on 17/05/2016.
//  Copyright (c) 2016 Mahogany Games. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Nodes
    var bird = SKSpriteNode()
    var background = SKSpriteNode()
    var ground = SKNode()
    var movingObjects = SKNode()
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var labelHolder = SKSpriteNode()
    
    // CategoryBitMasks
    let birdGroup:UInt32 = 1
    let objectGroup:UInt32 = 2
    let gapGroup:UInt32 = 0 << 3
    
    // States
    var gameOver = 0
    
    // Score
    var score = 0
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0,-5)
        self.addChild(movingObjects)
        self.addChild(labelHolder)
        
        makeBackground()
        
        // Score
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 70)
        scoreLabel.zPosition = 15
        self.addChild(scoreLabel)
        
        // Bird
        let birdTexture = SKTexture(imageNamed: "img/flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "img/flappy2.png")
        let animation = SKAction.animateWithTextures([birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatActionForever(animation)
        bird = SKSpriteNode(texture: birdTexture)
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        bird.zPosition = 15
        bird.runAction(makeBirdFlap)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2)
        bird.physicsBody!.dynamic = true
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody?.categoryBitMask = birdGroup // category bitmask of 1 (birdGroup)
        bird.physicsBody?.collisionBitMask = gapGroup
        bird.physicsBody?.contactTestBitMask = objectGroup
        self.addChild(bird)
        
        // Ground
        ground.position = CGPointMake(0,0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        ground.physicsBody!.dynamic = false
        ground.physicsBody?.categoryBitMask = objectGroup
        self.addChild(ground)
        
        // Calls the makePipes method every 3 second to generate new pipes
        var timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("makePipes"), userInfo: nil, repeats: true)
        
    }
    
    func makePipes() {
        
        if (gameOver == 0) { // stops more pipes from being created in the background after losing
        
            // Pipes
            let gapHeight = bird.size.height * 4
            let movementAmount = arc4random() % UInt32(self.frame.size.height / 2) // random number between 0 and half the screen height
            let pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 4 // shifting it down a quarter of the screen height
            
            let pipe1Texture = SKTexture(imageNamed: "img/pipe1.png")
            let pipe1 = SKSpriteNode(texture: pipe1Texture)
            pipe1.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.width, y: CGRectGetMidY(self.frame) + pipe1.size.height/2 + gapHeight/2 + pipeOffset)
            pipe1.zPosition=12
            let movePipes = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width/100))
            let removePipes = SKAction.removeFromParent() // remove pipes after they disappear to reserve memory
            let moveAndRemovePipes = SKAction.repeatActionForever(SKAction.sequence([movePipes, removePipes]))
            pipe1.runAction(moveAndRemovePipes)
            pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipe1.size)
            pipe1.physicsBody!.dynamic = false
            pipe1.physicsBody?.categoryBitMask = objectGroup
            movingObjects.addChild(pipe1)
            
            let pipe2Texture = SKTexture(imageNamed: "img/pipe2.png")
            let pipe2 = SKSpriteNode(texture: pipe2Texture)
            pipe2.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.width, y: CGRectGetMidY(self.frame) - pipe2.size.height/2 - gapHeight/2 + pipeOffset)
            pipe2.zPosition=12
            pipe2.runAction(movePipes)
            pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipe2.size)
            pipe2.physicsBody!.dynamic = false
            pipe2.physicsBody?.categoryBitMask = objectGroup
            movingObjects.addChild(pipe2)
            
            // When bird passes through gap
            var gap = SKNode()
            gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.width, y: CGRectGetMidY(self.frame) + pipeOffset)
            gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipe1.size.width, gapHeight))
            gap.runAction(moveAndRemovePipes) // move and remove the gap
            gap.physicsBody!.dynamic = false
            gap.physicsBody?.collisionBitMask = gapGroup
            gap.physicsBody?.categoryBitMask = gapGroup
            gap.physicsBody?.contactTestBitMask = birdGroup
            movingObjects.addChild(gap)
        }
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == gapGroup || contact.bodyB.categoryBitMask == gapGroup){
            score += 1
            scoreLabel.text = "\(score)"
        } else {
            // When the bird is not making contact with the gap
            if gameOver == 0 { // code won't try run the game over screen again if contact is made twice
                gameOver = 1
                movingObjects.speed = 0
                
                gameOverLabel.fontName = "Helvetica"
                gameOverLabel.fontSize = 30
                gameOverLabel.text = "Game Over! Tap to play again"
                gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
                gameOverLabel.zPosition = 16
                labelHolder.addChild(gameOverLabel)
                
            }
            
        }
        

    }
    
    func makeBackground() {
        let firstValue = CGFloat(0.0)
        let lastValue = CGFloat(3.0)
        let incrementValue = CGFloat(1.0)
        let sequence = firstValue.stride(to: lastValue, by: incrementValue)
        
        // Background
        let backgroundTexture = SKTexture(imageNamed: "img/bg.png")
        
        let moveBackground = SKAction.moveByX(-backgroundTexture.size().width, y: 0, duration: 9)
        let replaceBackgroud = SKAction.moveByX(backgroundTexture.size().width, y: 0, duration: 0)
        let moveBackgroundForever = SKAction.repeatActionForever(SKAction.sequence([moveBackground, replaceBackgroud]))
        
        for i in sequence {
            background = SKSpriteNode(texture: backgroundTexture)
            background.position = CGPoint(x: backgroundTexture.size().width/2 + backgroundTexture.size().width * i, y: CGRectGetMidY(self.frame))
            background.zPosition = 10
            background.size.height = self.frame.height
            
            background.runAction(moveBackgroundForever)
            movingObjects.addChild(background)
            
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        if(gameOver==0){
            bird.physicsBody?.velocity = CGVectorMake(0, 0)
            bird.physicsBody?.applyImpulse(CGVectorMake(0, 50))
        } else {
            score = 0
            scoreLabel.text = "0"
            movingObjects.removeAllChildren()
            makeBackground()
            bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidX(self.frame))
            labelHolder.removeAllChildren()
            bird.physicsBody?.velocity = CGVectorMake(0, 0)
            gameOver = 0
            movingObjects.speed = 1
        }

    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
