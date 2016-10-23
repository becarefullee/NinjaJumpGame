//
//  GameViewController.swift
//  Ninja Jump
//
//  Created by Becarefullee on 16/10/13.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
  
    override func viewDidLoad() {
      super.viewDidLoad()
      let scene =
        GameScene(size:CGSize(width: 1920, height: 1080))
      let skView = self.view as! SKView
      skView.showsFPS = true
      skView.showsNodeCount = true
      skView.ignoresSiblingOrder = true
      scene.scaleMode = .aspectFill
      skView.presentScene(scene)
    }
  
    override var prefersStatusBarHidden: Bool {
      return true
    }
}

