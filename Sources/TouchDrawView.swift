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

    /// Used to register undo and redo actions
    fileprivate var touchDrawUndoManager: UndoManager!

    /// must be set in whichever class is using the TouchDrawView
    open var delegate: TouchDrawViewDelegate?

    /// used to keep track of all the strokes
    internal var stack: [Stroke]!
    fileprivate var pointsArray: [String]!

    fileprivate var lastPoint = CGPoint.zero

    /// brushProperties: current brush settings
    fileprivate var brushProperties = StrokeSettings()

    fileprivate var touchesMoved = false

    fileprivate var mainImageView = UIImageView()
    fileprivate var tempImageView = UIImageView()

    fileprivate var undoEnabled = false
    fileprivate var redoEnabled = false
    fileprivate var clearEnabled = false

    /// initializes a TouchDrawView instance
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initTouchDrawView(frame)
    }

    /// initializes a TouchDrawView instance
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initTouchDrawView(CGRect.zero)
    }

    /// imports the stack so that previously exported stack can be used
    open func importStack(_ stack: [Stroke]) {
        self.stack = stack
        self.redrawLinePathsInStack()

        // Make sure undo is disabled
        if self.undoEnabled {
            self.delegate?.undoDisabled?()
            self.undoEnabled = false
        }

        // Make sure that redo is disabled
        if self.redoEnabled {
            self.delegate?.redoDisabled?()
            self.redoEnabled = false
        }

        // Make sure that clear is enabled
        if !self.clearEnabled {
            self.delegate?.clearEnabled?()
            self.clearEnabled = true
        }
    }

    /// Used to export the current stack (each individual stroke)
    open func exportStack() -> [Stroke] {
        return self.stack
    }

    /// adds the subviews and initializes stack
    fileprivate func initTouchDrawView(_ frame: CGRect) {
        self.addSubview(self.mainImageView)
        self.addSubview(self.tempImageView)
        self.stack = []

        self.touchDrawUndoManager = undoManager
        if self.touchDrawUndoManager == nil {
            self.touchDrawUndoManager = UndoManager()
        }

        // Initially sets the frames of the UIImageViews
        self.draw(frame)
    }

    /// sets the frames of the subviews
    override open func draw(_ rect: CGRect) {
        self.mainImageView.frame = rect
        self.tempImageView.frame = rect
    }

    /// merges tempImageView into mainImageView
    fileprivate func mergeViews() {
        UIGraphicsBeginImageContextWithOptions(self.mainImageView.frame.size, false, UIScreen.main.scale)
        self.mainImageView.image?.draw(in: self.mainImageView.frame, blendMode: CGBlendMode.normal, alpha: 1.0)
        self.tempImageView.image?.draw(in: self.tempImageView.frame, blendMode: CGBlendMode.normal, alpha: self.brushProperties.color.alpha)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        self.mainImageView.image = image
        UIGraphicsEndImageContext()

        self.tempImageView.image = nil
    }

    /// removes the last stroke from stack
    internal func popDrawing() {
        let stroke = self.stack.popLast()
        self.redrawLinePathsInStack()
        self.touchDrawUndoManager!.registerUndo(withTarget: self, selector: #selector(TouchDrawView.pushDrawing(_:)), object: stroke)
    }

    /// adds a new stroke to the stack
    internal func pushDrawing(_ object: AnyObject) {
        let stroke = object as? Stroke
        self.stack.append(stroke!)
        self.drawLine(stroke!)
        self.touchDrawUndoManager!.registerUndo(withTarget: self, selector: #selector(TouchDrawView.popDrawing), object: nil)
    }

    /// draws all the lines in the stack
    fileprivate func redrawLinePathsInStack() {
        self.internalClear()

        for stroke in self.stack {
            self.drawLine(stroke)
        }
    }

    /// draws a stroke
    fileprivate func drawLine(_ stroke: Stroke) -> Void {
        let properties = stroke.settings
        let array = stroke.points

        if array?.count == 1 {
            // Draw the one point
            let pointStr = array?[0]
            let point = CGPointFromString(pointStr!)
            self.drawLineFrom(point, toPoint: point, properties: properties!)
        }

        for i in 0 ..< (array?.count)! - 1 {
            let pointStr0 = array?[i]
            let pointStr1 = array?[i+1]

            let point0 = CGPointFromString(pointStr0!)
            let point1 = CGPointFromString(pointStr1!)
            self.drawLineFrom(point0, toPoint: point1, properties: properties!)
        }
        self.mergeViews()
    }

    /// draws a line from one point to another with certain properties
    fileprivate func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint, properties: StrokeSettings) -> Void {

        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()

        context!.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context!.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))

        context!.setLineCap(CGLineCap.round)
        context!.setLineWidth(properties.width)
        context!.setStrokeColor(red: properties.color.red, green: properties.color.green, blue: properties.color.blue, alpha: 1.0)
        context!.setBlendMode(CGBlendMode.normal)

        context!.strokePath()

        self.tempImageView.image?.draw(in: self.tempImageView.frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        self.tempImageView.image = image
        self.tempImageView.alpha = properties.color.alpha
        UIGraphicsEndImageContext()
    }

    /// exports the current drawing
    open func exportDrawing() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.mainImageView.bounds.size, false, UIScreen.main.scale)
        self.mainImageView.image?.draw(in: self.mainImageView.frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    /// clears the UIImageViews
    fileprivate func internalClear() -> Void {
        self.mainImageView.image = nil
        self.tempImageView.image = nil
    }

    /// clears the drawing
    open func clearDrawing() -> Void {
        self.internalClear()
        self.touchDrawUndoManager!.registerUndo(withTarget: self, selector: #selector(TouchDrawView.pushAll(_:)), object: stack)
        self.stack = []

        self.checkClearState()

        if !self.touchDrawUndoManager!.canRedo {
            if self.redoEnabled {
                self.delegate?.redoDisabled?()
                self.redoEnabled = false
            }
        }
    }

    internal func pushAll(_ object: AnyObject) {
        let array = object as? [Stroke]

        for stroke in array! {
            self.drawLine(stroke)
            self.stack.append(stroke)
        }
        self.touchDrawUndoManager!.registerUndo(withTarget: self, selector: #selector(TouchDrawView.clearDrawing), object: nil)
    }

    /// sets the brush's color
    open func setColor(_ color: UIColor) -> Void {
        self.brushProperties.color = CIColor(color: color)
    }

    /// sets the brush's width
    open func setWidth(_ width: CGFloat) -> Void {
        self.brushProperties.width = width
    }

    fileprivate func checkClearState() {
        if self.stack.count == 0 && self.clearEnabled {
            self.delegate?.clearDisabled?()
            self.clearEnabled = false
        }
        else if self.stack.count > 0 && !self.clearEnabled {
            self.delegate?.clearEnabled?()
            self.clearEnabled = true
        }
    }

    /// if possible, it will undo the last stroke
    open func undo() -> Void {
        if self.touchDrawUndoManager!.canUndo {
            self.touchDrawUndoManager!.undo()

            if !self.redoEnabled {
                self.delegate?.redoEnabled?()
                self.redoEnabled = true
            }

            if !self.touchDrawUndoManager!.canUndo {
                if self.undoEnabled {
                    self.delegate?.undoDisabled?()
                    self.undoEnabled = false
                }
            }

            self.checkClearState()
        }
    }

    /// if possible, it will redo the last undone stroke
    open func redo() -> Void {
        if self.touchDrawUndoManager!.canRedo {
            self.touchDrawUndoManager!.redo()

            if !self.undoEnabled {
                self.delegate?.undoEnabled?()
                self.undoEnabled = true
            }

            if !self.touchDrawUndoManager!.canRedo {
                if self.redoEnabled {
                    self.delegate?.redoDisabled?()
                    self.redoEnabled = false
                }
            }

            self.checkClearState()
        }
    }

    // MARK: - Actions

    /// triggered when touches begin
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesMoved = false
        if let touch = touches.first {
            self.lastPoint = touch.location(in: self)
            self.pointsArray = []
            self.pointsArray.append(NSStringFromCGPoint(self.lastPoint))
        }
    }

    /// triggered when touches move
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesMoved = true

        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            self.drawLineFrom(self.lastPoint, toPoint: currentPoint, properties: self.brushProperties)

            self.lastPoint = currentPoint
            self.pointsArray.append(NSStringFromCGPoint(self.lastPoint))
        }
    }

    /// triggered whenever touches end, resulting in a newly created Stroke
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.touchesMoved {
            // draw a single point
            self.drawLineFrom(self.lastPoint, toPoint: self.lastPoint, properties: self.brushProperties)
        }

        self.mergeViews()

        let stroke = Stroke()
        stroke.settings = StrokeSettings(settings: self.brushProperties)
        stroke.points = self.pointsArray

        self.stack.append(stroke)

        self.touchDrawUndoManager!.registerUndo(withTarget: self, selector: #selector(TouchDrawView.popDrawing), object: nil)

        if !self.undoEnabled {
            self.delegate?.undoEnabled?()
            self.undoEnabled = true
        }
        if self.redoEnabled {
            self.delegate?.redoDisabled?()
            self.redoEnabled = false
        }
        if !self.clearEnabled {
            self.delegate?.clearEnabled?()
            self.clearEnabled = true
        }
    }
}
