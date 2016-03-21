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
    
    private var deltaWidth = 2.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawView.delegate = self
        drawView.setWidth(CGFloat(deltaWidth))
        
        undoButton.enabled = false
        redoButton.enabled = false
        clearButton.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clear(sender: AnyObject) {
        drawView.clearDrawing()
    }
    
    // Slider can vary from 1 to 10
    @IBAction func sliderChanged(sender: UISlider) {
        let newWidth = Double(sender.value) * deltaWidth
        drawView.setWidth(CGFloat(newWidth))
    }
    
    @IBAction func randomColor(sender: AnyObject) {
        let r = CGFloat(random() % 255) / 255
        let g = CGFloat(random() % 255) / 255
        let b = CGFloat(random() % 255) / 255
        
        let color = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        drawView.setColor(color)
    }
    
    @IBAction func undo(sender: AnyObject) {
        drawView.undo()
    }
    
    @IBAction func redo(sender: AnyObject) {
        drawView.redo()
    }
    
    // MARK: - TouchDrawViewDelegate
    
    func undoEnabled() {
        self.undoButton.enabled = true
    }
    
    func undoDisabled() {
        self.undoButton.enabled = false
    }
    
    func redoEnabled() {
        self.redoButton.enabled = true
    }
    
    func redoDisabled() {
        self.redoButton.enabled = false
    }
    
    func clearEnabled() {
        self.clearButton.enabled = true
    }
    
    func clearDisabled() {
        self.clearButton.enabled = false
    }
}

