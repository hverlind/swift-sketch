//
//  View.swift
//  Sketch
//
//  Created by Hannes Verlinde on 04/10/14.
//  Copyright (c) 2014 Hannes Verlinde. All rights reserved.
//

import UIKit

class View: UIView {

    private let path = UIBezierPath()
    
    func addPoint(point: CGPoint) {
        if path.empty {
            path.moveToPoint(point)
        } else {
            path.addLineToPoint(point)
        }
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetLineWidth(context, 8.0)
        CGContextAddPath(context, path.CGPath)
        CGContextStrokePath(context)
    }

}
