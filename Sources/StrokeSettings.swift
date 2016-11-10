//
//  StrokeSettings
//  TouchDraw
//
//  Created by Christian Paul Dehli on 9/4/16.
//

/// properties to describe the brush
open class StrokeSettings: NSObject, NSCoding {

    /// color of the brush
    internal var color: CIColor!

    /// width of the brush
    internal var width: CGFloat!

    override init() {
        super.init()
        self.color = CIColor(color: UIColor.black)
        self.width = CGFloat(10.0)
    }

    init(settings: StrokeSettings) {
        super.init()
        self.color = settings.color
        self.width = settings.width
    }

    init(color: CIColor, width: CGFloat) {
        super.init()
        self.color = color
        self.width = width
    }

    // MARK: NSCoding

    required public convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        self.color = aDecoder.decodeObject(forKey: "color") as! CIColor!
        self.width = aDecoder.decodeObject(forKey: "width") as! CGFloat!
    }

    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.color, forKey: "color")
        aCoder.encode(self.width, forKey: "width")
    }
}
