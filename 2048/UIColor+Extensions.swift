//
//  UIColor+Extensions.swift
//  BlinkingScreen
//
//  Created by lunner on 6/4/15.
//  Copyright (c) 2015 lunner. All rights reserved.
//
import UIKit

public extension UIColor {
	public convenience init(redInt red: Int, greenInt green: Int, blueInt blue: Int, alpha: CGFloat) {
		let r: CGFloat, g: CGFloat, b: CGFloat
		let a: CGFloat
		r = clampColorFactor(red)
		g = clampColorFactor(green)
		b = clampColorFactor(blue)
		if alpha < 0 {
			a = fabs(alpha)
		}
		else if alpha > 1.0 {
			a = 1.0
		} else {
			a = alpha
		}
		
		
		self.init(red: r, green: g, blue: b, alpha: a)
				
	}
	
}
public func clampColorFactor(factor: Int) -> CGFloat {
	let out: CGFloat
	if factor >= 255 {
		out = 1.0
	} else if factor <= 0 {
		out = 0.0
	} else {
		out = CGFloat(factor) / 255.0
	}
	return out
}


public func + (left: UIColor, right: UIColor) -> UIColor {
	var leftR: CGFloat = 0.0 , leftG: CGFloat = 0.0, leftB: CGFloat = 0.0, leftA: CGFloat = 0.0
	var rightR: CGFloat = 0.0 , rightG: CGFloat = 0.0 , rightB: CGFloat = 0.0 , rightA: CGFloat = 0.0
	left.getRed(&leftR, green: &leftG, blue: &leftB, alpha: &leftA)
	right.getRed(&rightR, green: &rightG, blue: &rightB, alpha: &rightA)
	leftR = (leftR + rightR) % 1.0
	leftG = (leftG + rightG) % 1.0
	leftB = (leftB + rightB) % 1.0
	leftA = (leftA + rightA) % 1.0
	
	return UIColor(red: leftR, green: leftG, blue: leftB, alpha: leftA)
	
}

public func == (left: UIColor, right: UIColor) -> Bool {
	var leftR: CGFloat = 0.0, leftG: CGFloat = 0.0 , leftB: CGFloat = 0.0 , leftA: CGFloat = 0.0
	var rightR: CGFloat = 0.0, rightG: CGFloat = 0.0, rightB: CGFloat = 0.0, rightA: CGFloat = 0.0
	left.getRed(&leftR, green: &leftG, blue: &leftB, alpha: &leftA)
	right.getRed(&rightR, green: &rightG, blue: &rightB, alpha: &rightA)
	return (leftR == rightR) && (leftG == rightG) && (leftB == rightB) && (leftA == rightA)
}


