//
//  EnemyNode.swift
//  SpaceBoom
//
//  Created by Eric  on 05.04.23.
//

import SpriteKit

class EnemyNode: SKSpriteNode {
    var type: EnemyType
    var lastFireTime: Double = 0
    var shields: Int
    var enemySize: CGSize
    
    init(type: EnemyType, startPosition: CGPoint, yOffset: CGFloat, moveStraight: Bool, size: CGSize) {
        self.type = type
        shields = type.shields
        self.enemySize = size
        
        let texture = SKTexture(imageNamed: type.name)
        super.init(texture: texture, color: .white, size: size)
        
        physicsBody = SKPhysicsBody(texture: texture, size: size)
        physicsBody?.categoryBitMask = CollisionType.enemy.rawValue
        physicsBody?.collisionBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
        physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
        name = "enemy"
        position = CGPoint(x: startPosition.x, y: startPosition.y + yOffset)
        
        configureMovement(moveStraight)
                   
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NO")
    }
    
    func configureMovement(_ moveStraight: Bool) {
        let path = UIBezierPath()
        path.move(to: .zero)
        
        if moveStraight {
            path.addLine(to: CGPoint(x: 0, y: -4000))
        } else {
            path.addCurve(to: CGPoint(x: 0, y: -4000 ), controlPoint1: CGPoint(x: -position.x * 2, y: 0), controlPoint2: CGPoint(x: -position.x, y: -400))
        }
        
        let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: type.speed)
        let sequence = SKAction.sequence([movement, .removeFromParent()])
        run(sequence)
    }
    
    func fire(){
        let weaponType = "enemy_weapon"
        
        let weapon = SKSpriteNode(imageNamed: weaponType)
        weapon.name = "enemy_weapon"
        weapon.position = position
        weapon.zRotation = zRotation
        weapon.size = CGSize(width: 10, height: 20)
        
        
        parent?.addChild(weapon)
        
        weapon.physicsBody = SKPhysicsBody(texture: weapon.texture!, size: weapon.size)
        weapon.physicsBody?.categoryBitMask = CollisionType.enemyWeapon.rawValue
        weapon.physicsBody?.collisionBitMask = CollisionType.player.rawValue
        weapon.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        weapon.physicsBody?.mass = 0.001
        
        let speed: CGFloat = 1
        let adjustRotation = zRotation + (CGFloat.pi / 2)

        let dx = speed * cos(adjustRotation)
        let dy = speed * sin(adjustRotation)
        
        weapon.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
 
        
    }
}
