//
//  MapScene.swift
//  Sarab
//
//  Created by Nada Abdullah on 03/09/1446 AH.
//

import SpriteKit

class MapScene: SKScene {
    var cities: [String] = ["الطائف", "جدة", "الرياض"]
    var unlockedCities: Set<String> = []
    let defaults = UserDefaults.standard

    override func didMove(to view: SKView) {
        backgroundColor = .lightGray
        loadGameData()

        let titleLabel = SKLabelNode(text: "🌍 خريطة Sarab")
        titleLabel.fontSize = 30
        titleLabel.fontColor = .black
        titleLabel.position = CGPoint(x: frame.midX, y: frame.height - 50)
        addChild(titleLabel)

        for (index, city) in cities.enumerated() {
            let cityButton = SKLabelNode(text: city)
            cityButton.fontSize = 24
            cityButton.fontColor = unlockedCities.contains(city) ? .blue : .gray
            cityButton.position = CGPoint(x: frame.midX, y: frame.midY - CGFloat(index * 50))
            cityButton.name = city
            addChild(cityButton)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)

        for node in nodesAtPoint {
            if let cityName = node.name, unlockedCities.contains(cityName) {
                moveToCity(cityName: cityName)
            }
        }
    }

    func moveToCity(cityName: String) {
        let gameScene = GameScene(size: self.size)
        gameScene.currentCity = cityName
        let transition = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(gameScene, transition: transition)
    }

    func loadGameData() {
        if let savedCities = defaults.array(forKey: "unlockedCities") as? [String] {
            unlockedCities = Set(savedCities)
        } else {
            unlockedCities.insert("الطائف")
        }
    }
}
