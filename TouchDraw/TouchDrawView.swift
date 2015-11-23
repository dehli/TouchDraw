//
//  TouchDrawView.swift
//  TouchDraw
//
//  Created by Christian Paul Dehli on 10/4/15.
//

public protocol TouchDrawViewDelegate {
    func undoEnabled()
    func undoDisabled()
    func redoEnabled()
    func redoDisabled()
}

public class TouchDrawView: UIView {

    public var delegate: TouchDrawViewDelegate!
    
    // Used for undo/redo
    private var stack: NSMutableArray!
    private var pointsArray: NSMutableArray!
    
    private var lastPoint = CGPoint.zero
    
    private var brushColor = CIColor(color: UIColor.blackColor())
    private var brushWidth = CGFloat(10.0)
    
    private var touchesMoved = false
    
    private var mainImageView = UIImageView()
    private var tempImageView = UIImageView()
    
    private var undoEnabled = false
    private var redoEnabled = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initTouchDrawView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initTouchDrawView()
    }

    private func initTouchDrawView() {
        addSubview(mainImageView)
        addSubview(tempImageView)
        stack = []
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
            pointsArray = []
            pointsArray.addObject(NSStringFromCGPoint(lastPoint))
        }
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchesMoved = true
        if let touch = touches.first {
            let currentPoint = touch.locationInView(self)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            
            lastPoint = currentPoint
            pointsArray.addObject(NSStringFromCGPoint(lastPoint))
        }
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !touchesMoved {
            // draw a single point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        
        mergeViews()
        
        stack.addObject(pointsArray)
        undoManager?.registerUndoWithTarget(self, selector: "popDrawing", object: nil)
        
        if !undoEnabled {
            delegate.undoEnabled()
            undoEnabled = true
        }
        if redoEnabled {
            delegate.redoDisabled()
            redoEnabled = false
        }
        
    }
    
    func mergeViews() {
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.drawInRect(self.frame, blendMode: CGBlendMode.Normal, alpha: 1.0)
        tempImageView.image?.drawInRect(self.frame, blendMode: CGBlendMode.Normal, alpha: brushColor.alpha)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
    }
    
    func popDrawing() {
        let array = stack.lastObject as! NSArray
        stack.removeLastObject()
        redrawLinePathsInStack()
        undoManager?.registerUndoWithTarget(self, selector: "pushDrawing:", object: array)
    }
    
    func pushDrawing(array: NSArray) {
        stack.addObject(array)
        drawLine(array)
        undoManager?.registerUndoWithTarget(self, selector: "popDrawing", object: nil)
    }
    
    func redrawLinePathsInStack() {
        clearDrawing()
        for object in stack {
            let array = object as! NSArray
            drawLine(array)
        }
    }
    
    func drawLine(array: NSArray) {
        if array.count == 1 {
            // Draw the one point
            let pointStr = array[0] as! String
            let point = CGPointFromString(pointStr)
            drawLineFrom(point, toPoint: point)
        }
        
        for i in 0 ..< array.count-1 {
            let pointStr0 = array[i] as! String
            let pointStr1 = array[i+1] as! String
            
            let point0 = CGPointFromString(pointStr0)
            let point1 = CGPointFromString(pointStr1)
            drawLineFrom(point0, toPoint: point1)
        }
        mergeViews()
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
    
    public func undo() {
        if undoManager!.canUndo {
            undoManager?.undo()
            
            if !redoEnabled {
                delegate.redoEnabled()
                redoEnabled = true
            }
            
            if !undoManager!.canUndo {
                if undoEnabled {
                    delegate.undoDisabled()
                    undoEnabled = false
                }
            }
        }
    }
    
    public func redo() {
        if undoManager!.canRedo {
            undoManager?.redo()
            
            if !undoEnabled {
                delegate.undoEnabled()
                undoEnabled = true
            }
            
            if !undoManager!.canRedo {
                if redoEnabled {
                    delegate.redoDisabled()
                    redoEnabled = false
                }
            }
        }
    }
    
}
