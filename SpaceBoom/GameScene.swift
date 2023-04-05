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
    
    override func didMove(to view: SKView) {
        if let particles = SKEffectNode(fileNamed: "Starfield"){ //adds particles of starfield to screen
            particles.position = CGPoint(x: 0, y: frame.maxY + 500)
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
}
