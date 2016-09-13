//
//  Stroke.swift
//  TouchDraw
//
//  Created by Christian Paul Dehli on 9/4/16.
//


/// a drawing stroke
public class Stroke: NSObject, NSCoding {
    
    /// the points that make up the stroke
    internal var points: [String]!
    
    /// the properties of the stroke
    internal var settings: StrokeSettings!
    
    /// default initialization
    override init() {
        super.init()
        self.points = [];
        self.settings = StrokeSettings()
    }
    
    /// initialize a stroke with ceertain points and stroke settings
    init(points: [String], settings: StrokeSettings) {
        super.init()
        self.points = points
        self.settings = settings
    }
    
    // MARK: NSCoding
    
    /// Used to decode a Stroke with a decoder
    required public convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        self.points = aDecoder.decodeObjectForKey("points") as! [String]!
        self.settings = aDecoder.decodeObjectForKey("settings") as! StrokeSettings!
    }
    
    /// Used to encode a Stroke with a coder
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.points, forKey: "points")
        aCoder.encodeObject(self.settings, forKey: "settings")
    }
}