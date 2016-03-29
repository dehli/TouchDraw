//
//  ViewController.swift
//  TouchDraw
//
//  Created by Christian Paul Dehli on 3/26/16.
//  Copyright © 2016 Christian Paul Dehli. All rights reserved.
//

@testable import TouchDraw

class ViewController: UIViewController, TouchDrawViewDelegate {
    
    internal var undoIsEnabled: Bool!
    internal var redoIsEnabled: Bool!
    internal var clearIsEnabled: Bool!
    
    internal var touchDrawView: TouchDrawView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.undoIsEnabled = false
        self.redoIsEnabled = false
        self.clearIsEnabled = false
        
        touchDrawView = self.view as! TouchDrawView
        touchDrawView.delegate = self        
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