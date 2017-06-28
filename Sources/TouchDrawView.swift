//
//  TouchDrawView.swift
//  TouchDraw
//
//  Created by Christian Paul Dehli
//

/// The protocol which the container of TouchDrawView can conform to
@objc public protocol TouchDrawViewDelegate {
    /// triggered when undo is enabled (only if it was previously disabled)
    @objc optional func undoEnabled() -> Void

    /// triggered when undo is disabled (only if it previously enabled)
    @objc optional func undoDisabled() -> Void

    /// triggered when redo is enabled (only if it was previously disabled)
    @objc optional func redoEnabled() -> Void

    /// triggered when redo is disabled (only if it previously enabled)
    @objc optional func redoDisabled() -> Void

    /// triggered when clear is enabled (only if it was previously disabled)
    @objc optional func clearEnabled() -> Void

    /// triggered when clear is disabled (only if it previously enabled)
    @objc optional func clearDisabled() -> Void
}

/// A subclass of UIView which allows you to draw on the view using your fingers
open class TouchDrawView: UIView {

    /// Must be set in whichever class is using the TouchDrawView
    open var delegate: TouchDrawViewDelegate?
    
    /// Used to register undo and redo actions
    internal var touchDrawUndoManager: UndoManager!

    /// Used to keep track of all the strokes
    internal var stack: [Stroke]!
    internal var pointsArray: [CGPoint]!

    /// brushProperties: current brush settings
    internal var brushProperties = StrokeSettings()

    private let imageView = UIImageView()

    /// Initializes a TouchDrawView instance
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initTouchDrawView(frame)
    }

    /// Initializes a TouchDrawView instance
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initTouchDrawView(CGRect.zero)
    }

    /// Sets the frames of the subviews
    override open func draw(_ rect: CGRect) {
        imageView.frame = rect
    }
    
    /// Imports the stack so that previously exported stack can be used
    open func importStack(_ stack: [Stroke]) {
        // Make sure undo is disabled
        if touchDrawUndoManager.canUndo {
            delegate?.undoDisabled?()
        }

        // Make sure that redo is disabled
        if touchDrawUndoManager.canRedo {
            delegate?.redoDisabled?()
        }

        // Make sure that clear is enabled
        if stack.count == 0 && stack.count > 0 {
            delegate?.clearEnabled?()
        }
        
        self.stack = stack
        redrawStack()
        touchDrawUndoManager.removeAllActions()
    }

    /// Used to export the current stack (each individual stroke)
    open func exportStack() -> [Stroke] {
        return stack
    }

    /// adds the subviews and initializes stack
    private func initTouchDrawView(_ frame: CGRect) {
        addSubview(imageView)
        stack = []

        touchDrawUndoManager = undoManager
        if touchDrawUndoManager == nil {
            touchDrawUndoManager = UndoManager()
        }

        // Initially sets the frames of the UIImageView
        draw(frame)
    }

    /// Removes the last Stroke from stack
    internal func popDrawing() {
        touchDrawUndoManager.registerUndo(withTarget: self, selector: #selector(pushDrawing(_:)), object: stack.popLast())
        redrawStack()
    }

    /// Adds a new stroke to the stack
    internal func pushDrawing(_ stroke: Stroke) {
        stack.append(stroke)
        drawLine(stroke)
        touchDrawUndoManager.registerUndo(withTarget: self, selector: #selector(popDrawing), object: nil)
    }

    /// Clears view, then draws stack
    private func redrawStack() -> Void {
        internalClear()
        for stroke in stack {
            drawLine(stroke)
        }
    }

    /// Draws a single Stroke
    private func drawLine(_ stroke: Stroke) -> Void {
        let properties = stroke.settings
        let points = stroke.points

        if points.count == 1 {
            let point = points[0]
            drawLineFrom(point, toPoint: point, properties: properties)
        }

        for i in 1 ..< points.count {
            let point0 = points[i - 1]
            let point1 = points[i]
            drawLineFrom(point0, toPoint: point1, properties: properties)
        }
    }

    /// Draws a line from one point to another with certain properties
    fileprivate func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint, properties: StrokeSettings) -> Void {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        imageView.image?.draw(in: imageView.frame)
        
        let context = UIGraphicsGetCurrentContext()
        context!.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context!.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))

        context!.setLineCap(CGLineCap.round)
        context!.setLineWidth(properties.width)
        context!.setStrokeColor(red: properties.color.red,
                                green: properties.color.green,
                                blue: properties.color.blue,
                                alpha: properties.color.alpha)
        context!.setBlendMode(CGBlendMode.normal)
        context!.strokePath()

        let image = UIGraphicsGetImageFromCurrentImageContext()
        imageView.image = image
        UIGraphicsEndImageContext()
    }

    /// Exports the current drawing
    open func exportDrawing() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, UIScreen.main.scale)
        imageView.image?.draw(in: imageView.frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    /// Clears the UIImageViews
    private func internalClear() -> Void {
        imageView.image = nil
    }

    /// Clears the drawing
    open func clearDrawing() -> Void {
        internalClear()

        if !touchDrawUndoManager.canUndo {
            delegate?.undoEnabled?()
        }
        
        if touchDrawUndoManager.canRedo {
            delegate?.redoDisabled?()
        }
        
        if stack.count > 0 {
            delegate?.clearDisabled?()
        }
        
        touchDrawUndoManager.registerUndo(withTarget: self, selector: #selector(pushAll(_:)), object: stack)
        stack = []
    }
    
    internal func pushAll(_ strokes: [Stroke]) {
        for stroke in strokes {
            drawLine(stroke)
            stack.append(stroke)
        }
        touchDrawUndoManager.registerUndo(withTarget: self, selector: #selector(clearDrawing), object: nil)
    }

    /// Sets the brush's color
    open func setColor(_ color: UIColor) -> Void {
        brushProperties.color = CIColor(color: color)
    }

    /// Sets the brush's width
    open func setWidth(_ width: CGFloat) -> Void {
        brushProperties.width = width
    }

    /// if possible, it will undo the last stroke
    open func undo() -> Void {
        if touchDrawUndoManager.canUndo {
            let stackCount = stack.count
            
            if !touchDrawUndoManager.canRedo {
                delegate?.redoEnabled?()
            }

            touchDrawUndoManager.undo()
            
            if !touchDrawUndoManager.canUndo {
                delegate?.undoDisabled?()
            }
            
            if stackCount > 0 && stack.count == 0 {
                delegate?.clearDisabled?()
            } else if stackCount == 0 && stack.count > 0 {
                delegate?.clearEnabled?()
            }
        }
    }

    /// if possible, it will redo the last undone stroke
    open func redo() -> Void {
        if touchDrawUndoManager.canRedo {
            let stackCount = stack.count
            
            if !touchDrawUndoManager.canUndo {
                delegate?.undoEnabled?()
            }
            
            touchDrawUndoManager.redo()
            
            if !touchDrawUndoManager.canRedo {
                self.delegate?.redoDisabled?()
            }

            if stackCount > 0 && stack.count == 0 {
                delegate?.clearDisabled?()
            } else if stackCount == 0 && stack.count > 0 {
                delegate?.clearEnabled?()
            }
        }
    }
}

// MARK: - Actions

extension TouchDrawView {
    
    /// Triggered when touches begin
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            pointsArray = [point]
        }
    }
    
    /// Triggered when touches move
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {        
        if let touch = touches.first {
            let lastPoint = pointsArray.last
            let currentPoint = touch.location(in: self)
            drawLineFrom(lastPoint!, toPoint: currentPoint, properties: brushProperties)
            pointsArray.append(currentPoint)
        }
    }
    
    /// Triggered whenever touches end, resulting in a newly created Stroke
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if pointsArray.count == 1 {
            let lastPoint = pointsArray.last!
            drawLineFrom(lastPoint, toPoint: lastPoint, properties: brushProperties)
        }
        
        let stroke = Stroke()
        stroke.settings = StrokeSettings(settings: brushProperties)
        stroke.points = pointsArray
        
        if !touchDrawUndoManager.canUndo {
            delegate?.undoEnabled?()
        }
        
        if touchDrawUndoManager.canRedo {
            delegate?.redoDisabled?()
        }
        
        if stack.count == 0 {
            delegate?.clearEnabled?()
        }
        
        stack.append(stroke)
        touchDrawUndoManager.registerUndo(withTarget: self, selector: #selector(popDrawing), object: nil)
    }
}
