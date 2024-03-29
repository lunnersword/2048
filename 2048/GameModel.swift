//
//  GameModel.swift
//  2048
//
//  Created by lunner on 5/5/15.
//  Copyright (c) 2015 lunner. All rights reserved.
//

import UIKit

protocol GameModelProtocal: class {
	func scoreChanged(score: Int)
	func highestScoreChanged(score: Int)
	func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int)
	func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int)
	func insertTile(lacation: (Int, Int), value: Int)
}

///A class representing the game state and game logic for 2048, it is owned by ViewController
class GameModel: NSObject {
	let dimension: Int
	var threshold: Int
	
	var highestScore: Int {
		didSet {
			delegate.scoreChanged(highestScore)
		}
	}
	var score: Int = 0 {
		didSet {
			delegate.scoreChanged(score)
		}
	}
	var gameboard: SquareGameboard<TileObject>
	let delegate: GameModelProtocal
	
	var queue: [MoveCommand]
	var timer: NSTimer
	
	let maxCommands = 100
	let queueDelay = 0.2
	
	init(dimension: Int, threshold: Int, highestScore: Int, delegate: GameModelProtocal) {
		self.dimension = dimension
		self.highestScore = highestScore
		self.threshold = threshold
		self.delegate = delegate
		queue = [MoveCommand]()
		timer = NSTimer()
		gameboard = SquareGameboard(dimension: dimension, initialValue: .Empty)
		
	}
	// Reset the game state
	func reset() {
		score = 0
		gameboard.setAll(.Empty)
		queue.removeAll(keepCapacity: true)
		timer.invalidate()
	}
	/// Order the game model to perform a move (because the user swiped their finger). The queue enforces a delay of a few
	/// milliseconds between each move.
	func queueMove(direction: MoveDirection, completion: (Bool) -> ()) {
		if queue.count > maxCommands {
			//this should actually never happen in practice
			return
		}
		let command = MoveCommand(direction: direction, completion: completion)
		queue.append(command)
		if !timer.valid {
			// Timer isn't running, so fire the event immediately
			timerFired(timer)
		}
	}
	
	/// Inform the game model that the move delay timer fired. Once the timer fires, the game model tries to execute a
	/// single move that changes the game state.
	func timerFired(timer: NSTimer) {
		if queue.count == 0 {
			return
		}
		// go through the queue until a valid command is run or the queue is empty
		var changed = false
		while queue.count > 0 {
			let command = queue[0]
			queue.removeAtIndex(0)
			changed = performMove(command.direction)
			command.completion(changed)
			if changed {
				break
			}
		}
		if changed {
			self.timer = NSTimer.scheduledTimerWithTimeInterval(queueDelay, target: self, selector: "timerFired:", userInfo: nil, repeats: false)
		}
	}
	/// Insert a tile with a given value at a position upon the gameboard.
	func insertTile(pos: (Int, Int), value: Int) {
		let (x, y) = pos
		switch gameboard[x, y] {
		case .Empty:
			gameboard[x, y] = TileObject.Tile(value)
			delegate.insertTile(pos, value: value)
		case .Tile:
			break
		}
	}
	
	/// Insert a tile with a given value at a random open position upon the gameboad
	func insertTileAtRandomLocation(value: Int) {
		let openSpots = gameboardEmptySpots()
		if openSpots.count == 0 {
			return
		}
		// randomly select an open spot, and put a new tile there
		let idx = Int(arc4random_uniform(UInt32(openSpots.count - 1)))
		let (x, y) = openSpots[idx]
		insertTile((x, y), value: value)
	}
	
	func gameboardEmptySpots() -> [(Int, Int)] {
		var buffer = Array<(Int, Int)>()
		for i in 0..<dimension {
			for j in 0..<dimension {
				switch gameboard[i, j] {
				case .Empty:
					buffer += [(i, j)]
				case .Tile:
					break
				}
			}
		}
		return buffer
	}
	
	func gameboardFull() -> Bool {
		return gameboardEmptySpots().count == 0
	}

	func tileBelowHasSameValue(loc: (Int, Int), _ value: Int) -> Bool {
		let (x, y) = loc
		if x == dimension-1 {
			return false
		}
		switch gameboard[x+1, y] {//switch gameboard[x, y+1] {
		case let .Tile(v):
			return v == value
		default:
			return false
		}
	}
	
	func tileToRightHasSameValue(loc: (Int, Int), _ value: Int) -> Bool {
		let (x, y) = loc
		if y == dimension-1 {
			return false
		}
		switch gameboard[x, y+1] {//switch gameboard[x+1, y] {
		case let .Tile(v):
			return v == value
		default:
			return false
		}
	}
	
	func userHasLost() -> Bool {
		if !gameboardFull() {
			// Player can't lose before filling up the board
			return false
		}
		
		// Run through all the tiles and check for possible moves
		for i in 0..<dimension {
			for j in 0..<dimension {
				switch gameboard[i, j] {
				case .Empty:
					assert(false, "Gameboard reported itself as full, but we still found an empty tile. This is a logic error.")
				case let .Tile(v):
					if self.tileBelowHasSameValue((i, j), v) || self.tileToRightHasSameValue((i, j), v) {
						return false
					}
				}
			}
		}
		return true
	}
	
	func userHasWon() -> (Bool, (Int, Int)?) {
		for i in 0..<dimension {
			for j in 0..<dimension {
				// Look for a tile with the winning score or greater
				switch gameboard[i, j] {
				case let .Tile(v) where v >= threshold:
					return (true, (i, j))
				default:
					continue
				}
			}
		}
		return (false, nil)
	}
	
	
	//------------------------------------------------------------------------------------------------------------------//
	
	// Perform all calculations and update state for a single move.
	func performMove(direction: MoveDirection) -> Bool {
		// Prepare the generator closure. This closure differs in behavior depending on the direction of the move. It is
		// used by the method to generate a list of tiles which should be modified. Depending on the direction this list
		// may represent a single row or a single column, in either direction.
		let coordinateGenerator: (Int) -> [(Int, Int)] = { (iteration: Int) -> [(Int, Int)] in
			var buffer = Array<(Int, Int)>(count:self.dimension, repeatedValue: (0, 0))
			for i in 0..<self.dimension {
				switch direction {
				case .Up: buffer[i] = (i, iteration)
				case .Down: buffer[i] = (self.dimension - i - 1, iteration)
				case .Left: buffer[i] = (iteration, i)
				case .Right: buffer[i] = (iteration, self.dimension - i - 1)
				}
			}
			return buffer
		}
		
		var atLeastOneMove = false
		for i in 0..<dimension {
			// Get the list of coords
			let coords = coordinateGenerator(i)
			
			// Get the corresponding list of tiles
			let tiles = coords.map() { (c: (Int, Int)) -> TileObject in
				let (x, y) = c
				return self.gameboard[x, y]
			}
			
			// Perform the operation
			let orders = merge(tiles)
			atLeastOneMove = orders.count > 0 ? true : atLeastOneMove
			
			// Write back the results
			for object in orders {
				switch object {
				case let MoveOrder.SingleMoveOrder(s, d, v, wasMerge):
					// Perform a single-tile move
					let (sx, sy) = coords[s]
					let (dx, dy) = coords[d]
					if wasMerge {
						score += v
					}
					gameboard[sx, sy] = TileObject.Empty
					gameboard[dx, dy] = TileObject.Tile(v)
					delegate.moveOneTile(coords[s], to: coords[d], value: v)
				case let MoveOrder.DoubleMoveOrder(s1, s2, d, v):
					// Perform a simultaneous two-tile move
					let (s1x, s1y) = coords[s1]
					let (s2x, s2y) = coords[s2]
					let (dx, dy) = coords[d]
					score += v
					gameboard[s1x, s1y] = TileObject.Empty
					gameboard[s2x, s2y] = TileObject.Empty
					gameboard[dx, dy] = TileObject.Tile(v)
					delegate.moveTwoTiles((coords[s1], coords[s2]), to: coords[d], value: v)
				}
			}
		}
		return atLeastOneMove
	}
	
	//------------------------------------------------------------------------------------------------------------------//
	
	/// When computing the effects of a move upon a row of tiles, calculate and return a list of ActionTokens
	/// corresponding to any moves necessary to remove interstital space. For example, |[2][ ][ ][4]| will become
	/// |[2][4]|.
	func condense(group: [TileObject]) -> [ActionToken] {
		var tokenBuffer = [ActionToken]()
		for (idx, tile) in enumerate(group) {
			// Go through all the tiles in 'group'. When we see a tile 'out of place', create a corresponding ActionToken.
			switch tile {
			case let .Tile(value) where tokenBuffer.count == idx:
				tokenBuffer.append(ActionToken.NoAction(source: idx, value: value))
			case let .Tile(value):
				tokenBuffer.append(ActionToken.Move(source: idx, value: value))
			default:
				break //break here is just break default cluster
			}
		}
		return tokenBuffer;
	}
	
	class func quiescentTileStillQuiescent(inputPosition: Int, outputLength: Int, originalPosition: Int) -> Bool {
		// Return whether or not a 'NoAction' token still represents an unmoved tile
		return (inputPosition == outputLength) && (originalPosition == inputPosition)
	}
	
	/// When computing the effects of a move upon a row of tiles, calculate and return an updated list of ActionTokens
	/// corresponding to any merges that should take place. This method collapses adjacent tiles of equal value, but each
	/// tile can take part in at most one collapse per move. For example, |[1][1][1][2][2]| will become |[2][1][4]|.
	func collapse(group: [ActionToken]) -> [ActionToken] {
		
		
		var tokenBuffer = [ActionToken]()
		var skipNext = false
		for (idx, token) in enumerate(group) {
			if skipNext {
				// Prior iteration handled a merge. So skip this iteration.
				skipNext = false
				continue
			}
			switch token {
			case .SingleCombine:
				assert(false, "Cannot have single combine token in input")
			case .DoubleCombine:
				assert(false, "Cannot have double combine token in input")
			case let .NoAction(s, v)
				where (idx < group.count-1
					&& v == group[idx+1].getValue()
					&& GameModel.quiescentTileStillQuiescent(idx, outputLength: tokenBuffer.count, originalPosition: s)):
				// This tile hasn't moved yet, but matches the next tile. This is a single merge
				// The last tile is *not* eligible for a merge
				let next = group[idx+1]
				let nv = v + group[idx+1].getValue()
				skipNext = true
				tokenBuffer.append(ActionToken.SingleCombine(source: next.getSource(), value: nv))
			case let t where (idx < group.count-1 && t.getValue() == group[idx+1].getValue()):
				// This tile has moved, and matches the next tile. This is a double merge
				// (The tile may either have moved prevously, or the tile might have moved as a result of a previous merge)
				// The last tile is *not* eligible for a merge
				let next = group[idx+1]
				let nv = t.getValue() + group[idx+1].getValue()
				skipNext = true
				tokenBuffer.append(ActionToken.DoubleCombine(source: t.getSource(), second: next.getSource(), value: nv))
			case let .NoAction(s, v) where !GameModel.quiescentTileStillQuiescent(idx, outputLength: tokenBuffer.count, originalPosition: s):
				// A tile that didn't move before has moved (first cond.), or there was a previous merge (second cond.)
				tokenBuffer.append(ActionToken.Move(source: s, value: v))
			case let .NoAction(s, v):
				// A tile that didn't move before still hasn't moved
				tokenBuffer.append(ActionToken.NoAction(source: s, value: v))
			case let .Move(s, v):
				// Propagate a move
				tokenBuffer.append(ActionToken.Move(source: s, value: v))
			default:
				// Don't do anything
				break
			}
		}
		return tokenBuffer
	}
	
	/// When computing the effects of a move upon a row of tiles, take a list of ActionTokens prepared by the condense()
	/// and convert() methods and convert them into MoveOrders that can be fed back to the delegate.
	func convert(group: [ActionToken]) -> [MoveOrder] {
		var moveBuffer = [MoveOrder]()
		for (idx, t) in enumerate(group) {
			switch t {
			case let .Move(s, v):
				moveBuffer.append(MoveOrder.SingleMoveOrder(source: s, destination: idx, value: v, wasMerge: false))
			case let .SingleCombine(s, v):
				moveBuffer.append(MoveOrder.SingleMoveOrder(source: s, destination: idx, value: v, wasMerge: true))
			case let .DoubleCombine(s1, s2, v):
				moveBuffer.append(MoveOrder.DoubleMoveOrder(firstSource: s1, secondSource: s2, destination: idx, value: v))
			default:
				// Don't do anything
				break
			}
		}
		return moveBuffer
	}
	
	/// Given an array of TileObjects, perform a collapse and create an array of move orders.
	func merge(group: [TileObject]) -> [MoveOrder] {
		// Calculation takes place in three steps:
		// 1. Calculate the moves necessary to produce the same tiles, but without any interstital space.
		// 2. Take the above, and calculate the moves necessary to collapse adjacent tiles of equal value.
		// 3. Take the above, and convert into MoveOrders that provide all necessary information to the delegate.
		return convert(collapse(condense(group)))
	}
}




