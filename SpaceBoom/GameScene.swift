//
//  GameScene.swift
//  SpaceBoom
//
//  Created by Eric  on 03.04.23.
//

import SpriteKit

class GameScene: SKScene {
    let screenSize: CGRect = UIScreen.main.bounds
    let player = SKSpriteNode(imageNamed: "player")
    
    override func didMove(to view: SKView) {
        if let particles = SKEffectNode(fileNamed: "Starfield"){
            particles.position = CGPoint(x: 0, y: screenSize.maxY-150)
            particles.zPosition = -1
            addChild(particles)
        }
        
        player.name = "player"
        player.position.y = screenSize.minY-150
        player.zPosition = 1
        addChild(player)
    }
}
