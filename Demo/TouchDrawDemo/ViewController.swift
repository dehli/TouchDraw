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
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var redoButton: UIBarButtonItem!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var eraserButton: UIBarButtonItem!

    private static let deltaWidth = CGFloat(2.0)

    override func viewDidLoad() {
        super.viewDidLoad()

        drawView.delegate = self
        drawView.setWidth(ViewController.deltaWidth)
        drawView.image = UIImage(named: "image.png")

        undoButton.isEnabled = false
        redoButton.isEnabled = false
        clearButton.isEnabled = false
    }

    @IBAction func eraserClicked(_ sender: Any) {
        drawView.setColor(nil)
        eraserButton.isEnabled = false
    }

    @IBAction func clear(_ sender: AnyObject) {
        drawView.clearDrawing()
    }

    // Slider can vary from 1 to 10
    @IBAction func sliderChanged(_ sender: UISlider) {
        let newWidth = CGFloat(sender.value) * ViewController.deltaWidth
        drawView.setWidth(newWidth)
    }

    @IBAction func randomColor(_ sender: AnyObject) {
        let red = CGFloat(arc4random() % 255) / 255
        let green = CGFloat(arc4random() % 255) / 255
        let blue = CGFloat(arc4random() % 255) / 255

        let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        drawView.setColor(color)
        eraserButton.isEnabled = true
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
