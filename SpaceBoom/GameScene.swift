//
//  GameScene.swift
//  SpaceBoom
//
//  Created by Eric  on 03.04.23.
//

import CoreMotion
import SpriteKit
import AudioToolbox

enum CollisionType: UInt32 {
    case player = 1
    case playerWeapon = 2
    case enemy = 4
    case enemyWeapon = 8
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let player = SKSpriteNode(imageNamed: "player") //creates player node
    //let motionManager = CMMotionManager()
    var currentShields: SKLabelNode!
    var currentLevel: SKLabelNode!
    var startTouch = CGPoint()
    var bossFightGoing = false
    
    let waves = Bundle.main.decode([Wave].self, from: "waves.json") //gives array of waves from json file
    let enemyTypes = Bundle.main.decode([EnemyType].self, from: "enemy-types.json")
    
    var isPlayerAlive = true
    var levelNumber = 0 {
        didSet {
            currentLevel.text = "\(levelNumber)"
        }
    }
    var waveNumber = 0
    var playerShields = 10 {
        didSet {
            currentShields.text = "\(playerShields)"
        }
    }
    var playerShotSpeed = TimeInterval(5)
    var playerShootingInterval = TimeInterval(0.5)
    var playerPosition = CGPoint()
    
    let positions = Array(stride(from: -80, through: 80, by: 20))
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        if let particles = SKEmitterNode(fileNamed: "Starfield"){ //adds particles of starfield to screen
            particles.position = CGPoint(x: 0, y: frame.maxY)
            particles.advanceSimulationTime(10) // fills screen with space stuff before start
            particles.zPosition = -1 // make particles appear in background layer
            addChild(particles)
        }
        
        // Label showing player shields:
        currentShields = SKLabelNode(fontNamed: "Chalkduster")
        currentShields.fontColor = UIColor.red
        currentShields.text = "10"
        currentShields.horizontalAlignmentMode = .right
        currentShields.position = CGPoint(x: -frame.minX/4, y: frame.maxY - 30)
        currentShields.fontSize = 15
        addChild(currentShields)
        
        // Label showing the level:
        currentLevel = SKLabelNode(fontNamed: "Chalkduster")
        currentLevel.text = "1"
        currentLevel.horizontalAlignmentMode = .right
        currentLevel.position = CGPoint(x: frame.minX/5, y: frame.maxY - 30)
        currentLevel.fontSize = 15
        addChild(currentLevel)
        
        player.name = "player"
        player.position.y = frame.minY + 25
        player.zPosition = 1 // makes sure player visual is above the background layer
        addChild(player) //adds player to screen
        player.size = CGSize(width: 40, height: 60) // scale player size
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size) // blue line around player, that is used for collision
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue //describes category what type player is
        player.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue //describes what types of collision we have to care about, adds up to 12, that combo cannot be added through the other enums, thats why we use the power of 2
        player.physicsBody?.contactTestBitMask  = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue // what types will allert us at collision, else it will notice us about all collision
        player.physicsBody?.isDynamic = false // ignore gravity for players body
        
        //motionManager.startAccelerometerUpdates()
        
        // Shooting and timings for the player weapon:
        self.run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: self.playerShootingInterval),
                SKAction.run({
                    self.playShooting(speed: self.playerShotSpeed)
                })
            ])
        ))
        
        if !bossFightGoing {
            self.run(SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.wait(forDuration: 4),
                    SKAction.run({
                        self.createWave()
                    })
                ])
            ))
        }
        
    }
    
    /*
     updates screen in time intervalls to check for nodes
     */
    override func update(_ currentTime: TimeInterval) {
        
//        if let accelerometerData = motionManager.accelerometerData {
//            player.position.x += CGFloat(accelerometerData.acceleration.x * 50)
//
//            if player.position.x < frame.minX/4 {
//                player.position.x = frame.minX/4
//            } else if player.position.x > frame.maxX/4 {
//                player.position.x = frame.maxX/4
//            }
//        }
        
        for child in children {
            if child.frame.minY < 0 {
                if !frame.intersects(child.frame) {
                    child.removeFromParent()  //delete nodes that are out of screen
                }
            }
        }
        
        let activeEnemies = children.compactMap { $0 as? EnemyNode } //get all active enemies

//        if activeEnemies.isEmpty {
//            createWave()
//        }
        
        // make the enemy fire randomly
        for enemy in activeEnemies {
            guard frame.intersects(enemy.frame) else { continue }
            
            if enemy.lastFireTime + 1 < currentTime {
                enemy.lastFireTime = currentTime
                
                if Int.random(in: 0...4) == 0 {
                    enemy.fire()
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self){
            if (pow(location.x, 2) < pow(frame.minX/4, 2)) {
                startTouch = location
                playerPosition = player.position
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self) {
            if (pow((playerPosition.x + location.x - startTouch.x),2) < pow(frame.minX/4, 2)) {
                player.run(SKAction.move(to: CGPoint(x:  playerPosition.x + location.x - startTouch.x, y: playerPosition.y), duration: 0.01))
            }
        }
    }
    
    /**
     create waves from wave.json either a random one or a predefined
     */
    func createWave() {
        guard isPlayerAlive else { return } //no wave when player dead
        
        // after each wave appeared once level up
        if waveNumber == waves.count {
            levelNumber += 1
            waveNumber = 0
        }
        
        let currentWave = waves[waveNumber]
        waveNumber += 1
        
        // get a random enemy type for the random wave creation
        var enemyType: Int
      
        // defines where enemies spawn
        let enemyStartY = frame.maxY
        var enemyOffsetY: CGFloat
        
        
        if currentWave.enemies.isEmpty{
            // creates random enemy wave with random layout
            for (index, position) in positions.shuffled().enumerated() {
                enemyOffsetY = CGFloat.random(in: 0..<5) * 10
                enemyType = Int.random(in: 0..<enemyTypes.count)
                
                let enemy = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: -CGFloat(position), y: enemyStartY), yOffset: enemyOffsetY * CGFloat(index * 3), moveStraight: true, size: CGSize(width: 20, height: 30))
                addChild(enemy)
            }
        } else {
            for enemy in currentWave.enemies {
                enemyOffsetY = CGFloat.random(in: 0..<5) * 10
                enemyType = Int.random(in: 0..<enemyTypes.count)
                
                let node = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: CGFloat(positions[enemy.position]), y: enemyStartY), yOffset: enemyOffsetY, moveStraight: enemy.moveStraight, size: CGSize(width: 20, height: 30))
                addChild(node)
            }
        }
    }
    
    func playShooting(speed: TimeInterval){
        guard isPlayerAlive else { return }
        
        let shot = SKSpriteNode(imageNamed: "player_weapon")
        shot.name = "player_weapon"
        shot.position = player.position
        shot.size = CGSize(width: 20, height: 20)
        
        shot.physicsBody = SKPhysicsBody(texture: shot.texture!, size: shot.size)
        shot.physicsBody?.categoryBitMask = CollisionType.playerWeapon.rawValue
        shot.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        shot.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        addChild(shot)
        
        let movement = SKAction.move(to: CGPoint(x: shot.position.x, y: 1000), duration: speed)
        let sequence = SKAction.sequence([movement, .removeFromParent()])
        shot.run(sequence)
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        // make sure nodes definitely exist in our game currently
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        // makes sure if play is in here it is nodeB since e<p
        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? ""}
        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]
        
        if secondNode.name == "player" {
            guard isPlayerAlive else { return }
            
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = firstNode.position
                addChild(explosion)
            }
            //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            playerShields -= 1
            
            if playerShields == 0 {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                 gameOver()
                secondNode.removeFromParent()
            }
             
            firstNode.removeFromParent()
        } else if let enemy = firstNode as? EnemyNode {
            enemy.shields -= 1
            
            if enemy.shields == 0 {
                if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                    explosion.position = enemy.position
                    addChild(explosion)
                }
                
                enemy.removeFromParent()
            }
            
            secondNode.removeFromParent()
            
        } else {
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = secondNode.position
                addChild(explosion)
            }
            
            firstNode.removeFromParent()
            secondNode.removeFromParent()
        }
    }
    
    func gameOver() {
        isPlayerAlive = false
        
        if let explosion = SKEmitterNode(fileNamed: "Explosion") {
            explosion.position = player.position
            addChild(explosion)
        }
        
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.size = CGSize(width: 90, height: 100)
        addChild(gameOver)
    }
}
