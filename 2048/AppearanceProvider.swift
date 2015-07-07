//
//  AppearanceProvider.swift
//  2048
//
//  Created by lunner on 5/5/15.
//  Copyright (c) 2015 lunner. All rights reserved.
//

import UIKit

protocol AppearanceProviderProtocol: class {
	func tileColor(value: Int) -> UIColor
	func numberColor(value: Int) ->UIColor
	func fontForNumbers() ->UIFont
}


class AppearanceProvider: AppearanceProviderProtocol {
	
	let colors: [String: UIColor] = ["2": UIColor(redInt: 233, greenInt: 222, blueInt: 210, alpha: 1.0),
		"4": UIColor(redInt: 231, greenInt: 217, blueInt: 188, alpha: 1.0),
		"8": UIColor(redInt: 237, greenInt: 162, blueInt: 102, alpha: 1.0),
		"16": UIColor(redInt: 229, greenInt: 122, blueInt: 66, alpha: 1.0),
		"32": UIColor(redInt: 243, greenInt: 114, blueInt: 87, alpha: 1.0),
		"64": UIColor(redInt: 241, greenInt: 82, blueInt: 52, alpha: 1.0),
		"128": UIColor(redInt: 235, greenInt: 205, blueInt: 106, alpha: 1.0),
		"256": UIColor(redInt: 235, greenInt: 202, blueInt: 89, alpha: 1.0),
		"512": UIColor(redInt: 235, greenInt: 189, blueInt: 73, alpha: 1.0),
		"1024": UIColor(redInt: 234, greenInt: 195, blueInt: 56, alpha: 1.0),
		"2048": UIColor(redInt: 238, greenInt: 184, blueInt: 32, alpha: 1.0),
		"base": UIColor(redInt: 192, greenInt: 179, blueInt: 164, alpha: 1.0)]
	
	func tileColor(value: Int) -> UIColor {
		switch value {
		case 2:
			return colors["2"]!
		case 4:
			return colors["4"]!
		case 8:
			return colors["8"]!
		case 16:
			return colors["16"]!
		case 32:
			return colors["32"]!
		case 64:
			return colors["64"]!
		case 128:
			return colors["128"]!
		case 256:
			return colors["256"]!
		case 512:
			return colors["512"]!
		case 1024:
			return colors["1024"]!
		case 2048:
			return colors["2048"]!
		default:
			return UIColor.whiteColor()
		}
	}
	
	func numberColor(value: Int) -> UIColor {
		switch value {
		case 2, 4:
			return UIColor(red: 119.0/255.0, green: 110.0/255.0, blue: 101.0/255.0, alpha: 1.0)
		default:
			return UIColor.whiteColor()
		}
	}
	
	// this size should be returned according to the Screen
	func fontForNumbers() -> UIFont {
		let fontSize: CGFloat = 70.0
		if let font = UIFont(name: "HelveticalNeue", size: fontSize) {
			return font
		}
		return UIFont.systemFontOfSize(fontSize)
	}
}
