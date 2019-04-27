/*
 MachinePart.swift
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

let MachinePartLowPriority = 50
let MachinePartNormalPriority = 100
let MachinePartHighPriority = 200

protocol MachinePart {
    var identifier: String { get }
    var name: String { get }
    var fullName: String { get }
    var variantName: String? { get }
    var icon: UIImage? { get }
    var smallIcon: UIImage? { get }
    var priority: Int { get }
}

extension MachinePart {
    var fullName: String { return name }
    var smallIcon: UIImage? { return icon }
    var variantName: String? { return nil }
}