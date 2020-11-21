//
//  GraphicViewTests.swift
//  OpenGLDemoTests
//
//  Created by Myles La Verne Schultz on 6/7/20.
//  Copyright © 2020 Myles La Verne Schultz. All rights reserved.
//

import XCTest
@testable import OpenGLDemo

class GraphicViewTests: XCTestCase {
    private var sut: ViewOrganizer!
    private var expectedGrid: ViewOrganizer.GridSize!
    private var grid: ViewOrganizer.GridSize!
    private var viewSize: ViewOrganizer.GridSize!
    private var calculatedSpaceSize: ViewOrganizer.GridSize!

    override func setUp() {
        sut = ViewOrganizer()
        viewSize = ViewOrganizer.GridSize(width: 100, height: 100)
    }

    override func tearDown() {
        sut = nil
        expectedGrid = nil
        grid = nil
        viewSize = nil
        calculatedSpaceSize = nil
    }
    
    func testViewOrganizer_GridSize_whereWidthIsZero_initGridSize() {
        grid = ViewOrganizer.GridSize()
        
        XCTAssertEqual(grid.width, 0)
    }
    func testViewOrganizer_GridSize_whereHeightIsZero_initGridSize() {
        grid = ViewOrganizer.GridSize()
        
        XCTAssertEqual(grid.height, 0)
    }
    func testViewOrganizer_GridSize_whereSizeIsFiveByZero_initGridSize() {
        grid = ViewOrganizer.GridSize(width: 5)
        
        XCTAssertEqual(grid.width, 5)
    }
    func testViewOrganizer_GridSize_whereSizeIsZeroBySix_initGridSize() {
        grid = ViewOrganizer.GridSize(height: 6)
        
        XCTAssertEqual(grid.height, 6)
    }
    func textViewOrganizer_whereAreaIsZero_generateGrid() {
        sut = ViewOrganizer(numberOfSpaces: 0)
        
        grid = sut.generateGrid()
        
        expectedGrid = ViewOrganizer.GridSize(width: 1, height: 1)
        XCTAssertEqual(grid, expectedGrid)
    }
    func testViewOrganizer_whereAreaIsOne_generateGrid() {
        sut = ViewOrganizer(numberOfSpaces: 1)
        
        grid = sut.generateGrid()
        
        expectedGrid = ViewOrganizer.GridSize(width: 1, height: 1)
        XCTAssertEqual(grid, expectedGrid)
    }
    func testViewOrganizer_whereAreaIsFour_generateGrid() {
        sut = ViewOrganizer(numberOfSpaces: 4)
        
        grid = sut.generateGrid()
        
        expectedGrid = ViewOrganizer.GridSize(width: 2, height: 2)
        XCTAssertEqual(grid, expectedGrid)
    }
    func testViewOrganizer_whereAreaOfFive_generateGrid() {
        sut = ViewOrganizer(numberOfSpaces: 5)
        
        grid = sut.generateGrid()
        
        expectedGrid = ViewOrganizer.GridSize(width: 3, height: 2)
        XCTAssertEqual(grid, expectedGrid)
    }
    func testViewOrganizer_whereNumberOfSpaceIsZero_calculateSpaceSize() {
        sut = ViewOrganizer(numberOfSpaces: 0, viewSize: viewSize)
        grid = sut.generateGrid()
        
        calculatedSpaceSize = sut.calculateSpaceSize(forGrid: grid)
        
        expectedGrid = viewSize
        XCTAssertEqual(calculatedSpaceSize, expectedGrid)
    }
    func testViewOrganizer_whereNumbOfSpacesIsOne_calculateSpaceSize() {
        sut = ViewOrganizer(numberOfSpaces: 1, viewSize: viewSize)
        grid = sut.generateGrid()
        
        calculatedSpaceSize = sut.calculateSpaceSize(forGrid: grid)
        
        expectedGrid = ViewOrganizer.GridSize(width: 100, height: 100)
        XCTAssertEqual(calculatedSpaceSize, expectedGrid)
    }
    func testViewOrganizer_whereNumberOfSpacesIsTwo_calculateSpaceSize() {
        sut = ViewOrganizer(numberOfSpaces: 2, viewSize: viewSize)
        grid = sut.generateGrid()
        
        calculatedSpaceSize = sut.calculateSpaceSize(forGrid: grid)
        
        expectedGrid = ViewOrganizer.GridSize(width: 50, height: 100)
        XCTAssertEqual(calculatedSpaceSize, expectedGrid)
    }
    func testViewOrganizer_whereNumberOfSpacesIsFive_calculateSpaceSize() {
        sut = ViewOrganizer(numberOfSpaces: 5, viewSize: viewSize)
        grid = sut.generateGrid()
        
        calculatedSpaceSize = sut.calculateSpaceSize(forGrid: grid)
        
        expectedGrid = ViewOrganizer.GridSize(width: 33, height: 50)
        XCTAssertEqual(calculatedSpaceSize, expectedGrid)
    }
    func testViewOrganizer_whereNumberOfSpacesIsFour_layoutSpace0x0() {
        sut = ViewOrganizer(numberOfSpaces: 4, viewSize: viewSize)
        grid = sut.generateGrid()
        let spaceSize = sut.calculateSpaceSize(forGrid: grid)
        
        sut.layoutSpaces(withSize: spaceSize, forGrid: grid)
        
        let expectedSpace = [
            [
                ViewOrganizer.Space(x: 0, y: 0, width: 50, height: 50, backgroundColor: Float4(x: 0, y: 0, z: 0, w: 0)),
                ViewOrganizer.Space(x: 0, y: 50, width: 50, height: 50, backgroundColor: Float4(x: 0, y: 0, z: 0, w: 0))
                ],
            [
                ViewOrganizer.Space(x: 50, y: 0, width: 50, height: 50, backgroundColor: Float4(x: 0, y: 0, z: 0, w: 0)),
                ViewOrganizer.Space(x: 50, y: 50, width: 50, height: 50, backgroundColor: Float4(x: 0, y: 0, z: 0, w: 0))
                ]
        ]
        XCTAssertEqual(sut.layout, expectedSpace)
    }
}
