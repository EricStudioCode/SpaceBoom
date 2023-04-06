//
//  GameScene.swift
//  SpaceBoom
//
//  Created by Eric  on 03.04.23.
//

import SpriteKit

enum CollisionType: UInt32 {
    case player = 1
    case playerWeapon = 2
    case enemy = 4
    case enemyWeapon = 8
}

class GameScene: SKScene {
    let player = SKSpriteNode(imageNamed: "player") //creates player node
    
    let waves = Bundle.main.decode([Wave].self, from: "waves.json") //gives array of waves from json file
    let enemyTypes = Bundle.main.decode([EnemyType].self, from: "enemy-types.json")
    
    var isPlayerAlive = true
    var levelNumber = 0
    var waveNumber = 0
    
    let positions = Array(stride(from: -80, through: 80, by: 20))
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        
        if let particles = SKEmitterNode(fileNamed: "Starfield"){ //adds particles of starfield to screen
            particles.position = CGPoint(x: 0, y: frame.maxY)
            particles.advanceSimulationTime(10) // fills screen with space stuff before start
            particles.zPosition = -1 // make particles appear in background layer
            addChild(particles)
        }
        
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
    }
    
    override func update(_ currentTime: TimeInterval) {
        for child in children {
            if child.frame.minY < 0 {
                if !frame.intersects(child.frame) {
                    child.removeFromParent()
                }
            }
        }

        let activeEnemies = children.compactMap { $0 as? EnemyNode }

        if activeEnemies.isEmpty {
            createWave()
        }
    }
    
    func createWave() {
        print(frame.origin.x)
        print(frame.origin.y)
        print(frame.width)
        print(frame.height)
        print(frame.maxY)
        print(frame.maxX)
        print(frame.minY)
        guard isPlayerAlive else { return }
        
        if waveNumber == waves.count {
            levelNumber += 1
            waveNumber = 0
        }
        
        let currentWave = waves[waveNumber]
        waveNumber += 1
        
        let maximumEnemyType = min(enemyTypes.count, levelNumber + 1)
        let enemyType = Int.random(in: 0..<maximumEnemyType)
        
        let enemyOffsetY: CGFloat = 5
        let enemyStartY = 200
        
        if currentWave.enemies.isEmpty{
            for (index, position) in positions.shuffled().enumerated() {
                let enemy = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: -position, y: enemyStartY), yOffset: enemyOffsetY * CGFloat(index * 3), moveStraight: true, size: CGSize(width: 20, height: 30))
                enemy.size = CGSize(width: 20, height: 30)
                addChild(enemy)
            }
        } else {
            for enemy in currentWave.enemies {
                let node = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: positions[enemy.position], y: enemyStartY), yOffset: enemyOffsetY * enemyOffsetY, moveStraight: enemy.moveStraight, size: CGSize(width: 20, height: 30))
                node.size = CGSize(width: 20, height: 30)
                addChild(node)
            }
        }
    }
}
