//
//  AuxiliaryModels.swift
//  2048
//
//  Created by lunner on 5/5/15.
//  Copyright (c) 2015 lunner. All rights reserved.
//

import Foundation

/// An enum representing directions supported by the game 
enum MoveDirection {
	case Up
	case Down
	case Left
	case Right
}

/// An enum representing movement command issued by the view controller as the result of the user swiping
struct MoveCommand {
	var direction: MoveDirection
	var completion: (Bool) -> ()
	init(direction: MoveDirection, completion: (Bool) -> ()) {
		self.direction = direction
		self.completion = completion
	}
}

/// An enum representing a 'move order'. This is a data structure the game model use to inform the view controller
/// which tiles on the board should be moved and/or combined.
enum MoveOrder {
	case SingleMoveOrder(source: Int, destination: Int, value: Int, wasMerge: Bool)
	case DoubleMoveOrder(firstSource: Int, secondSource: Int, destination: Int, value: Int)
}

/// An enum representing either an empty space or a tile upon the board
enum TileObject {
	case Empty
	case Tile(Int)
}

/// An enum representing an intermediate result used by the game logic when figuring out how the board should change as
/// the result of a move. ActionTokens are transformed into MoveOrders before being sent to the delegate
enum ActionToken {
	case NoAction(source: Int, value: Int)
	case Move(source: Int, value: Int)
	case SingleCombine(source: Int, value: Int)
	case DoubleCombine(source: Int, second: Int, value: Int)
	
	// get the 'value', regardless of the specific type
	func getValue() -> Int {
		switch self {
		case let .NoAction(_, v): return v
		case let .Move(_, v): return v
		case let .SingleCombine(_, v): return v
		case let .DoubleCombine(_, _, v): return v
		}
	}
	
	// get the 'source', regardless of the specific type
	func getSource() -> Int {
		switch self {
		case let .NoAction(s, _): return s
		case let .Move(s, _): return s
		case let .SingleCombine(s, _): return s
		case let .DoubleCombine(s, _, _): return s
		}
	}
}

/// A struct representing a square gameboard, because this struct uses generics, it could conceivably be used to
/// represent state for many other games without modification.
struct SquareGameboard<T> {
	let dimension: Int
	var boardArray: [T]
	
	init(dimension: Int, initialValue: T) {
		self.dimension = dimension
		boardArray = [T](count: dimension * dimension, repeatedValue: initialValue)
	}
	subscript(row: Int, col: Int) -> T {
		get {
			assert(row >= 0 && row < dimension)
			assert(col >= 0 && col < dimension)
			return boardArray[row*dimension + col]
		}
		set {
			assert(row >= 0 && row < dimension, "gameboard row out of index")
			assert(col >= 0 && col < dimension, "gameboard col out of index")
			boardArray[row*dimension + col] = newValue
		}
		
	}
	mutating func setAll(item: T) {
		for i in 0..<dimension {
			for j in 0..<dimension {
				self[i, j] = item
			}
		}
	}
}