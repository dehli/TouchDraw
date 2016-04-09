//
//  TouchDrawTests.swift
//  TouchDrawTests
//
//  Created by Christian Paul Dehli on 10/10/15.
//  Copyright © 2015 Christian Paul Dehli. All rights reserved.
//

import XCTest
@testable import TouchDraw

class TouchDrawTests: XCTestCase, TouchDrawViewDelegate {
    
    var undoIsEnabled: Bool!
    var redoIsEnabled: Bool!
    var clearIsEnabled: Bool!
    
    var touchDrawView: TouchDrawView!
    
    override func setUp() {
        super.setUp()
        
        undoIsEnabled = false
        redoIsEnabled = false
        clearIsEnabled = false
        
        touchDrawView = TouchDrawView()
        touchDrawView.delegate = self
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /// Tests whether TouchDrawView enables undo after one point is drawn
    func testEnableUndo() {
        simulateTouch()
        XCTAssertTrue(undoIsEnabled, "Undo should be enabled")
    }
    
    /// Tests whether clearing empties the strokes
    func testClearing() {
        simulateTouch()
        XCTAssert(touchDrawView.stack.count > 0, "Should have strokes on view")
        touchDrawView.clearDrawing()
        XCTAssert(touchDrawView.stack.count == 0, "Should not have strokes on view")
    }
    
    /// Tests to make sure clear is enabled after you make a stroke
    func testClearEnabled() {
        simulateTouch()
        XCTAssertTrue(clearIsEnabled, "Clear should be enabled after a stroke")
    }
    
    /// Tests to make sure clear is diabled after calling clearDrawing()
    func testClearDisabled() {
        simulateTouch()
        touchDrawView.clearDrawing()
        XCTAssertFalse(clearIsEnabled, "Clear should not be enabled after calling clearDrawing()")
    }
    
    /// Tests undoing functionality
    func testUndo() {
        simulateTouch()
        XCTAssert(touchDrawView.stack.count == 1, "Should have one stroke")
        touchDrawView.undo()
        XCTAssert(touchDrawView.stack.count == 0, "Should not have any strokes")
    }
    
    /// Tests whether TouchDrawView enables redo after undoing a point
    func testEnableRedo() {
        simulateTouch()
        touchDrawView.undo()
        XCTAssertTrue(redoIsEnabled, "Redo should be enabled")
    }
    
    /// Internal function used to simulate a touch
    private func simulateTouch() {
        var touches = Set<UITouch>()
        touches.insert(UITouch())
        touchDrawView.touchesBegan(touches, withEvent: nil)
        touchDrawView.touchesEnded(touches, withEvent: nil)
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
