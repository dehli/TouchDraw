//
//  TouchDrawView.swift
//  TouchDraw
//
//  Created by Christian Paul Dehli
//

public protocol TouchDrawViewDelegate {
    /// undoEnabled: triggered when undo is enabled (only if it was previously disabled)
    /// - Returns: Void
    func undoEnabled() -> Void
    
    /// undoDisabled: triggered when undo is disabled (only if it previously enabled)
    /// - Returns: Void
    func undoDisabled() -> Void
    
    /// redoEnabled: triggered when redo is enabled (only if it was previously disabled)
    /// - Returns: Void
    func redoEnabled() -> Void
    
    /// redoDisabled: triggered when redo is disabled (only if it previously enabled)
    /// - Returns: Void
    func redoDisabled() -> Void
    
    /// clearEnabled: triggered when clear is enabled (only if it was previously disabled)
    /// - Returns: Void
    func clearEnabled() -> Void
    
    /// clearDisabled: triggered when clear is disabled (only if it previously enabled)
    /// - Returns: Void
    func clearDisabled() -> Void
}

private class BrushProperties {
    private var color: CIColor!
    private var width: CGFloat!
    
    init() {
        color = CIColor(color: UIColor.blackColor())
        width = CGFloat(10.0)
    }
    init(properties: BrushProperties) {
        color = properties.color
        width = properties.width
    }
}

private class Stroke {
    private var points: NSMutableArray!
    private var properties: BrushProperties!
    
    init() {
        points = []
        properties = BrushProperties()
    }
}

public class TouchDrawView: UIView {

    /// delegate: must be set in whichever class is using the TouchDrawView
    public var delegate: TouchDrawViewDelegate!
    
    /// stack: used to keep track of all the strokes
    private var stack: [Stroke]!
    private var pointsArray: NSMutableArray!
    
    private var lastPoint = CGPoint.zero
    
    /// brushProperties: current brush properties
    private var brushProperties = BrushProperties()
    
    private var touchesMoved = false
    
    private var mainImageView = UIImageView()
    private var tempImageView = UIImageView()
    
    private var undoEnabled = false
    private var redoEnabled = false
    private var clearEnabled = false
    
    /// init: initializes a TouchDrawView instance
    /// - Parameter: frame: frame for the view to be initialized in
    override init(frame: CGRect) {
        super.init(frame: frame)
        initTouchDrawView()
    }
    
    /// init: initializes a TouchDrawView instance
    /// - Parameter: coder aDecoder: NSCoder to initialize the view
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
    
    private func mergeViews() {
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.drawInRect(mainImageView.frame, blendMode: CGBlendMode.Normal, alpha: 1.0)
        tempImageView.image?.drawInRect(tempImageView.frame, blendMode: CGBlendMode.Normal, alpha: brushProperties.color.alpha)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
    }
    
    internal func popDrawing() {
        let stroke = stack.last
        stack.popLast()
        redrawLinePathsInStack()
        undoManager?.registerUndoWithTarget(self, selector: "pushDrawing:", object: stroke)
    }
    
    internal func pushDrawing(object: AnyObject) {
        let stroke = object as? Stroke
        stack.append(stroke!)
        drawLine(stroke!)
        undoManager?.registerUndoWithTarget(self, selector: "popDrawing", object: nil)
    }
    
    private func redrawLinePathsInStack() {
        internalClear()
        
        for stroke in stack {
            drawLine(stroke)
        }
    }
    
    /// drawLine: draws a stroke
    /// - Parameter: stroke: the stroke to be drawn
    /// - Returns: Void
    private func drawLine(stroke: Stroke) -> Void {
        let properties = stroke.properties
        let array = stroke.points
        
        if array.count == 1 {
            // Draw the one point
            let pointStr = array[0] as! String
            let point = CGPointFromString(pointStr)
            drawLineFrom(point, toPoint: point, properties: properties)
        }
        
        for i in 0 ..< array.count - 1 {
            let pointStr0 = array[i] as! String
            let pointStr1 = array[i+1] as! String
            
            let point0 = CGPointFromString(pointStr0)
            let point1 = CGPointFromString(pointStr1)
            drawLineFrom(point0, toPoint: point1, properties: properties)
        }
        mergeViews()
    }
    
    /// drawLineFrom: draws a line from one point to another with certain properties
    /// - Parameter: fromPoint: the location the line will start
    /// - Parameter: toPoint: the location the line will end
    /// - Parameter: properties: the brush's properties for the line
    /// - Returns: Void
    private func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint, properties: BrushProperties) -> Void {
        
        UIGraphicsBeginImageContext(self.frame.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, properties.width)
        CGContextSetRGBStrokeColor(context, properties.color.red, properties.color.green, properties.color.blue, 1.0)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        
        CGContextStrokePath(context)
        
        tempImageView.image?.drawInRect(tempImageView.frame)
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = properties.color.alpha
        UIGraphicsEndImageContext()
    }
    
    /// exportDrawing: exports the current drawing
    /// - Returns: UIImage
    public func exportDrawing() -> UIImage {
        UIGraphicsBeginImageContext(mainImageView.bounds.size)
        mainImageView.image?.drawInRect(mainImageView.frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// internalClear: clears the UIImageViews
    /// - Returns: Void
    private func internalClear() -> Void {
        mainImageView.image = nil
        tempImageView.image = nil
    }
    
    /// clearDrawing: clears the drawing
    /// - Returns: Void
    public func clearDrawing() -> Void {
        internalClear()
        undoManager?.registerUndoWithTarget(self, selector: "pushAll:", object: stack)
        stack = []
        
        checkClearState()
        
        if !undoManager!.canRedo {
            if redoEnabled {
                delegate.redoDisabled()
                redoEnabled = false
            }
        }
    }
    
    internal func pushAll(object: AnyObject) {
        let array = object as? [Stroke]
        
        for stroke in array! {
            drawLine(stroke)
            stack.append(stroke)
        }
        undoManager?.registerUndoWithTarget(self, selector: "clearDrawing", object: nil)
    }
    
    /// setColor: Sets the brush's color
    /// - Parameter: color: color of brush
    /// - Returns: Void
    public func setColor(color: UIColor) -> Void {
        brushProperties.color = CIColor(color: color)
    }
    
    /// setWidth: Sets the brush's width
    /// - Parameter: width: width of brush
    /// - Returns: Void
    public func setWidth(width: CGFloat) -> Void {
        brushProperties.width = width
    }
    
    private func checkClearState() {
        if stack.count == 0 && clearEnabled {
            self.delegate.clearDisabled()
            clearEnabled = false
        }
        else if stack.count > 0 && !clearEnabled {
            self.delegate.clearEnabled()
            clearEnabled = true
        }
    }
    
    /// undo: If possible, it will undo the last stroke
    /// - Returns: Void
    public func undo() -> Void {
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
            
            checkClearState()
        }
    }
    
    /// redo: If possible, it will redo the last undone stroke
    /// - Returns: Void
    public func redo() -> Void {
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
            
            checkClearState()
        }
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
            drawLineFrom(lastPoint, toPoint: currentPoint, properties: brushProperties)
            
            lastPoint = currentPoint
            pointsArray.addObject(NSStringFromCGPoint(lastPoint))
        }
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !touchesMoved {
            // draw a single point
            drawLineFrom(lastPoint, toPoint: lastPoint, properties: brushProperties)
        }
        
        mergeViews()
        
        let stroke = Stroke()
        stroke.properties = BrushProperties(properties: brushProperties)
        stroke.points = pointsArray
        
        stack.append(stroke)
        
        undoManager?.registerUndoWithTarget(self, selector: "popDrawing", object: nil)
        
        if !undoEnabled {
            delegate.undoEnabled()
            undoEnabled = true
        }
        if redoEnabled {
            delegate.redoDisabled()
            redoEnabled = false
        }
        if !clearEnabled {
            self.delegate.clearEnabled()
            clearEnabled = true
        }
    }
}
