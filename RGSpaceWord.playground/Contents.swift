/*: Playground documentation
 
 # Welcome to Răzvan's playground!
 
 ## I am happy to see you and I hope you have fun playing SpaceWord!
 
 * To play the game, slice the words where the correct space should be.
 * Slicing other parts of the phrase will make you loose 50 points, but will not change the game text.
 
 */
//#-hidden-code
import UIKit
import SpriteKit
import PlaygroundSupport

// Load the SKScene from 'GameScene.sks'
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))

// Construct the scene
let gameScene = RGGameScene(fileNamed: "GameScene")!

// Set the scale mode to scale to fit the window
gameScene.scaleMode = .aspectFill

// Present the scene
sceneView.presentScene(gameScene)
//#-end-hidden-code
/*: Editing part 1
 
 If you don't change the phrase, the game will start with a quote by **Steve Jobs**. Make sure you enter more than one space and enough letters.
 
 *With great phrases comes great scores!*
 
 */
gameScene.setGamePhrase(phrase: /*#-editable-code Write your own phrase*/"Here is my phrase"/*#-end-editable-code*/)

/*: Editing part 2
 
 Change the reaction to gravity to add or remove more effects to the spacing action.
 
 */
gameScene.setShouldReactToGravity(/*#-editable-code true/false*/true/*#-end-editable-code*/)
//#-hidden-code
// Set the current live view
PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
//#-end-hidden-code
/*: End part
 *Thank you very much for considering my application and taking the time to play!*
 
 *Răzvan*
 */
