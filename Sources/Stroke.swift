//
//  Stroke.swift
//  TouchDraw
//
//  Created by Christian Paul Dehli on 9/4/16.
//


/// a drawing stroke
open class Stroke: NSObject, NSCoding {

    /// the points that make up the stroke
    internal var points: [String]!

    /// the properties of the stroke
    internal var settings: StrokeSettings!

    /// default initialization
    override public init() {
        super.init()
        self.points = [];
        self.settings = StrokeSettings()
    }

    /// initialize a stroke with ceertain points and stroke settings
    public init(points: [String], settings: StrokeSettings) {
        super.init()
        self.points = points
        self.settings = settings
    }

    // MARK: NSCoding

    /// Used to decode a Stroke with a decoder
    required public convenience init?(coder aDecoder: NSCoder) {
        self.init()

        self.points = aDecoder.decodeObject(forKey: "points") as! [String]!
        self.settings = aDecoder.decodeObject(forKey: "settings") as! StrokeSettings!
    }

    /// Used to encode a Stroke with a coder
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.points, forKey: "points")
        aCoder.encode(self.settings, forKey: "settings")
    }
}
