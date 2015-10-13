//
//  ViewController.swift
//  TouchDrawDemo
//
//  Created by Christian Paul Dehli on 10/4/15.
//

import UIKit
import TouchDraw

class ViewController: UIViewController {
    
    @IBOutlet var drawView: TouchDrawView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawView.setWidth(5)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clear(sender: AnyObject) {
        drawView.clearDrawing()
    }
    
    @IBAction func randomColor(sender: AnyObject) {
        let r = CGFloat(random() % 255) / 255
        let g = CGFloat(random() % 255) / 255
        let b = CGFloat(random() % 255) / 255
        
        let color = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        drawView.setColor(color)
    }
    
    @IBAction func undo(sender: AnyObject) {
        // To be implemented
    }
    
    @IBAction func redo(sender: AnyObject) {
        // To be implemented
    }
}

