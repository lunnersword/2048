//
//  Tile.swift
//  2048
//
//  Created by lunner on 3/23/15.
//  Copyright (c) 2015 lunner. All rights reserved.
//

import UIKit

class TileView: UIView {
	unowned var delegate: AppearanceProviderProtocol
	var value: Int = 0 {
		didSet {
			backgroundColor = delegate.tileColor(value)
			numberLabel.textColor = delegate.numberColor(value)
			numberLabel.text = "\(value)"
		}
	}
	var numberLabel: UILabel
	
	init(base: UIView, value: Int, radius: CGFloat, delegate d: AppearanceProviderProtocol) {
		delegate = d
		let position = base.frame.origin
		let width =	base.bounds.size.width
		numberLabel = UILabel(frame: CGRectMake(0, 0, width, width))
		numberLabel.textAlignment = NSTextAlignment.Center
		numberLabel.minimumScaleFactor = 0.5
		numberLabel.font = delegate.fontForNumbers()
		//numberLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
				
		let frame = base.frame
		
		super.init(frame: CGRectMake(position.x, position.y, base.bounds.width, base.bounds.height))
		addSubview(numberLabel)
		layer.cornerRadius = radius
		
		self.value = value
		backgroundColor = delegate.tileColor(value)
		numberLabel.textColor = delegate.numberColor(value)
		numberLabel.text = "\(value)"
		
		//parent.addSubview(self)
	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	
}
