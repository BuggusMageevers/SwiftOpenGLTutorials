//
//  OpenGLWindow.swift
//  OpenGLDemo
//
//  Created by Myles La Verne Schultz on 8/16/20.
//  Copyright © 2020 Myles La Verne Schultz. All rights reserved.
//

import Cocoa

class OpenGLWindow: NSWindow {
    //  In order for NSTextField to work in a borderless
    //  window, the following needs to be set to true
    override var canBecomeKey: Bool {
        return true
    }
}
