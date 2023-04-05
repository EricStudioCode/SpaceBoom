//
//  EnemyType.swift
//  SpaceBoom
//
//  Created by Eric  on 05.04.23.
//

import SpriteKit

struct EnemyType: Codable {
    let name: String
    let shields: Int
    let speed: CGFloat
    let powerUpChance: Int
}
