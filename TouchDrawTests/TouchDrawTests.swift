//
//  TouchDrawTests.swift
//  TouchDrawTests
//
//  Created by Christian Paul Dehli on 10/10/15.
//  Copyright © 2015 Christian Paul Dehli. All rights reserved.
//

import XCTest
@testable import TouchDraw

class TouchDrawTests: XCTestCase {
    
    var viewController: TouchDrawViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewController = TouchDrawViewController()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /// Tests whether the TouchDrawView enables undoing after one point is drawn
    func testEnableUndo() {
        var touches = Set<UITouch>()
        touches.insert(UITouch())
        
        viewController.touchDrawView.touchesBegan(touches, withEvent: nil)
        viewController.touchDrawView.touchesEnded(touches, withEvent: nil)
        
        XCTAssertTrue(viewController.undoIsEnabled, "Undo should be enabled")        
    }
    
    /// Tests whether you clearing empties the strokes
    func testClearing() {
        var touches = Set<UITouch>()
        touches.insert(UITouch())

        viewController.touchDrawView.touchesBegan(touches, withEvent: nil)
        viewController.touchDrawView.touchesEnded(touches, withEvent: nil)
        
        XCTAssert(viewController.touchDrawView.stack.count > 0, "Should have strokes on view")
        viewController.touchDrawView.clearDrawing()
        XCTAssert(viewController.touchDrawView.stack.count == 0, "Should not have strokes on view")
    }
    
}
