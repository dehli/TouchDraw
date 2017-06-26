//
//  StrokeSettings.swift
//  TouchDraw
//
//  Created by Christian Paul Dehli on 9/4/16.
//

/// Properties to describe a stroke (color, width)
open class StrokeSettings: NSObject {
    
    /// Color of the brush
    internal var color: CIColor

    /// Width of the brush
    internal var width: CGFloat

    /// Default initializer
    override init() {
        self.color = CIColor(color: UIColor.black)
        self.width = CGFloat(10.0)
        super.init()
    }

    /// Initializes a StrokeSettings with another StrokeSettings object
    public init(settings: StrokeSettings) {
        self.color = settings.color
        self.width = settings.width
        super.init()
    }

    /// Initializes a StrokeSettings with a color and width
    public convenience init(color: CIColor, width: CGFloat) {
        self.init()
        self.color = color
        self.width = width
    }
    
    /// Used to decode a StrokeSettings with a decoder
    public convenience required init?(coder aDecoder: NSCoder) {
        let color = aDecoder.decodeObject(forKey: StrokeSettings.colorKey) as! CIColor
        let width = aDecoder.decodeObject(forKey: StrokeSettings.widthKey) as! CGFloat
        
        self.init(color: color, width: width)
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
