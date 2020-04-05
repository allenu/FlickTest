//
//  ViewController.swift
//  FlickTest
//
//  Created by Allen Ussher on 4/5/20.
//  Copyright © 2020 Ussher Press. All rights reserved.
//

import Cocoa

class PlayfieldLayer: CALayer {
    var cardLayer: CardLayer!
    
    override init(layer: Any) {
        super.init(layer: layer)
        
        cardLayer = CardLayer(layer: self)
        addSublayer(cardLayer)

        backgroundColor = Colors.contentArea.cgColor
        cornerRadius = 12.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        let cardWidth: CGFloat = (bounds.width/3.0).rounded()
        let cardHeight: CGFloat = ((cardWidth * 4.0)/3.0).rounded()
        cardLayer.bounds = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
        cardLayer.position = CGPoint(x: bounds.midX.rounded(), y: bounds.midY.rounded())
    }
    
    func flickCardLeft(completionHandler: @escaping () -> Void) {
        
        let targetPosition = CGPoint(x: -cardLayer.bounds.width / 2.0, y: cardLayer.position.y)
        let anim = CABasicAnimation(keyPath: "position")
        anim.fromValue = cardLayer.position
        anim.toValue = targetPosition
        anim.duration = 0.3
        
        cardLayer.add(anim, forKey: "position")

        // Set it now so that when anim is complete, we don't need to set it again
        cardLayer.position = targetPosition

        DispatchQueue.main.asyncAfter(deadline: .now() + anim.duration, execute: {
            completionHandler()
        })
    }
    
    func moveCardOffScreen() {
        // Do not animate
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let targetPosition = CGPoint(x: (bounds.midX.rounded()), y: -cardLayer.bounds.height)
        cardLayer.position = targetPosition
        
        CATransaction.commit()
    }
    
    func popCardUp(completionHandler: @escaping () -> Void) {
        
        let targetPosition = CGPoint(x: bounds.midX.rounded(), y: bounds.midY.rounded())
        let anim = CABasicAnimation(keyPath: "position")
        anim.fromValue = cardLayer.position
        anim.toValue = targetPosition
        anim.duration = 0.3
        
        cardLayer.add(anim, forKey: "position")

        // Set it now so that when anim is complete, we don't need to set it again
        cardLayer.position = targetPosition

        DispatchQueue.main.asyncAfter(deadline: .now() + anim.duration, execute: {
            completionHandler()
        })
    }
}

class CardLayer: CALayer {
    
    lazy var textLayer: CATextLayer = {
        let textLayer = CATextLayer()
        
        // Make it not blurry
        textLayer.contentsScale = NSScreen.main!.backingScaleFactor
        
        textLayer.isWrapped = true
        
        textLayer.anchorPoint = .zero
//        textLayer.backgroundColor = NSColor.green.cgColor
        textLayer.string = "Hello, world! This is some text"
        textLayer.font = NSFont(name: "Arial Rounded MT Bold", size: 24.0)
        textLayer.foregroundColor = Colors.cardText.cgColor
        
        return textLayer
    }()

    override init(layer: Any) {
        super.init(layer: layer)
        
        addSublayer(textLayer)
        
        backgroundColor = Colors.bottomCard.cgColor
        cornerRadius = 12.0
        masksToBounds = false
        
        // Set shadow
        shadowOpacity = 0.5
        shadowOffset = CGSize(width: 0.0, height: -24.0)
        shadowColor = Colors.contentAreaLightText.cgColor
        shadowRadius = 12.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        // Don't animate this
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let targetBounds = self.bounds.insetBy(dx: 20.0, dy: 60.0)
        // Need to set bounds origin to 0,0 and position at where target bounds are
        textLayer.bounds = CGRect(x: 0, y: 0, width: targetBounds.width, height: targetBounds.height)
        textLayer.position = targetBounds.origin
        CATransaction.commit()
    }
}

class ViewController: NSViewController {
    
    var state: UserInteractionState = .popping
    var playfieldLayer: PlayfieldLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.wantsLayer = true
        
        playfieldLayer = PlayfieldLayer(layer: view.layer!)
        view.layer = playfieldLayer
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        view.window?.makeFirstResponder(view)

        playfieldLayer.moveCardOffScreen()
        // Pop that card up
        playfieldLayer.popCardUp {
            self.state = .idle
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func keyDown(with theEvent: NSEvent) {
        // Only allow user input if in idle state
        guard case UserInteractionState.idle = state else { return }
        
        if theEvent.keyCode == 123 { // Left cursor key
            Swift.print("left")
            
            startFlicking()
        } else if theEvent.keyCode == 124 { // Right cursor key
            Swift.print("right")
        } else if theEvent.keyCode == 125 { // down cursor key
            Swift.print("down")
        } else if theEvent.keyCode == 53 { // Esc
            Swift.print("Esc")
        }
    }
    
    func startFlicking() {
        state = .flicking
        playfieldLayer.flickCardLeft(completionHandler: {
            // Re-position to off-screen at bottom
            self.state = .movingOffScreen
            self.playfieldLayer.moveCardOffScreen()
            
            // Now it's off-screen, so start the popping animation
            self.state = .popping
            self.playfieldLayer.popCardUp {
                self.state = .idle
            }
        })
    }
}
