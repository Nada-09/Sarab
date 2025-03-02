//
//  GameScene.swift
//  Sarab
//
//  Created by Nada Abdullah on 02/09/1446 AH.
//

//
//  GameScene.swift
//  Sarab
//
//  Created by Nada Abdullah on 02/09/1446 AH.
//

import SpriteKit

class GameScene: SKScene {
    var player: SKShapeNode!
    var npc: SKShapeNode!
    
    var answeredPuzzles: Set<String> = [] // قائمة الألغاز المجابة
    var hintCount = 0 // 🔥 تتبع عدد التلميحات المستخدمة
    let defaults = UserDefaults.standard // نظام الحفظ
    var currentCity = "الطائف" // 🔥 تتبع المدينة الحالية
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        loadGameData() // تحميل التقدم المحفوظ عند بدء اللعبة
        
        // 🔥 إنشاء اللاعب (دائرة)
        player = SKShapeNode(circleOfRadius: 30)
        player.fillColor = .blue
        player.position = CGPoint(x: frame.midX - 300, y: frame.midY)
        addChild(player)

        // 🔥 إنشاء NPC (مربع)
        npc = SKShapeNode(rectOf: CGSize(width: 50, height: 50))
        npc.fillColor = .red
        npc.position = CGPoint(x: frame.midX + 300, y: frame.midY)
        addChild(npc)

        // 🔥 زر العودة للخريطة (تحريك الزر للأسفل ليراه اللاعب)
        let mapButton = SKLabelNode(text: "🗺 العودة للخريطة")
        mapButton.fontSize = 24
        mapButton.fontColor = .red // ✅ تغيير اللون ليكون واضحًا
        mapButton.position = CGPoint(x: frame.midX, y: frame.minY + 100) // ✅ تحريك الزر للأسفل
        mapButton.name = "mapButton"
        addChild(mapButton)
        
        // 🔥 إضافة تسمية فوق الـ NPC
        let npcLabel = SKLabelNode(text: "👴 شيخ \(currentCity)")
        npcLabel.fontSize = 18
        npcLabel.fontColor = .black
        npcLabel.position = CGPoint(x: npc.position.x, y: npc.position.y + 40)
        addChild(npcLabel)
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)

        for node in nodesAtPoint {
            if node.name == "mapButton" {
                let transition = SKTransition.fade(withDuration: 1.0)
                self.view?.presentScene(MapScene(size: self.size), transition: transition)
                return
            }

            if npc.contains(location) {
                startPuzzle()
            }
        }
    }

    // 🔥 تشغيل اللغز عند لمس الـ NPC
    func startPuzzle() {
        let puzzlesByCity: [String: [(String, [String], String, String)]] = [
            "الطائف": [
                ("كم كيلو من الورد يحتاج لإنتاج لتر واحد من ماء الورد؟", ["5,000 وردة", "10,000 وردة", "15,000 وردة"], "10,000 وردة", "👀 تحتاج إلى حوالي 10,000 وردة!"),
                ("متى يتم قطف الورد الطائفي؟", ["الصباح الباكر", "منتصف النهار", "المساء"], "الصباح الباكر", "🌞 يتم قطفه في الصباح الباكر للحفاظ على زيوته العطرية."),
                ("لماذا يتم تقطير الورد الطائفي في أواني نحاسية؟", ["لزيادة النقاوة", "لمنع الاحتراق", "لتغيير اللون"], "لزيادة النقاوة", "🔥 النحاس يساعد في نقاوة ماء الورد!")
            ],
            "جدة": [
                ("ما هو أشهر حي تراثي في جدة؟", ["حي البلد", "حي الورود", "حي البساتين"], "حي البلد", "🏛️ حي البلد هو القلب التاريخي لجدة!"),
                ("لماذا كانت المشربيات (الروشان) مهمة في المنازل الحجازية؟", ["للخصوصية", "لتخزين الطعام", "للهواء البارد"], "للخصوصية", "🏡 المشربيات توفر الخصوصية وتهوية ممتازة."),
                ("أي ميناء تاريخي كان يستخدم لتجارة التوابل عبر جدة؟", ["ميناء السويس", "ميناء المخا", "ميناء ينبع"], "ميناء المخا", "⚓ ميناء المخا كان مركزًا رئيسيًا لتجارة التوابل!")
            ]
        ]
        
        guard let puzzles = puzzlesByCity[currentCity] else { return }
        
        let availablePuzzles = puzzles.filter { !answeredPuzzles.contains($0.0) }
        
        if availablePuzzles.isEmpty {
            moveToNextCity()
            return
        }
        
        let randomPuzzle = availablePuzzles.randomElement()!
        
        let puzzleAlert = UIAlertController(title: "🔍 لغز \(currentCity)", message: randomPuzzle.0, preferredStyle: .alert)
        
        let hintAction = UIAlertAction(title: "🔎 تلميح", style: .default) { _ in
            self.hintCount += 1
            self.showAlert(title: "💡 تلميح:", message: randomPuzzle.3)
        }
        puzzleAlert.addAction(hintAction)
        
        for choice in randomPuzzle.1 {
            puzzleAlert.addAction(UIAlertAction(title: choice, style: .default, handler: { action in
                if action.title == randomPuzzle.2 {
                    self.answeredPuzzles.insert(randomPuzzle.0)
                    self.saveGameData()
                    self.showAlert(title: "✅ صحيح!", message: "أحسنت! إجابة صحيحة! 🎉")
                } else {
                    self.showAlert(title: "❌ خطأ!", message: "إجابة خاطئة! حاول مرة أخرى.")
                }
            }))
        }
        
        puzzleAlert.addAction(UIAlertAction(title: "إلغاء", style: .cancel, handler: nil))
        
        if let viewController = self.view?.window?.rootViewController {
            viewController.present(puzzleAlert, animated: true, completion: nil)
        }
    }

    func moveToNextCity() {
        let cityOrder = ["الطائف", "جدة", "الرياض"] // 🔥 ترتيب المدن
        if let currentIndex = cityOrder.firstIndex(of: currentCity), currentIndex < cityOrder.count - 1 {
            currentCity = cityOrder[currentIndex + 1] // 🔥 الانتقال للمدينة التالية
            answeredPuzzles.removeAll() // 🔥 إعادة تعيين الألغاز للمدينة الجديدة
            saveGameData() // ✅ حفظ المدينة الجديدة
            showAlert(title: "🚀 انتقال!", message: "تهانينا! لقد أكملت \(cityOrder[currentIndex]) والآن تتجه إلى \(currentCity)!")
        } else {
            showAlert(title: "🎉 نهاية المغامرة!", message: "لقد أكملت جميع المدن! 🚀🎮")
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "حسنًا", style: .default, handler: nil))
        
        if let viewController = self.view?.window?.rootViewController {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    func saveGameData() {
        defaults.set(Array(answeredPuzzles), forKey: "answeredPuzzles")
        defaults.set(hintCount, forKey: "hintCount")
        defaults.set(currentCity, forKey: "currentCity") // ✅ حفظ المدينة الحالية
    }

    func loadGameData() {
        if let savedPuzzles = defaults.array(forKey: "answeredPuzzles") as? [String] {
            answeredPuzzles = Set(savedPuzzles)
        }
        hintCount = defaults.integer(forKey: "hintCount")
        currentCity = defaults.string(forKey: "currentCity") ?? "الطائف"
    }
}
