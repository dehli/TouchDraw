//
//  Stroke.swift
//  TouchDraw
//
//  Created by Christian Paul Dehli on 9/4/16.
//


/// a drawing stroke
public class Stroke {
    /// the points that make up the stroke
    internal var points: [String]!
    /// the properties of the stroke
    internal var settings: StrokeSettings!
    
    init() {
        self.points = [];
        self.settings = StrokeSettings()
    }
    
    init(points: [String], settings: StrokeSettings) {
        self.points = points
        self.settings = settings
    }    
}