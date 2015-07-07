//
//  ViewController.swift
//  2048
//
//  Created by lunner on 3/5/15.
//  Copyright (c) 2015 lunner. All rights reserved.
//

import UIKit
import Foundation

enum GameStatus {
	case GameBegin
	case GameOver
	case GameWin
	case GameContinue
	
}
enum DefaultKeys: String {
	case DimensionKey = "DIMENSIONKEY"
	case ThresholdKey = "THRESHOLDKEY"
	case ScoreKey = "SCOREKEY"
	case HighestScoreKey = "HIGHESTSCOREKEY"
	
}

class ViewController: UIViewController, GameModelProtocal {
	@IBOutlet var currentScoreLabel: UILabel!
	@IBOutlet var highestScoreLabel: UILabel!
	@IBOutlet var menuButton: UIButton!
	@IBOutlet var scoreOrderButton: UIButton!
	@IBOutlet var swipeTilesView: UIView!

	@IBOutlet var tileBaseViews: [UIView]!
	var label: UILabel!
	
	let debugAids = true	
	
	var cornerRadius: CGFloat = 4
	var tileCornerRadius: CGFloat = 4
	var tiles: Dictionary<NSIndexPath, TileView> = Dictionary()
	
	let provider = AppearanceProvider()
	
	let tilePopStartScale: CGFloat = 0.1
	let tilePopMaxScale: CGFloat = 1.1
	let tilePopDelay: NSTimeInterval = 0.05
	let tileExpandTime: NSTimeInterval = 0.18
	let tileContractTime: NSTimeInterval = 0.08
	
	let tileMergeStartScale: CGFloat = 1.0
	let tileMergeExpandTime: NSTimeInterval = 0.08
	let tileMergeContractTime: NSTimeInterval = 0.08
	
	let perSquareSlideDuration: NSTimeInterval = 0.08
	var model: GameModel?

	
	//override func
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		//swipe left
		
		//setup gameModel
		setupCornerRadius(cornerRadius)
		setupTilesCornerRadius(tileCornerRadius)
		
		let userDefaults = NSUserDefaults.standardUserDefaults()
		let dim = userDefaults.integerForKey(DefaultKeys.DimensionKey.rawValue)
		let threshold = userDefaults.integerForKey(DefaultKeys.ThresholdKey.rawValue)
		let highestScore = userDefaults.integerForKey(DefaultKeys.HighestScoreKey.rawValue)
		highestScoreLabel.text = "\(highestScore)"
		highestScoreLabel.textAlignment = NSTextAlignment.Center
		currentScoreLabel.text = "\(0)"
		currentScoreLabel.textAlignment = NSTextAlignment.Center
		model = GameModel(dimension: dim, threshold: threshold, highestScore: highestScore, delegate: self)
		
		
		var swipeLeftGesture = UISwipeGestureRecognizer()
		swipeLeftGesture.addTarget(self, action: "swipedTiles:")
		swipeLeftGesture.direction = UISwipeGestureRecognizerDirection.Left
		swipeTilesView.addGestureRecognizer(swipeLeftGesture)
		//swipe right
		var swipeRightGesture = UISwipeGestureRecognizer(target: self, action: "swipedTiles:")
		swipeRightGesture.direction = UISwipeGestureRecognizerDirection.Right
		swipeTilesView.addGestureRecognizer(swipeRightGesture)
		//swipe up
		var swipeUpGesture = UISwipeGestureRecognizer(target: self, action: "swipedTiles:")
		swipeUpGesture.direction = UISwipeGestureRecognizerDirection.Up
		swipeTilesView.addGestureRecognizer(swipeUpGesture)
		//swipe down
		var swipeDownGesture = UISwipeGestureRecognizer(target: self, action: "swipedTiles:")
		swipeDownGesture.direction = UISwipeGestureRecognizerDirection.Down
		swipeTilesView.addGestureRecognizer(swipeDownGesture)
		
		swipeTilesView.userInteractionEnabled = true
		
		
		// below three line here cannot make tile position and size right move it to view did appear
//		assert(model != nil)
//		model!.insertTileAtRandomLocation(2)
//		model!.insertTileAtRandomLocation(2)
		
		if debugAids {
			println("view did loaded")
		}
	}
	override func viewDidAppear(animated: Bool) {
		assert(model != nil)
		model!.insertTileAtRandomLocation(2)
		model!.insertTileAtRandomLocation(2)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func setupCornerRadius(radius: CGFloat) {
		//let views = view.subviews
		for subView in view.subviews {
			if let subview = subView as? UIView {
				subview.layer.cornerRadius = radius
			}
		}
	}
	
	func setupTilesCornerRadius(radius: CGFloat) {
		for tileView in swipeTilesView.subviews {
			if let tile = tileView as? TileView {
				tile.layer.cornerRadius = radius
			}
		}
	}
	
	func resetTiles() {
		for (key, tile) in tiles {
			tile.removeFromSuperview()
		}
		tiles.removeAll(keepCapacity: true)
	}

	func reset() {
		assert(model != nil)
		resetTiles()
		model!.reset()
		model!.insertTileAtRandomLocation(2)
		model!.insertTileAtRandomLocation(2)
		
	}
	
	
	func positionIsValid(pos: (Int, Int)) -> Bool {
		assert(model != nil, "model is nil")
		let (x, y) = pos
		return (x >= 0 && x < model!.dimension && y >= 0 && y < model!.dimension)
	}
	
	func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
		UIGraphicsBeginImageContext(size)
		var context = UIGraphicsGetCurrentContext()
		
		CGContextSetFillColorWithColor(context, color.CGColor)
		var rect = CGRect()
		rect.size = size
		CGContextFillRect(context, rect)
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return image
	}
	func generateNewNum() -> Int {
		//2 90% 4 10%
		let randSed = arc4random_uniform(100)
		if randSed < 90 {
			return 2
		}
		else {
			return 4
		}
	}
	
	
	func gameRestart() {
		//clear tils
		//new two tiles
	}
	
	func gameOver() {
		
	}
	
	func followUp() {
		let (userWon, winningCoords) = model!.userHasWon()
		if userWon {
			// TODO: alert delegate we won
			let alertView = UIAlertView()
			alertView.title = "Victory"
			alertView.message = "You won!"
			alertView.addButtonWithTitle("Cancel")
			alertView.show()
			// TODO: At this point we should stall the game until the user taps 'New Game' (which hasn't been implemented yet)
			return
		}
		// Now, insert more tiles
		let randomVal = Int(arc4random_uniform(10))
		model!.insertTileAtRandomLocation(randomVal == 1 ? 4 : 2)
		
		// At this point, the user may lose
		if model!.userHasLost() {
			// TODO: alert delegate we lost
			NSLog("You lost...")
			let alertView = UIAlertView()
			alertView.title = "Defeat"
			alertView.message = "You lost..."
			alertView.addButtonWithTitle("Cancel")
			alertView.show()
		}

	}
	
	func swipedTiles(gesture: UISwipeGestureRecognizer) {
		switch gesture.direction {
		case UISwipeGestureRecognizerDirection.Down:
			model!.queueMove(MoveDirection.Down, completion: { (changed: Bool) -> () in
				if changed {
					self.followUp()
				}
			})
		case UISwipeGestureRecognizerDirection.Up:
			model!.queueMove(MoveDirection.Up, completion: { (changed: Bool) -> () in
				if changed {
					self.followUp()
				}
			})
		case UISwipeGestureRecognizerDirection.Left:
			model!.queueMove(MoveDirection.Left, completion: { (changed: Bool) -> () in
				if changed {
					self.followUp()
				}
			})
		case UISwipeGestureRecognizerDirection.Right:
			model!.queueMove(MoveDirection.Right, completion: { (changed: Bool) -> () in
				if changed {
					self.followUp()
				}
			})
		default:
			return
		}
	}
	
	// protocol
	func scoreChanged(score: Int) {
		currentScoreLabel.text = "\(score)"
	}
	
	func highestScoreChanged(score: Int) {
		highestScoreLabel.text = "\(score)"
	}
	
	/// Update the gameboard by inserting a tile in a given location. The tile will be inserted with a 'pop' animation.
	func insertTile(pos: (Int, Int), value: Int) {
		assert(positionIsValid(pos))
		let (row, col) = pos
		let r = tileCornerRadius//(cornerRadius >= 2) ? cornerRadius - 2 : 0
		let baseIndex = row*model!.dimension + col
		assert(baseIndex < model!.dimension*model!.dimension && baseIndex >= 0, "baseIndex out of range")
		let base = tileBaseViews[baseIndex]
		let tile = TileView(base: base, value: value, radius: r, delegate: provider)
		tile.layer.setAffineTransform(CGAffineTransformMakeScale(tilePopStartScale, tilePopStartScale))
		swipeTilesView.addSubview(tile)
		swipeTilesView.bringSubviewToFront(tile)
		tile.setNeedsDisplay()
		tiles[NSIndexPath(forRow: row, inSection: col)] = tile
		
		// Add to board
		UIView.animateWithDuration(tileExpandTime, delay: tilePopDelay, options: UIViewAnimationOptions.TransitionNone,
			animations: { () -> Void in
				// Make the tile 'pop'
				tile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
			},
			completion: { (finished: Bool) -> Void in
				// Shrink the tile after it 'pops'
				UIView.animateWithDuration(self.tileContractTime, animations: { () -> Void in
					tile.layer.setAffineTransform(CGAffineTransformIdentity)
				})
		})
	}
	
	/// Update the gameboard by moving a single tile from one location to another. If the move is going to collapse two
	/// tiles into a new tile, the tile will 'pop' after moving to its new location.
	func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int) {
		assert(positionIsValid(from) && positionIsValid(to))
		let (fromRow, fromCol) = from
		let (toRow, toCol) = to
		let fromKey = NSIndexPath(forRow: fromRow, inSection: fromCol)
		let toKey = NSIndexPath(forRow: toRow, inSection: toCol)
		
		// Get the tiles
		assert(tiles[fromKey] != nil)
		let tile = tiles[fromKey]!
		let endTile = tiles[toKey]
		
		let baseIndex = toRow*model!.dimension + toCol
		assert(baseIndex < model!.dimension*model!.dimension && baseIndex >= 0, "baseIndex out of range")
		let toBase = tileBaseViews[baseIndex]
		// Make the frame
		var finalFrame = toBase.frame
		
		// Update board state
		tiles.removeValueForKey(fromKey)
		tiles[toKey] = tile
		
		// Animate
		let shouldPop = endTile != nil
		UIView.animateWithDuration(perSquareSlideDuration,
			delay: 0.0,
			options: UIViewAnimationOptions.BeginFromCurrentState,
			animations: { () -> Void in
				// Slide tile
				tile.frame = finalFrame
			},
			completion: { (finished: Bool) -> Void in
				tile.value = value
				endTile?.removeFromSuperview()
				if !shouldPop || !finished {
					return
				}
				tile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tileMergeStartScale, self.tileMergeStartScale))
				// Pop tile
				UIView.animateWithDuration(self.tileMergeExpandTime,
					animations: { () -> Void in
						tile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
					},
					completion: { (finished: Bool) -> () in
						// Contract tile to original size
						UIView.animateWithDuration(self.tileMergeContractTime,
							animations: { () -> Void in
								tile.layer.setAffineTransform(CGAffineTransformIdentity)
						})
				})
		})
	}
	
	/// Update the gameboard by moving two tiles from their original locations to a common destination. This action always
	/// represents tile collapse, and the combined tile 'pops' after both tiles move into position.
	func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
		assert(positionIsValid(from.0) && positionIsValid(from.1) && positionIsValid(to))
		let (fromRowA, fromColA) = from.0
		let (fromRowB, fromColB) = from.1
		let (toRow, toCol) = to
		let fromKeyA = NSIndexPath(forRow: fromRowA, inSection: fromColA)
		let fromKeyB = NSIndexPath(forRow: fromRowB, inSection: fromColB)
		let toKey = NSIndexPath(forRow: toRow, inSection: toCol)
		
		assert(tiles[fromKeyA] != nil)
		assert(tiles[fromKeyB] != nil)
		let tileA = tiles[fromKeyA]!
		let tileB = tiles[fromKeyB]!
		
		// Make the frame
		let baseIndex = toRow*model!.dimension + toCol
		assert(baseIndex < model!.dimension*model!.dimension && baseIndex >= 0, "baseIndex out of range")

		var finalFrame = tileBaseViews[baseIndex].frame
				
		// Update the state
		let oldTile = tiles[toKey]  // TODO: make sure this doesn't cause issues
		oldTile?.removeFromSuperview()
		tiles.removeValueForKey(fromKeyA)
		tiles.removeValueForKey(fromKeyB)
		tiles[toKey] = tileA
		
		UIView.animateWithDuration(perSquareSlideDuration,
			delay: 0.0,
			options: UIViewAnimationOptions.BeginFromCurrentState,
			animations: { () -> Void in
				// Slide tiles
				tileA.frame = finalFrame
				tileB.frame = finalFrame
			},
			completion: { (finished: Bool) -> Void in
				tileA.value = value
				tileB.removeFromSuperview()
				if !finished {
					return
				}
				tileA.layer.setAffineTransform(CGAffineTransformMakeScale(self.tileMergeStartScale, self.tileMergeStartScale))
				// Pop tile
				UIView.animateWithDuration(self.tileMergeExpandTime,
					animations: { () -> Void in
						tileA.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
					},
					completion: { (finished: Bool) -> Void in
						// Contract tile to original size
						UIView.animateWithDuration(self.tileMergeContractTime,
							animations: { () -> Void in
								tileA.layer.setAffineTransform(CGAffineTransformIdentity)
						})
				})
		})
	}

}

