//
//  StrokeSettings.swift
//  TouchDraw
//
//  Created by Christian Paul Dehli on 9/4/16.
//

/// Properties to describe a stroke (color, width)
open class StrokeSettings: NSObject {

    /// Color of the brush
    private static let defaultColor = CIColor(color: UIColor.black)
    internal var color: CIColor?

    /// Width of the brush
    private static let defaultWidth = CGFloat(10.0)
    internal var width: CGFloat

    /// Default initializer
    override public init() {
        color = StrokeSettings.defaultColor
        width = StrokeSettings.defaultWidth
        super.init()
    }

    /// Initializes a StrokeSettings with another StrokeSettings object
    public convenience init(_ settings: StrokeSettings) {
        self.init()
        self.color = settings.color
        self.width = settings.width
    }

    /// Initializes a StrokeSettings with a color and width
    public convenience init(color: CIColor?, width: CGFloat) {
        self.init()
        self.color = color
        self.width = width
    }

    /// Used to decode a StrokeSettings with a decoder
    required public convenience init?(coder aDecoder: NSCoder) {
        let color = aDecoder.decodeObject(forKey: StrokeSettings.colorKey) as? CIColor
        var width = aDecoder.decodeObject(forKey: StrokeSettings.widthKey) as? CGFloat
        if width == nil {
            width = StrokeSettings.defaultWidth
        }

        self.init(color: color, width: width!)
    }
}

// MARK: - NSCoding

extension StrokeSettings: NSCoding {
    internal static let colorKey = "color"
    internal static let widthKey = "width"

    /// Used to encode a StrokeSettings with a coder
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.color, forKey: StrokeSettings.colorKey)
        aCoder.encode(self.width, forKey: StrokeSettings.widthKey)
    }
}
