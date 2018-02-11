//
//  GameScene.swift
//  SpaceShooter
//
//  Created by Jeffrey Chen on 2/9/18.
//  Copyright © 2018 lyftgame. All rights reserved.
//

import SpriteKit
import GameplayKit

var player: SKSpriteNode? = .init()
var projectile: SKSpriteNode? = .init()

var scoreLabel: SKLabelNode? = .init()
var mainLabel: SKLabelNode? = .init()

var fireProjectileRate = 0.2
var projectileSpeed = 0.9

var enemySpeed = 1.8
var enemySpawnRate = 0.6

var isAlive = true

var score = 0

var pressedDown = false

var textColorHUD = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)

struct physicsCategory {
    static let player: UInt32 = 1
    static let enemy: UInt32 = 2
    static let projectile: UInt32 = 3
    static let passenger: UInt32 = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self

        self.backgroundColor = .purple

        spawnEnemy()
        spawnPlayer()
        spawnScoreLabel()
        spawnMainLabel()
        fireProjectile()
        randonEnemyTimerSpawn()
        updateScore()
        hideLabel()
        resetVariablesOnStart()

    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            if isAlive {
                player?.position.x = touchLocation.x
            } else {
                player?.position.x = -200
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //if touches.count > 1 {
            pressedDown = true
        //}
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        pressedDown = false
    }



    func spawnPlayer() {
        //player = SKSpriteNode(color: .white, size: CGSize(width: 100, height: 100))
        player = SKSpriteNode(imageNamed: "car")
        player?.size = CGSize(width: 90, height: 150)
        guard let player = player else { return }
        player.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 500)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.categoryBitMask = physicsCategory.player
        player.physicsBody?.contactTestBitMask = physicsCategory.enemy
        player.physicsBody?.isDynamic = false

        self.addChild(player)
    }

    func spawnEnemy() {
        guard isAlive else {
            return
        }
//        let enemy = SKSpriteNode(color: .red, size: CGSize(width: 80, height: 80))
        let enemy = SKSpriteNode(imageNamed: "icon" + String(Int(arc4random_uniform(4)) + 1))
        enemy.size = CGSize(width: 80, height: 80)
        enemy.position = CGPoint(x: Int(arc4random_uniform(600)) - 300, y: 1000)
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.categoryBitMask = physicsCategory.enemy
        enemy.physicsBody?.contactTestBitMask = physicsCategory.projectile
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.affectedByGravity = true
        enemy.physicsBody?.allowsRotation = false

        let moveForward = SKAction.moveTo(y: -1000, duration: enemySpeed)
        let destroy =  SKAction.removeFromParent()

        enemy.run(SKAction.sequence([moveForward, destroy]))
        self.addChild(enemy)
    }

    func spawnPassenger() {
        guard isAlive else {
            return
        }
        //        let enemy = SKSpriteNode(color: .red, size: CGSize(width: 80, height: 80))
        let passenger = SKSpriteNode(imageNamed: "pass" + String(Int(arc4random_uniform(2)) + 1))
        passenger.size = CGSize(width: 80, height: 80)
        passenger.position = CGPoint(x: Int(arc4random_uniform(600)) - 300, y: 1000)
        passenger.physicsBody = SKPhysicsBody(rectangleOf: passenger.size)
        passenger.physicsBody?.categoryBitMask = physicsCategory.passenger
        passenger.physicsBody?.contactTestBitMask = physicsCategory.projectile
        passenger.physicsBody?.isDynamic = true
        passenger.physicsBody?.affectedByGravity = true
        passenger.physicsBody?.allowsRotation = false

        let moveForward = SKAction.moveTo(y: -1000, duration: enemySpeed)
        let destroy =  SKAction.removeFromParent()

        passenger.run(SKAction.sequence([moveForward, destroy]))
        self.addChild(passenger)
        
    }

    func spawnScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Futura")
        guard let scoreLabel = scoreLabel else { return }
        scoreLabel.fontSize = 50
        scoreLabel.fontColor = textColorHUD
        scoreLabel.position = CGPoint(x: self.frame.minX + 150, y: self.frame.minY + 50)

        scoreLabel.text = "Score"
        self.addChild(scoreLabel)

    }

    func spawnMainLabel() {
        mainLabel = SKLabelNode(fontNamed: "Futura")
        mainLabel?.fontSize = 100
        mainLabel?.fontColor = textColorHUD
        mainLabel?.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        mainLabel?.text = "Start!"

        self.addChild(mainLabel!)
    }

    func spawnProjectile() {
        guard isAlive && pressedDown else {
            return
        }
        projectile = SKSpriteNode(color: .white, size: CGSize(width: 20, height: 20))
        guard let projectile = projectile else { return }
        guard let player = player else { return }
        projectile.position = CGPoint(x: player.position.x, y: player.position.y)

        projectile.physicsBody = SKPhysicsBody(rectangleOf: projectile.size)
        projectile.physicsBody?.affectedByGravity = false
        projectile.physicsBody?.categoryBitMask = physicsCategory.projectile
        projectile.physicsBody?.isDynamic = false
        projectile.zPosition = -1

        let moveForward = SKAction.moveTo(y: 1000, duration: projectileSpeed)
        let destroy = SKAction.removeFromParent()

        projectile.run(SKAction.sequence([moveForward, destroy]))
        self.addChild(projectile)
    }

    func spawnExplosion(enemyTemp: SKSpriteNode, color: UIColor) {
        let explosionEmitterPath = Bundle.main.path(forResource: "explosion", ofType: "sks")
        let explosion = NSKeyedUnarchiver.unarchiveObject(withFile: explosionEmitterPath!) as! SKEmitterNode
        explosion.position = CGPoint(x: enemyTemp.position.x, y: enemyTemp.position.y)
        explosion.zPosition = 1
        explosion.targetNode = self
        explosion.particleColor = color

        self.addChild(explosion)

        let explosionTimerRemove = SKAction.wait(forDuration: 0.2)
        let removeExplosion = SKAction.run {
            explosion.removeFromParent()
        }
        self.run(SKAction.sequence([explosionTimerRemove, removeExplosion]))
    }

    func spawnDeath(temp: SKSpriteNode) {
        let explosionEmitterPath = Bundle.main.path(forResource: "fire", ofType: "sks")
        let explosion = NSKeyedUnarchiver.unarchiveObject(withFile: explosionEmitterPath!) as! SKEmitterNode
        guard let player = player else { return }
        explosion.position = CGPoint(x: player.position.x, y: player.position.y)
        explosion.particleSize = CGSize(width: 200, height: 200)
        explosion.zPosition = 1
        explosion.targetNode = self

        self.addChild(explosion)

        let explosionTimerRemove = SKAction.wait(forDuration: 3)
        let removeExplosion = SKAction.run {
            explosion.removeFromParent()
        }

        self.run(SKAction.sequence([explosionTimerRemove, removeExplosion]))
    }

    func spawnHealth(temp: SKSpriteNode) {
        let explosionEmitterPath = Bundle.main.path(forResource: "fireflies", ofType: "sks")
        let explosion = NSKeyedUnarchiver.unarchiveObject(withFile: explosionEmitterPath!) as! SKEmitterNode
        explosion.position = CGPoint(x: temp.position.x, y: temp.position.y)
        explosion.zPosition = 1
        explosion.targetNode = self
        explosion.particleSize = CGSize(width: 20, height: 20)

        self.addChild(explosion)

        let explosionTimerRemove = SKAction.wait(forDuration: 1.5)
        let removeExplosion = SKAction.run {
            explosion.removeFromParent()
        }
        self.run(SKAction.sequence([explosionTimerRemove, removeExplosion]))
    }

    func fireProjectile() {
        let fireProjectileTimer = SKAction.wait(forDuration: fireProjectileRate)

        let spawn = SKAction.run {
            self.spawnProjectile()
        }

        let sequence = SKAction.sequence([fireProjectileTimer, spawn])

        self.run(SKAction.repeatForever(sequence))
    }

    func randonEnemyTimerSpawn() {
        let spawnEnemyTimer = SKAction.wait(forDuration: enemySpawnRate)

        let spawn = SKAction.run {
            let ran = Int(arc4random_uniform(100))
            if ran > 40 {
                self.spawnEnemy()
            } else {
                self.spawnPassenger()
            }
        }

        let sequence = SKAction.sequence([spawnEnemyTimer, spawn])

        self.run(SKAction.repeatForever(sequence))
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody = contact.bodyA
        let secondBody: SKPhysicsBody = contact.bodyB

        if (firstBody.categoryBitMask == physicsCategory.projectile
            && secondBody.categoryBitMask == physicsCategory.enemy) ||
           (firstBody.categoryBitMask == physicsCategory.enemy
            && secondBody.categoryBitMask == physicsCategory.projectile) {
            spawnExplosion(enemyTemp: firstBody.node as! SKSpriteNode, color: .orange)
            projectileCollision(enemyTemp: firstBody.node as! SKSpriteNode,
                                projectileTemp: secondBody.node as! SKSpriteNode,
                                scoreDiff: 1)
        }

        if (firstBody.categoryBitMask == physicsCategory.projectile
            && secondBody.categoryBitMask == physicsCategory.passenger) ||
            (firstBody.categoryBitMask == physicsCategory.passenger
                && secondBody.categoryBitMask == physicsCategory.projectile) {
            spawnExplosion(enemyTemp: firstBody.node as! SKSpriteNode, color: .red)
            projectileCollision(enemyTemp: firstBody.node as! SKSpriteNode,
                                projectileTemp: secondBody.node as! SKSpriteNode,
                                scoreDiff: -1)
        }

        if (firstBody.categoryBitMask == physicsCategory.player
            && secondBody.categoryBitMask == physicsCategory.enemy) ||
            (firstBody.categoryBitMask == physicsCategory.enemy
            && secondBody.categoryBitMask == physicsCategory.player) {
            spawnDeath(temp: firstBody.node as! SKSpriteNode)
            playerCollision(enemyTemp: firstBody.node as! SKSpriteNode,
                                playerTemp: secondBody.node as! SKSpriteNode)
        }

        if (firstBody.categoryBitMask == physicsCategory.player
            && secondBody.categoryBitMask == physicsCategory.passenger) ||
            (firstBody.categoryBitMask == physicsCategory.passenger
                && secondBody.categoryBitMask == physicsCategory.player) {
            spawnHealth(temp: firstBody.node as! SKSpriteNode)
            playerSave(passTemp: firstBody,
                            playerTemp: secondBody)
        }

    }

    func projectileCollision(enemyTemp: SKSpriteNode?, projectileTemp: SKSpriteNode?, scoreDiff: Int) {
        enemyTemp?.removeFromParent()
        projectileTemp?.removeFromParent()
        score = max(0, score + scoreDiff)
        updateScore()
    }

    func playerCollision(enemyTemp: SKSpriteNode?, playerTemp: SKSpriteNode?) {
        mainLabel?.fontSize = 50
        mainLabel?.alpha = 1
        mainLabel?.text = "Game Over"

        playerTemp?.removeFromParent()
        enemyTemp?.removeFromParent()

        isAlive = false
        waitThenMoveToTitleScreen()
    }

    func playerSave(passTemp: SKPhysicsBody?, playerTemp: SKPhysicsBody?) {
        if passTemp?.categoryBitMask == physicsCategory.player {
            playerTemp?.node?.removeFromParent()
        } else {
            passTemp?.node?.removeFromParent()
        }
        score = score + 2
        updateScore()
    }

    func waitThenMoveToTitleScreen() {
        let wait = SKAction.wait(forDuration: 2)
        let transition = SKAction.run {
            self.view?.presentScene(TitleScene(), transition: .crossFade(withDuration: 1.0))
        }
        let sequence = SKAction.sequence([wait, transition])
        self.run(SKAction.repeat(sequence, count: 1))
    }

    func updateScore() {
        scoreLabel?.text = "Score: \(score)"
    }

    func hideLabel() {
        let wait = SKAction.wait(forDuration: 3.0)
        let hide = SKAction.run {
            mainLabel?.alpha = 0
        }

        let sequence = SKAction.sequence([wait, hide])
        self.run(SKAction.repeat(sequence, count: 1))
    }

    func resetVariablesOnStart() {
        isAlive = true
        score = 0
    }

    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if !isAlive {
            player?.position.x = -200
        }
    }
}
