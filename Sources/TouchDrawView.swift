//
//  TouchDrawView.swift
//  TouchDraw
//
//  Created by Christian Paul Dehli
//

/// The protocol which the container of TouchDrawView must conform to
public protocol TouchDrawViewDelegate {
    /// triggered when undo is enabled (only if it was previously disabled)
    func undoEnabled() -> Void
    
    /// triggered when undo is disabled (only if it previously enabled)
    func undoDisabled() -> Void
    
    /// triggered when redo is enabled (only if it was previously disabled)
    func redoEnabled() -> Void
    
    /// triggered when redo is disabled (only if it previously enabled)
    func redoDisabled() -> Void
    
    /// triggered when clear is enabled (only if it was previously disabled)
    func clearEnabled() -> Void
    
    /// triggered when clear is disabled (only if it previously enabled)
    func clearDisabled() -> Void
}

/// properties to describe the brush
internal class BrushProperties {
    /// color of the brush
    internal var color: CIColor!
    /// width of the brush
    internal var width: CGFloat!
    
    init() {
        color = CIColor(color: UIColor.blackColor())
        width = CGFloat(10.0)
    }
    init(properties: BrushProperties) {
        color = properties.color
        width = properties.width
    }
}

/// a drawing stroke
internal class Stroke {
    /// the points that make up the stroke
    internal var points: NSMutableArray!
    /// the properties of the stroke
    internal var properties: BrushProperties!
    
    init() {
        points = []
        properties = BrushProperties()
    }
}

/// A subclass of UIView which allows you to draw on the view using your fingers
public class TouchDrawView: UIView {
    
    private var touchDrawUndoManager: NSUndoManager!

    /// must be set in whichever class is using the TouchDrawView
    public var delegate: TouchDrawViewDelegate!
    
    /// used to keep track of all the strokes
    internal var stack: [Stroke]!
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
    
    /// initializes a TouchDrawView instance
    override init(frame: CGRect) {
        super.init(frame: frame)
        initTouchDrawView(frame)
    }
    
    /// initializes a TouchDrawView instance
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initTouchDrawView(CGRect.zero)
    }

    /// adds the subviews and initializes stack
    private func initTouchDrawView(frame: CGRect) {
        addSubview(mainImageView)
        addSubview(tempImageView)
        stack = []
        
        touchDrawUndoManager = undoManager
        if touchDrawUndoManager == nil {
            touchDrawUndoManager = NSUndoManager()
        }
        
        // Initially sets the frames of the UIImageViews
        drawRect(frame)
    }
    
    /// sets the frames of the subviews
    override public func drawRect(rect: CGRect) {
        mainImageView.frame = rect
        tempImageView.frame = rect
    }
    
    /// merges tempImageView into mainImageView
    private func mergeViews() {
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.drawInRect(mainImageView.frame, blendMode: CGBlendMode.Normal, alpha: 1.0)
        tempImageView.image?.drawInRect(tempImageView.frame, blendMode: CGBlendMode.Normal, alpha: brushProperties.color.alpha)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        mainImageView.image = image
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
    }
    
    /// removes the last stroke from stack
    internal func popDrawing() {
        let stroke = stack.last
        stack.popLast()
        redrawLinePathsInStack()
        touchDrawUndoManager!.registerUndoWithTarget(self, selector: #selector(TouchDrawView.pushDrawing(_:)), object: stroke)
    }
    
    /// adds a new stroke to the stack
    internal func pushDrawing(object: AnyObject) {
        let stroke = object as? Stroke
        stack.append(stroke!)
        drawLine(stroke!)
        touchDrawUndoManager!.registerUndoWithTarget(self, selector: #selector(TouchDrawView.popDrawing), object: nil)
    }
    
    /// draws all the lines in the stack
    private func redrawLinePathsInStack() {
        internalClear()
        
        for stroke in stack {
            drawLine(stroke)
        }
    }
    
    /// draws a stroke
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
    
    /// draws a line from one point to another with certain properties
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
        let image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.image = image
        tempImageView.alpha = properties.color.alpha
        UIGraphicsEndImageContext()
    }
    
    /// exports the current drawing
    public func exportDrawing() -> UIImage {
        UIGraphicsBeginImageContext(mainImageView.bounds.size)
        mainImageView.image?.drawInRect(mainImageView.frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// clears the UIImageViews
    private func internalClear() -> Void {
        mainImageView.image = nil
        tempImageView.image = nil
    }
    
    /// clears the drawing
    public func clearDrawing() -> Void {
        internalClear()
        touchDrawUndoManager!.registerUndoWithTarget(self, selector: #selector(TouchDrawView.pushAll(_:)), object: stack)
        stack = []
        
        checkClearState()
        
        if !touchDrawUndoManager!.canRedo {
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
        touchDrawUndoManager!.registerUndoWithTarget(self, selector: #selector(TouchDrawView.clearDrawing), object: nil)
    }
    
    /// sets the brush's color
    public func setColor(color: UIColor) -> Void {
        brushProperties.color = CIColor(color: color)
    }
    
    /// sets the brush's width
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
    
    /// if possible, it will undo the last stroke
    public func undo() -> Void {
        if touchDrawUndoManager!.canUndo {
            touchDrawUndoManager!.undo()
            
            if !redoEnabled {
                delegate.redoEnabled()
                redoEnabled = true
            }
            
            if !touchDrawUndoManager!.canUndo {
                if undoEnabled {
                    delegate.undoDisabled()
                    undoEnabled = false
                }
            }
            
            checkClearState()
        }
    }
    
    /// if possible, it will redo the last undone stroke
    public func redo() -> Void {
        if touchDrawUndoManager!.canRedo {
            touchDrawUndoManager!.redo()
            
            if !undoEnabled {
                delegate.undoEnabled()
                undoEnabled = true
            }
            
            if !touchDrawUndoManager!.canRedo {
                if redoEnabled {
                    delegate.redoDisabled()
                    redoEnabled = false
                }
            }
            
            checkClearState()
        }
    }
    
    // MARK: - Actions
    
    /// triggered when touches begin
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchesMoved = false
        if let touch = touches.first {
            lastPoint = touch.locationInView(self)
            pointsArray = []
            pointsArray.addObject(NSStringFromCGPoint(lastPoint))
        }
    }
    
    /// triggered when touches move
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchesMoved = true
        if let touch = touches.first {
            let currentPoint = touch.locationInView(self)
            drawLineFrom(lastPoint, toPoint: currentPoint, properties: brushProperties)
            
            lastPoint = currentPoint
            pointsArray.addObject(NSStringFromCGPoint(lastPoint))
        }
    }
    
    /// triggered whenever touches end, resulting in a newly created Stroke
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
        
        touchDrawUndoManager!.registerUndoWithTarget(self, selector: #selector(TouchDrawView.popDrawing), object: nil)
        
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
