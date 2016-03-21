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

public class BrushProperties {
    public var color: CIColor!
    public var width: CGFloat!
    
    init() {
        color = CIColor(color: UIColor.blackColor())
        width = CGFloat(10.0)
    }
}

public class TouchDrawView: UIView {

    public var delegate: TouchDrawViewDelegate!
    
    // Used for undo/redo
    private var stack: NSMutableArray!
    private var pointsArray: NSMutableArray!
    
    private var lastPoint = CGPoint.zero
    
    private var brushProperties = BrushProperties()
    
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
        mainImageView.frame = rect
        tempImageView.frame = rect
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
    
    private func mergeViews() {
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.drawInRect(mainImageView.frame, blendMode: CGBlendMode.Normal, alpha: 1.0)
        tempImageView.image?.drawInRect(tempImageView.frame, blendMode: CGBlendMode.Normal, alpha: brushProperties.color.alpha)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
    }
    
    // Needs to be public for undoManager
    public func popDrawing() {
        let array = stack.lastObject as! NSArray
        stack.removeLastObject()
        redrawLinePathsInStack()
        undoManager?.registerUndoWithTarget(self, selector: "pushDrawing:", object: array)
    }
    
    // Needs to be public for undoManager
    public func pushDrawing(array: NSArray) {
        stack.addObject(array)
        drawLine(array)
        undoManager?.registerUndoWithTarget(self, selector: "popDrawing", object: nil)
    }
    
    private func redrawLinePathsInStack() {
        internalClear()
        for object in stack {
            let array = object as! NSArray
            drawLine(array)
        }
    }
    
    private func drawLine(array: NSArray) {
        if array.count == 1 {
            // Draw the one point
            let pointStr = array[0] as! String
            let point = CGPointFromString(pointStr)
            drawLineFrom(point, toPoint: point)
        }
        
        for i in 0 ..< array.count - 1 {
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
        
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, brushProperties.width)
        CGContextSetRGBStrokeColor(context, brushProperties.color.red, brushProperties.color.green, brushProperties.color.blue, 1.0)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        
        CGContextStrokePath(context)
        
        tempImageView.image?.drawInRect(tempImageView.frame)
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = brushProperties.color.alpha
        UIGraphicsEndImageContext()
    }
    
    public func exportDrawing() -> UIImage {
        UIGraphicsBeginImageContext(mainImageView.bounds.size)
        mainImageView.image?.drawInRect(mainImageView.frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func internalClear() {
        mainImageView.image = nil
        tempImageView.image = nil
    }
    
    public func clearDrawing() {
        internalClear()
        undoManager?.registerUndoWithTarget(self, selector: "pushAll:", object: stack)
        stack = []
    }
    
    // Needs to be public for undoManager
    public func pushAll(array: NSArray) {
        for mark in array {
            let markArray = mark as! NSArray
            drawLine(markArray)
            stack.addObject(markArray)
        }
        undoManager?.registerUndoWithTarget(self, selector: "clearDrawing", object: nil)
    }
    
    public func setColor(color: UIColor) {
        brushProperties.color = CIColor(color: color)
    }
    
    public func setWidth(width: CGFloat) {
        brushProperties.width = width
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
