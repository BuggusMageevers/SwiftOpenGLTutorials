//
//  GraphicToolsViewController.swift
//  OpenGLDemo
//
//  Created by Myles La Verne Schultz on 8/3/20.
//  Copyright © 2020 Myles La Verne Schultz. All rights reserved.
//

import Cocoa

class GraphicToolsViewController: NSViewController {
    @IBOutlet weak var numberOfTrianglesField: NSTextField!
    @IBOutlet weak var currentTriangleField: NSTextField! {
        didSet {
            getView()?.startTriangle = UInt(currentTriangleField.stringValue)!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    func getView() -> GraphicView? {
        let controller = self.parent as? NSSplitViewController
        let viewItem = controller?.splitViewItems.compactMap() { $0.viewController as? GraphicViewController }
        return viewItem?.first?.graphicView
    }
    @IBAction func translateXSlider(_ sender: NSSlider) {
        getView()?.cameraPosition = Float3(x: sender.floatValue, y: getView()!.cameraRotation.y, z: getView()!.cameraRotation.z)
    }
    @IBAction func translateYSlider(_ sender: NSSlider) {
        getView()?.cameraPosition = Float3(x: getView()!.cameraRotation.x, y: sender.floatValue, z: getView()!.cameraRotation.z)
    }
    @IBAction func translateZSlider(_ sender: NSSlider) {
        getView()?.cameraPosition = Float3(x: getView()!.cameraRotation.x, y: getView()!.cameraRotation.y, z: sender.floatValue)
    }
    @IBAction func rotateXSlider(_ sender: NSSlider) {
        getView()?.cameraRotation = Float3(x: sender.floatValue, y: getView()!.cameraRotation.y, z: getView()!.cameraRotation.z)
    }
    @IBAction func rotateYSlider(_ sender: NSSlider) {
        getView()?.cameraRotation = Float3(x: getView()!.cameraRotation.x, y: sender.floatValue, z: getView()!.cameraRotation.z)
    }
    @IBAction func rotateZSlider(_ sender: NSSlider) {
        getView()?.cameraRotation = Float3(x: getView()!.cameraRotation.x, y: getView()!.cameraRotation.y, z: sender.floatValue)
    }
    @IBAction func setNumberOfTriangles(_ sender: NSTextField) {
        numberOfTrianglesField.stringValue = sender.stringValue.filter() { $0 >= "0" && $0 <= "9" }
        getView()?.numberOfTrianglesToDraw = UInt(numberOfTrianglesField.stringValue)!
    }
    @IBAction func setCurrentTriangle(_ sender: NSTextField) {
        currentTriangleField.stringValue = sender.stringValue.filter() { $0 >= "0" && $0 <= "9" }
        getView()?.startTriangle = UInt(currentTriangleField.stringValue)!
    }
}
