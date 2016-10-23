//
//  GameScene.swift
//  Ninja Jump
//
//  Created by Becarefullee on 16/10/13.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
  var runningDown: Bool = true
  let ninja = SKSpriteNode(imageNamed: "Run__000")
  let maxAspectRatio: CGFloat
  let playableHeight: CGFloat
  let playableRect: CGRect
  let ninjaRunAnimation: SKAction
  let ninjaJumpAnimation: SKAction
  let ninjaRunOppositeAnimation: SKAction
  let ninjaJumpOppositeAnimation: SKAction
  let enemyBottomAttack: SKAction
  let enemyUpperAttack: SKAction
  let playableMargin: CGFloat
  let cameraNode = SKCameraNode()
  let cameraMovePointsPerSec: CGFloat = 600
  var lastUpdateTime: TimeInterval = 0
  var dt: TimeInterval = 0
  var ninjaVelocity: CGPoint = CGPoint(x: 600,y: 0)
  var jumpVelocity: CGPoint = CGPoint(x: 600, y: -800)
  var isJumping: Bool = false
  var lives = 5
  var isNinjaVisible: Bool = true
  var score : Int = 0
  var survivalTime: TimeInterval = 0
  var gameOver: Bool = false
  let livesLabel = SKLabelNode(fontNamed: "Chalkduster")
  let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")

  
  
  //MARK: Init
  
  override init(size: CGSize){
    
    maxAspectRatio = 16.0/9.0
    playableHeight = size.width / maxAspectRatio
    playableMargin = (size.height - playableHeight)/2.0
    playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)

    
    var runTextures:[SKTexture] = []
    for i in 0...9 {
      runTextures.append(SKTexture(imageNamed: "Run__00\(i)"))
    }
    ninjaRunAnimation = SKAction.animate(with: runTextures, timePerFrame: 0.05)
    
    
    var jumpTextures:[SKTexture] = []
    for i in 0...9 {
      jumpTextures.append(SKTexture(imageNamed: "Jump__00\(i)"))
    }
    ninjaJumpAnimation = SKAction.animate(with: jumpTextures, timePerFrame: 0.05)
    
    var runOpositeTextures:[SKTexture] = []
    for i in 0...9 {
      runOpositeTextures.append(SKTexture(imageNamed: "r__00\(i)"))
    }
    ninjaRunOppositeAnimation = SKAction.animate(with: runOpositeTextures, timePerFrame: 0.05)
    
    var jumpOppositeTextures:[SKTexture] = []
    for i in 0...9 {
      jumpOppositeTextures.append(SKTexture(imageNamed: "j__00\(i)"))
    }
    ninjaJumpOppositeAnimation = SKAction.animate(with: jumpOppositeTextures, timePerFrame: 0.05)

    var enemyUpperTextures:[SKTexture] = []
    for i in 0...9 {
      enemyUpperTextures.append(SKTexture(imageNamed: "Attack__00\(i)"))
    }
    enemyUpperAttack = SKAction.animate(with: enemyUpperTextures, timePerFrame: 0.05)

    var enemyBottomTextures:[SKTexture] = []
    for i in 0...9 {
      enemyBottomTextures.append(SKTexture(imageNamed: "A00\(i)"))
    }
    enemyBottomAttack = SKAction.animate(with: enemyBottomTextures, timePerFrame: 0.05)
    

    
    super.init(size: size)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  

  //MARK: Lifecycle
  
  override func didMove(to view: SKView) {
    
    backgroundColor = SKColor.white

    for i in 0...1 {
      let background = backgroundNode()
      background.anchorPoint = CGPoint.zero
      background.position =
        CGPoint(x: CGFloat(i)*background.size.width, y: 0)
      background.name = "background"
      background.zPosition = -1
      addChild(background)
    }
    ninja.setScale(0.5)
    ninja.position = CGPoint(x: size.width/5 + ninja.size.width/2, y: cameraRect.minY + ninja.size.height/2)

    ninja.zPosition = 1000
    print(ninja.size.height)
    addChild(ninja)
    run(SKAction.repeatForever(SKAction.sequence([SKAction.run({
      self.spawnUpperBarriers()
    }), SKAction.wait(forDuration: 1), SKAction.run({ 
      self.spawnBottomBarriers()
    }), SKAction.wait(forDuration: 5)])))
    run(SKAction.repeatForever(SKAction.sequence([SKAction.run({
      self.spawnKuwu()
    }), SKAction.wait(forDuration: 2.0)])))
    
    ninja.run(SKAction.repeatForever(ninjaRunAnimation), withKey: "runAnimation")
    addChild(cameraNode)
    camera = cameraNode
    cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
    
    spawnKuwu()
    
    livesLabel.text = "Lives: \(lives)"
    livesLabel.fontColor = SKColor.black
    livesLabel.fontSize = 60
    livesLabel.zPosition = 100
    livesLabel.zRotation = -π/2
    livesLabel.horizontalAlignmentMode = .left
    livesLabel.verticalAlignmentMode = .top
    livesLabel.position = CGPoint(x: -playableRect.size.width/2 +
      CGFloat(80),y: playableRect.size.height/2 - CGFloat(10))
    cameraNode.addChild(livesLabel)

    scoreLabel.text = "\(score)"
    scoreLabel.fontColor = SKColor.black
    scoreLabel.fontSize = 60
    scoreLabel.zPosition = 100
    scoreLabel.zRotation = -π/2
    scoreLabel.horizontalAlignmentMode = .left
    scoreLabel.verticalAlignmentMode = .bottom
    scoreLabel.position = CGPoint(x: -playableRect.size.width/2 + CGFloat(20),y: -playableRect.size.height/2 + CGFloat(230))
    cameraNode.addChild(scoreLabel)

    
  }
  
  
  override func didEvaluateActions() {
    checkCollision()
  }

  override func update(_ currentTime: TimeInterval) {
    if lives <= 0  && !gameOver  {
      gameOver = true
      score = Int(survivalTime * 1000)
      print("You lose!")
      print("Final Score: \(score)")
      let gameOverScene = GameOverScene(size: size, score: score)
      gameOverScene.scaleMode = scaleMode
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      view?.presentScene(gameOverScene, transition: reveal)

      
    }else{
      if lastUpdateTime > 0 {
        dt = currentTime - lastUpdateTime
        survivalTime = survivalTime + dt
        score = Int(survivalTime * 1000)
        scoreLabel.text = "\(score)"
      } else {
        dt = 0 }
      lastUpdateTime = currentTime
        
      
      if isJumping {
        moveSprite(sprite: ninja, velocity: jumpVelocity)
      }
      else {
        moveSprite(sprite: ninja, velocity: ninjaVelocity)
      }
      moveCamera()
      boundsCheck()
    }
  }
  
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    isJumping = true
    stopNinjaRunAnimation()
    startNinjaJumpAnimation()
  }
}



//MARK: Ninja Actions



extension GameScene {
  
  func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
    let amountToMove = velocity * CGFloat(dt)
    sprite.position += amountToMove
  }
  
  func startNinjaRunAnimation() {
    if ninja.action(forKey: "runAnimation") == nil {
      ninja.run(SKAction.repeatForever(ninjaRunAnimation), withKey: "runAnimation")
    }
  }
  
  func stopNinjaRunAnimation() {
    ninja.removeAction(forKey: "runAnimation")
  }
  
  func startNinjaJumpAnimation() {
    if ninja.action(forKey: "jumpAnimation") == nil {
      if runningDown {
        ninja.run(SKAction.repeatForever(ninjaJumpAnimation), withKey: "jumpAnimation")
        ninja.run(SKAction.rotate(byAngle: π*9, duration: 1.0))
        ninja.run(SKAction.repeatForever(ninjaJumpOppositeAnimation), withKey: "jumpAnimation")
        ninja.run(SKAction.rotate(byAngle: π*10, duration: 1.0))
        runningDown = false
      }else {
        ninja.run(SKAction.repeatForever(ninjaJumpOppositeAnimation), withKey: "jumpAnimation")
        ninja.run(SKAction.rotate(byAngle: π*10, duration: 1.0))
        ninja.run(SKAction.repeatForever(ninjaJumpAnimation), withKey: "jumpAnimation")
        ninja.run(SKAction.rotate(byAngle: π*9, duration: 1.0))
        runningDown = true
      }
      
    }
  }
  
  func stopNinjaJumpAnimation() {
    ninja.removeAction(forKey: "jumpAnimation")
  }
}


//MARK: Enemy Actions

extension GameScene {
  
  func spawnUpperBarriers() {
    let upperBarrier = SKSpriteNode(imageNamed: "Attack__000")
    upperBarrier.name = "enemy"
    upperBarrier.setScale(0.5)
    upperBarrier.position = CGPoint(x: CGFloat.random(min: ninja.position.x + size.width, max:cameraRect.maxX + size.width), y: playableHeight + playableMargin - (upperBarrier.size.height/2) )
    addChild(upperBarrier)
    upperBarrier.run(SKAction.repeatForever(enemyUpperAttack))
    upperBarrier.run(SKAction.sequence([SKAction.wait(forDuration: 20),SKAction.removeFromParent()]))

  }
  
  func spawnBottomBarriers(){
    let bottomBarrier = SKSpriteNode(imageNamed: "Attack__000")
    bottomBarrier.name = "enemy"
    bottomBarrier.setScale(0.5)
    bottomBarrier.position = CGPoint(x: CGFloat.random(min: ninja.position.x + size.width, max: cameraRect.maxX + size.width), y: playableMargin + bottomBarrier.size.height/2)
    addChild(bottomBarrier)
    bottomBarrier.run(SKAction.repeatForever(enemyBottomAttack))
    bottomBarrier.run(SKAction.sequence([SKAction.wait(forDuration: 20),SKAction.removeFromParent()]))
  }
  
  func spawnKuwu() {
    let kuwu = SKSpriteNode(imageNamed: "Kunai")
    kuwu.name = "kuwu"
    kuwu.setScale(0.8)
    kuwu.zRotation = π/2
    kuwu.position = CGPoint(x: cameraRect.maxX + kuwu.size.width/2, y: CGFloat.random(min: cameraRect.minY + kuwu.size.height/2, max: cameraRect.maxY - kuwu.size.height/2))
    addChild(kuwu)
    let actionMove = SKAction.moveBy(x: -cameraRect.width, y: 0, duration: 3.0)
    let actionRemove = SKAction.removeFromParent()
    kuwu.run(SKAction.sequence([actionMove, actionRemove]))
  }
}


//MARK: Camera


extension GameScene {
  
  
  func backgroundNode() -> SKSpriteNode {
    // 1
    let backgroundNode = SKSpriteNode()
    backgroundNode.anchorPoint = CGPoint.zero
    backgroundNode.name = "background"
    // 2
    let background1 = SKSpriteNode(imageNamed: "background1")
    background1.anchorPoint = CGPoint.zero
    background1.position = CGPoint(x: 0, y: 0)
    backgroundNode.addChild(background1)
    // 3
    let background2 = SKSpriteNode(imageNamed: "background1")
    background2.anchorPoint = CGPoint.zero
    background2.position =
      CGPoint(x: background1.size.width, y: 0)
    backgroundNode.addChild(background2)
    // 4
    backgroundNode.size = CGSize(
      width: background1.size.width + background2.size.width,
      height: background1.size.height)
    return backgroundNode
  }
  
  
  func overlapAmount() -> CGFloat {
    guard let view = self.view else {
      return 0 }
    let scale = view.bounds.size.width / self.size.width
    let scaledHeight = self.size.height * scale
    let scaledOverlap = scaledHeight - view.bounds.size.height
    return scaledOverlap / scale
  }
  
  func getCameraPosition() -> CGPoint {
    return CGPoint(x: cameraNode.position.x, y: cameraNode.position.y)
  }
  
  func setCameraPosition(position: CGPoint) {
//    cameraNode.position = CGPoint(x: position.x, y: position.y -
//      overlapAmount()/2)
    cameraNode.position = CGPoint(x: position.x, y: position.y)

  }
  
  
  var cameraRect : CGRect {
    return CGRect(
      x: getCameraPosition().x - size.width/2
        + (size.width - playableRect.width)/2,
            y: getCameraPosition().y - size.height/2
              + (size.height - playableRect.height)/2,
      width: playableRect.width,
      height: playableRect.height)
  }
  
  
  func moveCamera() {
    let backgroundVelocity =
      CGPoint(x: cameraMovePointsPerSec, y: 0)
    let amountToMove = backgroundVelocity * CGFloat(dt)
    cameraNode.position += amountToMove
    enumerateChildNodes(withName: "background") { node, _ in
      let background = node as! SKSpriteNode
      if background.position.x + background.size.width <
        self.cameraRect.origin.x {
        background.position = CGPoint(
          x: background.position.x + background.size.width*2,
          y: background.position.y)
      }
    }
  }
  

  func debugDrawPlayableArea() {
    let shape = SKShapeNode()
    let path = CGMutablePath()
    path.addRect(cameraRect)
    shape.path = path
    shape.strokeColor = SKColor.red
    shape.lineWidth = 4.0
    addChild(shape)
  }
  
  
  
  func boundsCheck(){
    let bottomLeft = CGPoint(x: playableRect.minX,
                             y: playableRect.minY)
    let topRight = CGPoint(x: playableRect.maxX,
                           y: playableRect.maxY)
    if ninja.position.y < (bottomLeft.y + ninja.size.height/2){
      stopNinjaJumpAnimation()
      startNinjaRunAnimation()
      ninja.position.y = bottomLeft.y + ninja.size.height/2
      jumpVelocity.y = -jumpVelocity.y
      isJumping = false
    }
    if ninja.position.y > topRight.y - ninja.size.height/2{
      stopNinjaJumpAnimation()
      ninja.run(SKAction.repeatForever(ninjaRunOppositeAnimation), withKey: "runAnimation")
      ninja.position.y = topRight.y - ninja.size.height/2
      jumpVelocity.y = -jumpVelocity.y
      isJumping = false
    }
  }

  
}



//MARK: Collision Detection

extension GameScene {
  
  func ninjaHitEnemy(enemy: SKSpriteNode) {
    blink(sprite: ninja)
    lives -= 1
    livesLabel.text = "Lives: \(lives)"
  }
  
  func checkCollision() {
    var hitKuwu:[SKSpriteNode] = []
    enumerateChildNodes(withName: "kuwu") { (node, _) in
      if self.isNinjaVisible {
        let kuwu = node as! SKSpriteNode
        if kuwu.frame.insetBy(dx: 5, dy: 5).intersects(self.ninja.frame) {
          hitKuwu.append(kuwu)
          self.isNinjaVisible = false
        }
      }
    }
    for kuwu in hitKuwu {
      ninjaHitEnemy(enemy: ninja)
    }
    
    var hitEnemys:[SKSpriteNode] = []
    enumerateChildNodes(withName: "enemy") { (node, _) in
      if self.isNinjaVisible {
        let enemy = node as! SKSpriteNode
        if node.frame.insetBy(dx: 60, dy: 60).intersects(
          self.ninja.frame) {
          hitEnemys.append(enemy)
//          self.collisionTimes = self.collisionTimes + 1
//          print(self.collisionTimes)
          self.isNinjaVisible = false
        }
      }
    }
    for enemy in hitEnemys {
      ninjaHitEnemy(enemy: enemy)
    }
  }
  
  
  func blink(sprite: SKSpriteNode) {
    let blinkTimes = 10.0
    let duration = 3.0
    sprite.run(SKAction.customAction(withDuration: duration) {
      node, elapsedTime in
      let slice = duration / blinkTimes
      let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
      node.isHidden = remainder > slice / 2
    }) {
      self.isNinjaVisible = true
    }
    
  }
}





