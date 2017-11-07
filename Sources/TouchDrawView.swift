//
//  TouchDrawView.swift
//  TouchDraw
//
//  Created by Christian Paul Dehli
//

/// The protocol which the container of TouchDrawView can conform to
@objc public protocol TouchDrawViewDelegate {
    /// triggered when undo is enabled (only if it was previously disabled)
    @objc optional func undoEnabled()

    /// triggered when undo is disabled (only if it previously enabled)
    @objc optional func undoDisabled()

    /// triggered when redo is enabled (only if it was previously disabled)
    @objc optional func redoEnabled()

    /// triggered when redo is disabled (only if it previously enabled)
    @objc optional func redoDisabled()

    /// triggered when clear is enabled (only if it was previously disabled)
    @objc optional func clearEnabled()

    /// triggered when clear is disabled (only if it previously enabled)
    @objc optional func clearDisabled()
}

/// A subclass of UIView which allows you to draw on the view using your fingers
open class TouchDrawView: UIView {

    /// Should be set in whichever class is using the TouchDrawView
    open weak var delegate: TouchDrawViewDelegate?

    /// Used to register undo and redo actions
    fileprivate var touchDrawUndoManager: UndoManager!

    /// Used to keep track of all the strokes
    internal var stack: [Stroke]!

    /// Used to keep track of the current StrokeSettings
    fileprivate var settings: StrokeSettings!

    fileprivate let imageView = UIImageView()

    /// Initializes a TouchDrawView instance
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize(frame)
    }

    /// Initializes a TouchDrawView instance
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize(CGRect.zero)
    }

    /// Adds the subviews and initializes stack
    private func initialize(_ frame: CGRect) {
        stack = []
        settings = StrokeSettings()

        addSubview(imageView)

        touchDrawUndoManager = undoManager
        if touchDrawUndoManager == nil {
            touchDrawUndoManager = UndoManager()
        }

        // Initially sets the frames of the UIImageView
        draw(frame)
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
        if self.stack.count == 0 && stack.count > 0 {
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

    /// Exports the current drawing
    open func exportDrawing() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, UIScreen.main.scale)
        imageView.image?.draw(in: imageView.frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    /// Clears the drawing
    @objc open func clearDrawing() {
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
        redrawStack()
    }

    /// Sets the brush's color
    open func setColor(_ color: UIColor?) {
        if color == nil {
            settings.color = nil
        } else {
            settings.color = CIColor(color: color!)
        }
    }

    /// Sets the brush's width
    open func setWidth(_ width: CGFloat) {
        settings.width = width
    }

    /// If possible, it will redo the last undone stroke
    open func redo() {
        if touchDrawUndoManager.canRedo {
            let stackCount = stack.count

            if !touchDrawUndoManager.canUndo {
                delegate?.undoEnabled?()
            }

            touchDrawUndoManager.redo()

            if !touchDrawUndoManager.canRedo {
                self.delegate?.redoDisabled?()
            }

            updateClear(oldStackCount: stackCount)
        }
    }

    /// If possible, it will undo the last stroke
    open func undo() {
        if touchDrawUndoManager.canUndo {
            let stackCount = stack.count

            if !touchDrawUndoManager.canRedo {
                delegate?.redoEnabled?()
            }

            touchDrawUndoManager.undo()

            if !touchDrawUndoManager.canUndo {
                delegate?.undoDisabled?()
            }

            updateClear(oldStackCount: stackCount)
        }
    }

    /// Update clear after either undo or redo
    internal func updateClear(oldStackCount: Int) {
        if oldStackCount > 0 && stack.count == 0 {
            delegate?.clearDisabled?()
        } else if oldStackCount == 0 && stack.count > 0 {
            delegate?.clearEnabled?()
        }
    }

    /// Removes the last Stroke from stack
    @objc internal func popDrawing() {
        touchDrawUndoManager.registerUndo(withTarget: self,
                                          selector: #selector(pushDrawing(_:)),
                                          object: stack.popLast())
        redrawStack()
    }

    /// Adds a new stroke to the stack
    @objc internal func pushDrawing(_ stroke: Stroke) {
        stack.append(stroke)
        drawStrokeWithContext(stroke)
        touchDrawUndoManager.registerUndo(withTarget: self, selector: #selector(popDrawing), object: nil)
    }

    /// Draws all of the strokes
    @objc internal func pushAll(_ strokes: [Stroke]) {
        stack = strokes
        redrawStack()
        touchDrawUndoManager.registerUndo(withTarget: self, selector: #selector(clearDrawing), object: nil)
    }
}

// MARK: - Touch Actions

extension TouchDrawView {

    /// Triggered when touches begin
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let stroke = Stroke(points: [touch.location(in: self)],
                                settings: settings)
            stack.append(stroke)
        }
    }

    /// Triggered when touches move
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let stroke = stack.last!
            let lastPoint = stroke.points.last
            let currentPoint = touch.location(in: self)
            drawLineWithContext(fromPoint: lastPoint!, toPoint: currentPoint, properties: stroke.settings)
            stroke.points.append(currentPoint)
        }
    }

    /// Triggered whenever touches end, resulting in a newly created Stroke
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let stroke = stack.last!
        if stroke.points.count == 1 {
            let lastPoint = stroke.points.last!
            drawLineWithContext(fromPoint: lastPoint, toPoint: lastPoint, properties: stroke.settings)
        }

        if !touchDrawUndoManager.canUndo {
            delegate?.undoEnabled?()
        }

        if touchDrawUndoManager.canRedo {
            delegate?.redoDisabled?()
        }

        if stack.count == 1 {
            delegate?.clearEnabled?()
        }

        touchDrawUndoManager.registerUndo(withTarget: self, selector: #selector(popDrawing), object: nil)
    }
}

// MARK: - Drawing

fileprivate extension TouchDrawView {

    /// Begins the image context
    func beginImageContext() {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
    }

    /// Ends image context and sets UIImage to what was on the context
    func endImageContext() {
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }

    /// Draws the current image for context
    func drawCurrentImage() {
        imageView.image?.draw(in: imageView.frame)
    }

    /// Clears view, then draws stack
    func redrawStack() {
        beginImageContext()
        for stroke in stack {
            drawStroke(stroke)
        }
        endImageContext()
    }

    /// Draws a single Stroke
    func drawStroke(_ stroke: Stroke) {
        let properties = stroke.settings
        let points = stroke.points

        if points.count == 1 {
            let point = points[0]
            drawLine(fromPoint: point, toPoint: point, properties: properties)
        }

        for i in stride(from: 1, to: points.count, by: 1) {
            let point0 = points[i - 1]
            let point1 = points[i]
            drawLine(fromPoint: point0, toPoint: point1, properties: properties)
        }
    }

    /// Draws a single Stroke (begins/ends context
    func drawStrokeWithContext(_ stroke: Stroke) {
        beginImageContext()
        drawCurrentImage()
        drawStroke(stroke)
        endImageContext()
    }

    /// Draws a line between two points
    func drawLine(fromPoint: CGPoint, toPoint: CGPoint, properties: StrokeSettings) {
        let context = UIGraphicsGetCurrentContext()
        context!.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context!.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))

        context!.setLineCap(CGLineCap.round)
        context!.setLineWidth(properties.width)

        let color = properties.color
        if color != nil {
            context!.setStrokeColor(red: properties.color!.red,
                                    green: properties.color!.green,
                                    blue: properties.color!.blue,
                                    alpha: properties.color!.alpha)
            context!.setBlendMode(CGBlendMode.normal)
        } else {
            context!.setBlendMode(CGBlendMode.clear)
        }

        context!.strokePath()
    }

    /// Draws a line between two points (begins/ends context)
    func drawLineWithContext(fromPoint: CGPoint, toPoint: CGPoint, properties: StrokeSettings) {
        beginImageContext()
        drawCurrentImage()
        drawLine(fromPoint: fromPoint, toPoint: toPoint, properties: properties)
        endImageContext()
    }
}
