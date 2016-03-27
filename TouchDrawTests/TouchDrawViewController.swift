//
//  TouchDrawViewController.swift
//  TouchDraw
//
//  Created by Christian Paul Dehli on 3/26/16.
//  Copyright © 2016 Christian Paul Dehli. All rights reserved.
//

@testable import TouchDraw

class TouchDrawViewController: UIViewController, TouchDrawViewDelegate {
    
    internal var undoIsEnabled: Bool!
    internal var redoIsEnabled: Bool!
    internal var clearIsEnabled: Bool!
    
    internal var touchDrawView: TouchDrawView!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.addTouchDrawView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTouchDrawView()
    }
    
    private func addTouchDrawView() {
        self.touchDrawView = TouchDrawView(frame: self.view.frame)
        self.view.addSubview(touchDrawView)
        touchDrawView.delegate = self
        
        self.undoIsEnabled = false
        self.redoIsEnabled = false
        self.clearIsEnabled = false
        
        print(self.touchDrawView.undoManager)
        
    }
    
    // MARK: - TouchDrawViewDelegate
    
    func undoEnabled() {
        self.undoIsEnabled = true
    }
    
    func undoDisabled() {
        self.undoIsEnabled = false
    }
    
    func redoEnabled() {
        self.redoIsEnabled = true
    }
    
    func redoDisabled() {
        self.redoIsEnabled = false
    }
    
    func clearEnabled() {
        self.clearIsEnabled = true
    }
    
    func clearDisabled() {
        self.clearIsEnabled = false
    }
}