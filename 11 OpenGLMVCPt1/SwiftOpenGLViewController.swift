//
//  ViewController.swift
//  OpenGLMVCPt1
//
//  Created by Myles Schultz on 9/30/16.
//  Copyright © 2016 MyKo. All rights reserved.
//
//  Ver 3:  First step in developing our app to be MVC compliant.  Uses
//      an IBOutlet to reference the instance of SwiftOpenGLView we
//      created in interface builder.
//

import Cocoa


class SwiftOpenGLViewController: NSViewController {
    @IBOutlet weak var interactiveView: SwiftOpenGLView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
}
