//
//  RGGameScene.swift
//  RGSpaceWord
//
//  Created by Răzvan-Gabriel Geangu on 31/03/2018.
//  Copyright © 2018 Răzvan-Gabriel Geangu. All rights reserved.
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import SpriteKit
import AVFoundation

public class RGGameScene: SKScene {
    
    private let quote = "There’s lots of ways to be as a person, and some people express their deep appreciation in different ways, but one of the ways that I believe people express their appreciation to the rest of humanity is to make something wonderful and put it out there."
    
    /**
     This Double is used to move the nodes at a certain speed. Default value is 0.8 and should not be less than 0.3.
     */
    private var movementDuration = 0.8 {
        didSet {
            moveNodes(duration: movementDuration)
        }
    }
    
    /**
     The score of the game. Initially 0, increased to 100 as a bonus
     and formatted to display decimal style.
     */
    var score: Int = 0 {
        didSet {
            
            // Create a number formatter to display with decimal style
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            let formattedNumber = numberFormatter.string(from: NSNumber(value: score))
            
            if let scoreLabel = scoreLabel {
                
                // Set the score label to the formatted number
                scoreLabel.text = formattedNumber
            }
            
            // If the score is higher than the best score
            if score > bestScore {
                
                // Set the current best score.
                bestScore = score
            }
        }
    }
    
    /**
     This is used to store the best score during a session.
     */
    var bestScore: Int = 0
    
    /**
     This is used to store the text that is used for this game.
     */
    private var gameText: String = "" {
        didSet {
            removeLetterNodes()
        }
    }
    
    /**
     The background node that displays an image.
     */
    private lazy var background = childNode(withName: "background") as? SKSpriteNode
    
    /**
     The score label that displays the current score of the game.
     */
    private lazy var scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
    
    /**
     This is an sequence of letter nodes. It is used to understand
     where spaces are needed by getting the position of each node and
     matching the touch with the space indices/current space index.
     */
    private var letterNodes = [SKLabelNode]()
    
    /**
     The phrase of the game.
     */
    private var phrase = "" {
        didSet {
            // Remove the spaces and new lines (which are threated as spaces) from the game text
            gameText = phrase.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    /**
     The space indices stored in a sequence.
     */
    private var spaceIndices = [Int]() {
        didSet {
            // If it is empty, we end the game
            if spaceIndices.isEmpty {
                
                // Reset the game state
                isPlaying = false
            } else {
                
                // If the game runs
                if isPlaying {
                    
                    // Bonus starting score = 100
                    score += 100
                    
                    // Add the amount lost from blade effect
                    score += 50
                    
                    // Increase the speed of the game with on variable change
                    if movementDuration > 0.3 {
                        movementDuration -= 0.05
                    }
                }
            }
        }
    }
    
    /**
     A variable that describes the state of the game.
     Controls the views for the specific state.
     */
    private var isPlaying = false {
        didSet {
            if isPlaying {
                
                // If no phrase comes from the user
                if phrase.isEmpty {
                    
                    // Reset the game text
                    phrase = quote
                }
                
                // Add the letter nodes to the screen
                addLetterNodes(withText: gameText)
                
                // Set the movement duration to default
                movementDuration = 0.8
                
                // Check if score label is created
                if let scoreLabel = scoreLabel {
                    
                    // Check if score label is added to the view
                    if scoreLabel.parent == nil {
                        
                        // Add the score label to the view
                        addChild(scoreLabel)
                    }
                }
                
                // Remove the initial labels
                playPauseButton.removeFromParent()
                finalScoreLabel.removeFromParent()
            } else {
                
                // Set the final score label
                setScores()
                
                // Reset the score to 0
                score = 0
                
                // Remove the letter nodes
                removeLetterNodes()
                
                // Remove the current score label
                scoreLabel?.removeFromParent()
                
                // Add the initial labels
                addChild(playPauseButton)
                addChild(finalScoreLabel)
            }
        }
    }
    
    /**
     The first label with information about how to start the game.
     */
    private var playPauseButton: SKLabelNode = {
        // Initialise
        let playPauseButton = SKLabelNode(text: "Tap anywhere to play")
        
        // No action needed on this node
        playPauseButton.isUserInteractionEnabled = true
        
        // Style
        playPauseButton.fontColor = .white
        playPauseButton.fontSize = 36
        playPauseButton.fontName = "Chalkduster"
        playPauseButton.horizontalAlignmentMode = .center
        
        // Unique identifier
        playPauseButton.name = "-1"
        
        return playPauseButton
    }()
    
    /**
     The best score label that gets added after the game is finished.
     */
    private var finalScoreLabel: SKLabelNode = {
        // Initialise
        let finalScoreLabel = SKLabelNode(text: "Best Score: 0")
        
        // No action needed on this node
        finalScoreLabel.isUserInteractionEnabled = false
        
        // Style
        finalScoreLabel.fontColor = .white
        finalScoreLabel.fontSize = 24
        finalScoreLabel.fontName = "Chalkduster"
        finalScoreLabel.horizontalAlignmentMode = .center
        finalScoreLabel.position.y -= 100
        
        // Unique identifier
        finalScoreLabel.name = "-2"
        
        return finalScoreLabel
    }()
    
    /**
     This variable tells the label nodes if they should be spaced by position or react to gravity.
     */
    private var shouldReactToGravity = false
    
    /**
     This generator adds haptic feedback when slice is successful.
     */
    private let generator = UIImpactFeedbackGenerator(style: .medium)
    
    public override func didMove(to view: SKView) {
        
        // Remove the score label from the parent as we do not needed on the first view
        scoreLabel?.removeFromParent()
        
        // Add the start node label
        addChild(playPauseButton)
        
        // Add to the view the final score label
        addChild(finalScoreLabel)
        
        // Set the score to 0
        score = 0
        
        playSound(fileName: "sound_background", type: .background)
        player?.numberOfLoops = 10
        playSound(fileName: "sound_slice", type: .slice)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Get only the first touch to display the blade
        guard let touch = touches.first else {
            return
        }
        
        // Get the touch location
        let touchLocation = touch.location(in: self)
        
        // Present the blade at position
        presentBladeAtPosition(touchLocation)
        
        // If it is not playing
        if !isPlaying {
            
            // Reset the game state
            isPlaying = true
            
            // Set the space indices from the phrase which triggers the game to start
            spaceIndices = getSpacesIndices(from: phrase)
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Get the first touch for the blade
        guard let touch = touches.first else {
            return
        }
        
        // Get the current point
        let currentPoint = touch.location(in: self)
        
        // Get the previous point
        let previousPoint = touch.previousLocation(in: self)
        
        // Calculate the distance for the blade
        delta = CGPoint(x: currentPoint.x - previousPoint.x, y: currentPoint.y - previousPoint.y)
        
        // If the slice player is initialised
        if let slicePlayer = slicePlayer {
            
            // If slice was executed
            if delta.y > 20 || delta.y < -20 {
                
                // Play a slice sound
                slicePlayer.play()
            }
        }
        
        // Get the touched nodes in the scene
        guard let touchedNodes = scene?.nodes(at: touch.location(in: self)) else { return }
        
        // If the current space index exists
        if let currentSpaceIndex = spaceIndices.first {
            
            if touchedNodes.contains(where: { (node) -> Bool in
                guard let nodeName = node.name else { return false }
                
                if let nodeIndex = Int(nodeName) {
                    if nodeIndex == currentSpaceIndex - 1 || nodeIndex == currentSpaceIndex + 1 {
                        return true
                    }
                }
                
                return false
            }) {
                if delta.y > 20 || delta.y < -20 {
                    // Add a space to the nodes to all the nodes to the current space index
                    addSpace(at: currentSpaceIndex)
                
                    // Remove the first space index that has been found.
                    spaceIndices.removeFirst()
                    
                    // Add haptic feedback
                    generator.impactOccurred()
                }
            } else if touchedNodes.contains(where: { (node) -> Bool in
                guard let _ = node as? SKLabelNode else { return false }
                return true
            }) {
                // Decrease score when not touching right nodes
                score -= 50
            }
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Remove the blade on touch ended
        removeBlade()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Remove the blade on touch cancelled
        removeBlade()
    }
    
    public override func update(_ currentTime: TimeInterval) {
        if isPlaying {
            if letterNodes[spaceIndices[0]].position.x < frame.minX {
                
                // Stop game if the space is not inserted at the correct index
                isPlaying = false
            } else {
                
                // Add the right ammount based on the speed
                score += 1 * letterNodes.count / spaceIndices.count
            }
        }
        
        // if the blade is not available return
        guard let blade = blade else {
            return
        }
        
        // Add the delta to the new position
        let newPosition = CGPoint(x: blade.position.x + delta.x, y: blade.position.y + delta.y)
        
        // Set the new position
        blade.position = newPosition
        
        // Reseting the delta to only move the blade on touch move
        delta = .zero
    }
    
    /**
     A function that adds the letter nodes to the view one after the other.
     It sets the name to a unique identifier represented by an integer which
     describes the index of the letter node in the sequence.
     
     - parameter withText: A **String** that describes the text that needs to be split in nodes.
     */
    func addLetterNodes(withText: String) {
        
        // Initialise the unique identifier
        var uniqueID = 0
        
        // Loop through the characters of the text
        for character in withText {
            
            // Create a new label node with the character
            let letterNode = SKLabelNode(text: String(character))
            
            letterNode.physicsBody = SKPhysicsBody(circleOfRadius: letterNode.frame.width)
            letterNode.physicsBody!.affectedByGravity = false
            letterNode.physicsBody!.isDynamic = true
            letterNode.physicsBody!.allowsRotation = true
            
            // Set the style
            letterNode.horizontalAlignmentMode = .left
            letterNode.fontName = "Chalkduster"
            letterNode.fontSize = 96
            
            // Set the unique identifier
            letterNode.name = "\(uniqueID)"
            uniqueID += 1
            
            // Set the position of the nodes if first one is already added
            if letterNodes.count > 0 {
                
                // Position the new node right after the last one
                letterNode.position = CGPoint(x: letterNodes.last!.frame.maxX, y: 0)
            }
            
            // Add the node to the view
            addChild(letterNode)
            
            // Add the node to the letter nodes sequence
            letterNodes.append(letterNode)
        }
    }
    
    /**
     A function that removes the letter nodes from the view and resets the letter nodes sequence.
     */
    func removeLetterNodes() {
        removeChildren(in: letterNodes)
        letterNodes.removeAll()
    }
    
    /**
     A function that gets the spaces indices from a word.
     
     - parameter from phrase: A **String** that represents the word for which the spaces are needed to be found.
     
     - Returns: A sequence of **Int** that represent the indices of the spaces in the phrase.
     */
    func getSpacesIndices(from words: String) -> [Int] {
        
        // Initialise the index
        var index = 0
        
        // Initialise the indices sequence.
        var indices = [Int]()
        
        // Loop through all the characters in the phrase
        for character in words {
            
            // If the character is represented by a space or a new line
            if CharacterSet.whitespacesAndNewlines.contains(character.unicodeScalars.first!) {
                
                // Append the index to the sequence
                indices.append(index)
            }
            
            // Increase the index variable
            index += 1
        }
        
        // Return the sequence
        return indices
    }
    
    /**
     A function that adds a space at an index in the phrase.
     It moves all the nodes before the index by 60 points to the left.
     
     - parameter at index: The index of the last node in the sequence to be moved.
     */
    func addSpace(at index: Int) {
        
        // Loop through all the letter nodes
        for node in letterNodes {
            
            // If the node name (that contains the unique identifier as an Int) is equal tou our index
            if Int(node.name!) == index {
                
                // Stop
                break
            } else {
                
                if shouldReactToGravity {
                    
                    // React to gravity
                    node.physicsBody!.affectedByGravity = true
                    node.physicsBody!.applyImpulse(CGVector(dx: -10, dy: 0))
                    node.physicsBody!.applyAngularImpulse(0.1)
                } else {
                    
                    // Move the nodes to the left by 60 points
                    node.position.x -= 60
                }
            }
        }
    }
    
    /**
     Creates the action that moves the nodes by 128 points to the left.
     The action repeats forever and removes all the actions that are stored before in the letter nodes.
     
     - parameter duration: A **Double** that represents the time needed to move the nodes by 128 points.
     */
    func moveNodes(duration: Double) {
        
        // Create the action
        let moveLeft = SKAction.moveBy(x: -128, y: 0, duration: duration)
        
        // Loop through all the letter nodes
        for node in letterNodes {
            
            // Remove all the actions
            node.removeAllActions()
            
            // Run forever the move left action
            node.run(SKAction.repeatForever(moveLeft))
        }
    }
    
    /**
     The player for the background sound.
     */
    var player: AVAudioPlayer?
    
    /**
     The player for the touch/slice sound.
     */
    var slicePlayer: AVAudioPlayer?
    
    /**
     An enum that describes the sound types.
     */
    enum SoundType {
        case background
        case slice
    }
    
    /**
     A function to play a sound.
     
     - parameter fileName: A **String** that contains the name of the sound. The file needs to be with the mp3 extension.
     */
    @available(iOS 11, *)
    func playSound(fileName: String, type: SoundType) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            switch type {
            case .background:
                do {
                    player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                    
                    guard let player = player else { return }
                    player.play()
                }
            case .slice:
                do {
                    slicePlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                }
            }
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    /**
     Optional variable for the blade.
     */
    var blade: SWBlade?
    
    /**
     Helps with the positioning of the blade.
     */
    var delta: CGPoint = .zero
    
    /**
     A function that presents the blade a position in the view.
     
     - parameter position: The **CGPoint** position where the blade needs to be shown.
     */
    func presentBladeAtPosition(_ position:CGPoint) {
        blade = SWBlade(position: position, target: self, color: .white)
        
        guard let blade = blade else {
            debugPrint("Could not initialise blade")
            return
        }
        
        // Add blade to the view
        addChild(blade)
    }
    
    /**
     A function to remove the blade from the view.
     */
    func removeBlade() {
        delta = .zero
        blade!.removeFromParent()
    }
    
    private func setScores() {
        // Create a number formatter
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedBestScore = numberFormatter.string(from: NSNumber(value: bestScore))
        let formattedScore = numberFormatter.string(from: NSNumber(value: score))
        
        // Set the best score within the label
        finalScoreLabel.text = "Your Score: \(formattedScore!) Best Score: \(formattedBestScore!)"
    }

    /**
     A function to set the game phrase.
     
     - parameter phrase: The phrase of the game.
     */
    public func setGamePhrase(phrase: String) {
        if !phrase.isEmpty {
            self.phrase = phrase
        }
    }
    
    /**
     A function to set the game physics.
     
     - parameter value: A *Bool* that tells the scene if the spaced words should react to gravity.
     */
    public func setShouldReactToGravity(_ value: Bool) {
        shouldReactToGravity = value
    }
}
