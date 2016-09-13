//
//  StrokeSettings
//  TouchDraw
//
//  Created by Christian Paul Dehli on 9/4/16.
//

/// properties to describe the brush
public class StrokeSettings: NSObject, NSCoding {

    /// color of the brush
    internal var color: CIColor!

    /// width of the brush
    internal var width: CGFloat!

    override init() {
        super.init()
        self.color = CIColor(color: UIColor.blackColor())
        self.width = CGFloat(10.0)
    }

    /// initializes a StrokeSettings with another StrokeSettings object
    init(settings: StrokeSettings) {
        super.init()
        self.color = settings.color
        self.width = settings.width
    }

    /// initializes a StrokeSettings with a color and width
    init(color: CIColor, width: CGFloat) {
        super.init()
        self.color = color
        self.width = width
    }

    // MARK: NSCoding

    /// Used to decode a StrokeSettings with a decoder
    required public convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        self.color = aDecoder.decodeObjectForKey("color") as! CIColor!
        self.width = aDecoder.decodeObjectForKey("width") as! CGFloat!
    }

    /// Used to encode a StrokeSettings with a coder
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.color, forKey: "color")
        aCoder.encodeObject(self.width, forKey: "width")
    }
}