/*
 Emulator.swift -- Interface to Emulator Core
 Copyright (C) 2019 Dieter Baron
 
 This file is part of C64, a Commodore 64 emulator for iOS, based on VICE.
 The authors can be contacted at <c64@spiderlab.at>
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 02111-1307  USA.
 */

import Foundation
import UIKit

public protocol Emulator: class {
    var machine: Machine { get set }
    var imageView: UIImageView? { get set }
    var delegate: EmulatorDelegate? { get set }

    // trigger cartridge freeze function
    func freeze()
    
    // press key, delayed by given number of frames
    func press(key: Key, delayed: Int)
    
    // quit emulation
    func quit()
    
    // release key, delayed by given number of frames
    func release(key: Key, delayed: Int)

    // reset machine
    func reset()
    
    func start()
    
    func attach(drive: Int, image: DiskImage?)

    func joystick(_ index: Int, buttons: JoystickButtons)
    
    func mouse(moved distance: CGPoint)
    
    func mouse(setX x: Int32)

    func mouse(setY y: Int32)

    func mouse(pressed button: Int)

    func mouse(release button: Int)

    func lightPen(moved position: CGPoint?, size: CGSize, button1: Bool, button2: Bool, isKoalaPad: Bool)

    func setResource(name: Machine.ResourceName, value: Machine.ResourceValue)

    func setResourceNow(name: Machine.ResourceName, value: Machine.ResourceValue)

    func set(borderMode: MachineConfig.BorderMode)
}


public extension Emulator {
    func press(key: Key) {
        press(key: key, delayed: 0)
    }
    
    func release(key: Key) {
        release(key: key, delayed: 0)
    }
}