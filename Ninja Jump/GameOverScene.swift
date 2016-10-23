//
//  GameOverScene.swift
//  Ninja Jump
//
//  Created by Becarefullee on 16/10/14.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//

import Foundation
import SpriteKit
class GameOverScene: SKScene {

  let loseLabel: SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
  let scoreLabel: SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
  let score: Int
  let highestScoreLabel: SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
  let firstHighestScore: SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
  let secondHighestScore: SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
  let thirdHighestScore: SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
  let fourthHighestScore: SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
  let fifthHighestScore: SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")

  var scoreBoard:[Int] = [0, 0, 0, 0, 0]
  
  
  
  init(size: CGSize, score: Int) {
    self.score = score
    super.init(size: size)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMove(to view: SKView) {
//    // Back to GameScene
    
    
    if let historyScores = UserDefaults.standard.array(forKey: "score") as? [Int] {
     scoreBoard = historyScores
     scoreBoard.append(score)
     scoreBoard = scoreBoard.sorted()
      if scoreBoard.count > 5 {
        scoreBoard.reverse()
        scoreBoard.removeLast()
        UserDefaults.standard.set(scoreBoard, forKey: "score")
      }
      print(scoreBoard.sorted())

    }else {
      scoreBoard.append(score)
      scoreBoard = scoreBoard.sorted().reversed()
      scoreBoard.removeLast()
      print(scoreBoard)
      UserDefaults.standard.set(scoreBoard, forKey: "score")
    }
    
    
    
    loseLabel.text = "You Lose!"
    loseLabel.zRotation = -π/2
    loseLabel.fontSize = 100
    loseLabel.position = CGPoint(x: size.width/2 + CGFloat(500), y: size.height/2)
    addChild(loseLabel)
    
    scoreLabel.text = "Score: \(score)"
    scoreLabel.zRotation = -π/2
    scoreLabel.fontSize = 100
    scoreLabel.position = CGPoint(x: size.width/2 + CGFloat(100), y: size.height/2)
    addChild(scoreLabel)
    
    
    firstHighestScore.text = "1st Score: \(score)"
    firstHighestScore.zRotation = -π/2
    firstHighestScore.fontSize = 80
    firstHighestScore.position = CGPoint(x: size.width/2 - CGFloat(100), y: size.height/2)
    addChild(firstHighestScore)

    secondHighestScore.text = "2nd Score: \(score)"
    secondHighestScore.zRotation = -π/2
    secondHighestScore.fontSize = 80
    secondHighestScore.position = CGPoint(x: size.width/2 - CGFloat(200), y: size.height/2)
    addChild(secondHighestScore)

    thirdHighestScore.text = "3rd Score: \(score)"
    thirdHighestScore.zRotation = -π/2
    thirdHighestScore.fontSize = 80
    thirdHighestScore.position = CGPoint(x: size.width/2 - CGFloat(300), y: size.height/2)
    addChild(thirdHighestScore)

    fourthHighestScore.text = "4th Score: \(score)"
    fourthHighestScore.zRotation = -π/2
    fourthHighestScore.fontSize = 80
    fourthHighestScore.position = CGPoint(x: size.width/2 - CGFloat(400), y: size.height/2)
    addChild(fourthHighestScore)

    fifthHighestScore.text = "5th Score: \(score)"
    fifthHighestScore.zRotation = -π/2
    fifthHighestScore.fontSize = 80
    fifthHighestScore.position = CGPoint(x: size.width/2 - CGFloat(500), y: size.height/2)
    addChild(fifthHighestScore)

    
    var scoreLabels: [SKLabelNode] = [firstHighestScore, secondHighestScore, thirdHighestScore, fourthHighestScore, fifthHighestScore]
    
    for i in 0..<scoreBoard.count {
      scoreLabels[i].text = "Score: \(scoreBoard[i])"
    }

    
    
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    let wait = SKAction.wait(forDuration: 0.1)
    let block = SKAction.run {
      let myScene = GameScene(size: self.size)
      myScene.scaleMode = self.scaleMode
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      self.view?.presentScene(myScene, transition: reveal)
    }
    self.run(SKAction.sequence([wait, block]))

  }
  
  
}

