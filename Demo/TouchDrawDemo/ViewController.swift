//
//  ViewController.swift
//  TouchDrawDemo
//
//  Created by Christian Paul Dehli on 10/4/15.
//

import UIKit
import TouchDraw

class ViewController: UIViewController, TouchDrawViewDelegate {
    
    @IBOutlet var drawView: TouchDrawView!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    
    fileprivate var deltaWidth = 2.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawView.delegate = self
        drawView.setWidth(CGFloat(deltaWidth))
        
        undoButton.isEnabled = false
        redoButton.isEnabled = false
        clearButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clear(_ sender: AnyObject) {
        drawView.clearDrawing()
    }
    
    // Slider can vary from 1 to 10
    @IBAction func sliderChanged(_ sender: UISlider) {
        let newWidth = Double(sender.value) * deltaWidth
        drawView.setWidth(CGFloat(newWidth))
    }
    
    @IBAction func randomColor(_ sender: AnyObject) {
        let r = CGFloat(arc4random() % 255) / 255
        let g = CGFloat(arc4random() % 255) / 255
        let b = CGFloat(arc4random() % 255) / 255
        
        let color = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        drawView.setColor(color)
    }
    
    @IBAction func undo(_ sender: AnyObject) {
        drawView.undo()
    }
    
    @IBAction func redo(_ sender: AnyObject) {
        drawView.redo()
    }
    
    // MARK: - TouchDrawViewDelegate
    
    func undoEnabled() {
        self.undoButton.isEnabled = true
    }
    
    func undoDisabled() {
        self.undoButton.isEnabled = false
    }
    
    func redoEnabled() {
        self.redoButton.isEnabled = true
    }
    
    func redoDisabled() {
        self.redoButton.isEnabled = false
    }
    
    func clearEnabled() {
        self.clearButton.isEnabled = true
    }
    
    func clearDisabled() {
        self.clearButton.isEnabled = false
    }
}

