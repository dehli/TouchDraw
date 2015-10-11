//
//  TouchDrawView.swift
//  TouchDraw
//
//  Created by Christian Paul Dehli on 10/4/15.
//

import UIKit

public class TouchDrawView: UIView {

    private var lastPoint = CGPoint.zero
    
    private var brushColor = CIColor(color: UIColor.blackColor())
    private var brushWidth = CGFloat(10.0)
    
    private var touchesMoved = false
    
    private var mainImageView = UIImageView()
    private var tempImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initImageView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initImageView()
    }

    private func initImageView() {
        addSubview(mainImageView)
        addSubview(tempImageView)
    }
    
    override public func drawRect(rect: CGRect) {
        mainImageView.frame = self.frame
        tempImageView.frame = self.frame
    }
    
    // MARK: - Actions
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchesMoved = false
        if let touch = touches.first {
            lastPoint = touch.locationInView(self)
        }
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchesMoved = true
        if let touch = touches.first {
            let currentPoint = touch.locationInView(self)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            
            lastPoint = currentPoint
        }
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !touchesMoved {
            // draw a single point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.drawInRect(self.frame, blendMode: CGBlendMode.Normal, alpha: 1.0)
        tempImageView.image?.drawInRect(self.frame, blendMode: CGBlendMode.Normal, alpha: brushColor.alpha)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
    }
    
    private func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext(self.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.drawInRect(self.frame)
        
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, brushWidth)
        CGContextSetRGBStrokeColor(context, brushColor.red, brushColor.green, brushColor.blue, 1.0)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        
        CGContextStrokePath(context)
        
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = brushColor.alpha
        UIGraphicsEndImageContext()
    }
    
    public func exportDrawing() -> UIImage {
        UIGraphicsBeginImageContext(mainImageView.bounds.size)
        mainImageView.image?.drawInRect(mainImageView.frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    public func clearDrawing() {
        mainImageView.image = nil
    }
    
    public func setColor(color: UIColor) {
        brushColor = CIColor(color: color)
    }
    
    public func setWidth(width: CGFloat) {
        brushWidth = width
    }
    
    // Implement redo and undo
    
    
}
