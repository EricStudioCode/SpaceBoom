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
    
    init(type: EnemyType, startPosition: CGPoint, xOffset: CGFloat, moveStraight: Bool, size: CGSize) {
        self.type = type
        shields = type.shields
        self.enemySize = size
        
        let texture = SKTexture(imageNamed: type.name)
        super.init(texture: texture, color: .white, size: texture.size())
        
        physicsBody = SKPhysicsBody(texture: texture, size: enemySize)
        physicsBody?.categoryBitMask = CollisionType.enemy.rawValue
        physicsBody?.collisionBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
        physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
        name = "enemy"
        position = CGPoint(x: startPosition.x + xOffset, y: startPosition.y)
        
        configureMovement(moveStraight)
                   
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NO")
    }
    
    func configureMovement(_ moveStraight: Bool) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: frame.maxY * 2))
        
        if moveStraight {
            path.addLine(to: CGPoint(x: 0, y: frame.minY * 2))
        } else {
            path.addCurve(to: CGPoint(x: 0, y: -1000), controlPoint1: CGPoint(x: 0, y: 0), controlPoint2: CGPoint(x: 0, y: -10))
        }
        
        let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: type.speed)
        let sequence = SKAction.sequence([movement, .removeFromParent()])
        run(sequence)
    }
}
