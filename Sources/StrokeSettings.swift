//
//  StrokeSettings
//  TouchDraw
//
//  Created by Christian Paul Dehli on 9/4/16.
//

/// properties to describe the brush
public class StrokeSettings {
    
    /// color of the brush
    internal var color: CIColor!
    /// width of the brush
    internal var width: CGFloat!
    
    init() {
        self.color = CIColor(color: UIColor.blackColor())
        self.width = CGFloat(10.0)
    }
    init(settings: StrokeSettings) {
        self.color = settings.color
        self.width = settings.width
    }
    init(color: CIColor, width: CGFloat) {
        self.color = color
        self.width = width
    }
}