//
//  TitleScene.swift
//  SpaceShooter
//
//  Created by Jeffrey Chen on 2/9/18.
//  Copyright © 2018 lyftgame. All rights reserved.
//

import Foundation
import SpriteKit

class TitleScene: SKScene {
    var btnPlay : UIButton?
    var gameTitle: UILabel?

    var textColorHUD = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)

    override func didMove(to view: SKView) {
        self.backgroundColor = .purple

        setupText()
    }

    func setupText() {
        guard let view = view else { return }
        btnPlay = UIButton(frame: CGRect(x: 100, y: 100, width: 400, height: 100))
        guard let btnPlay = btnPlay else { return }
        btnPlay.center = CGPoint(x: view.frame.size.width / 2, y: 600)
        btnPlay.setTitle("Play!", for: .normal)
        btnPlay.setTitleColor(textColorHUD, for: .normal)
        btnPlay.addTarget(self, action: #selector(playTheGame), for: .touchUpInside)

        self.view?.addSubview(btnPlay)
        gameTitle = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
        guard let gameTitle = gameTitle else { return }
        gameTitle.textColor = textColorHUD
        gameTitle.font = UIFont(name: "Futura", size: 40)
        gameTitle.textAlignment = .center
        gameTitle.text = "Save Humanity"

        self.view?.addSubview(gameTitle)
    }

    @objc func playTheGame() {
        self.view?.presentScene(GameScene(), transition: .crossFade(withDuration: 1))
        btnPlay?.removeFromSuperview()
        gameTitle?.removeFromSuperview()

        if let scene = GameScene(fileNamed: "GameScene") {
            let skView = self.view! as SKView
            skView.ignoresSiblingOrder = true

            scene.scaleMode = .aspectFill
            skView.presentScene(scene)
        }
    }
}
