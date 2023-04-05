//
//  GameScene.swift
//  SpaceBoom
//
//  Created by Eric  on 03.04.23.
//

import SpriteKit

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
        player.scale(to: CGSize(width: 40, height: 60)) // player size
    }
}
