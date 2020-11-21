//
//  GraphicMathTests.swift
//  OpenGLDemoTests
//
//  Created by Myles La Verne Schultz on 6/25/20.
//  Copyright © 2020 Myles La Verne Schultz. All rights reserved.
//

import XCTest
@testable import OpenGLDemo

class Float2Tests: XCTestCase {
    var sut: Float2?
    
    override func setUp() {
        
    }

    override func tearDown() {
        sut = nil
    }

    func testFloat2_wherex0y0_initialize() {
        sut = Float2()
        
        XCTAssert(sut?.x == 0 && sut?.y == 0)
    }
    func testFloat2_where2x3_initialize() {
        sut = Float2(x: 2, y: 3)
        
        XCTAssertEqual(sut?.x, 2)
        XCTAssertEqual(sut?.y, 3)
    }
    func testFloat2_where2x3_equal() {
        sut = Float2(x: 2, y: 3)
        
        XCTAssertTrue(sut! == sut!)
    }
    func testFloat2_where2x3_notEqual() {
        sut = Float2(x: 2, y: 3)
        
        XCTAssertFalse(sut! != sut!)
    }
    func testFloat2_where2x4and3x5_add() {
        let lhs = Float2(x: 2, y: 4)
        let rhs = Float2(x: 3, y: 5)
        
        let expected = Float2(x: 5, y: 9)
        XCTAssertEqual(lhs + rhs, expected)
    }
    func testFloat2_where2x5and3x3_subtract() {
        let lhs = Float2(x: 2, y: 5)
        let rhs = Float2(x: 3, y: 3)
        
        let expected = Float2(x: -1, y: 2)
        XCTAssertEqual(lhs - rhs, expected)
    }
    func testFloat2_where2x4and0_multiply() {
        let lhs = Float2(x: 2, y: 4)
        let rhs = Float(0.0)
        
        let expected = Float2(x: 0, y: 0)
        XCTAssertEqual(lhs * rhs, expected)
        XCTAssertEqual(rhs * lhs, expected)
    }
    func testFloat2_where2x4and3x5_dotProduct() {
        let lhs = Float2(x: 2, y: 4)
        let rhs = Float2(x: 3, y: 5)
    
        let expected = Float(26)
        XCTAssertEqual(lhs.dotProduct(rhs), expected)
    }
    func testFloat2_where2x0and3x5_dotProduct() {
        let lhs = Float2(x: 2, y: 0)
        let rhs = Float2(x: 3, y: 5)
        
        let expected = Float(6)
        XCTAssertEqual(lhs.dotProduct(rhs), expected)
    }
    func testFloat2_2x4_length() {
        let lhs = Float2(x: 2, y: 4)
        
        let expected = Float(4.472135955)
        XCTAssertEqual(lhs.length(), expected)
    }
    func testFloat2_0x0_length() {
        let lhs = Float2(x: 0, y: 0)
        
        let expected = Float(0)
        XCTAssertEqual(lhs.length(), expected)
    }
}

class Float3Tests: XCTestCase {
    
}
