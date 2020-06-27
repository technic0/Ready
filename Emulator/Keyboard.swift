/*
 Keyboard.swift -- Layout of Virtual Keyboards
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

import UIKit

public struct Keyboard {
    private struct Polygon {
        var key: Key
        
        var vertices: [CGPoint]
        var left: CGFloat
        var right: CGFloat
        var top: CGFloat
        var bottom: CGFloat
        
        init(vertices: [CGPoint], key: Key) {
            self.vertices = vertices
            self.key = key

            if let first = vertices.first {
                left = first.x
                right = first.x
                top = first.y
                bottom = first.y
                
                for point in vertices.dropFirst() {
                    if point.x < left {
                        left = point.x
                    }
                    if point.x > right {
                        right = point.x
                    }
                    if point.y < top {
                        top = point.y
                    }
                    if point.y < bottom {
                        bottom = point.y
                    }
                }
            }
            else {
                // empty bounding box for empty polygon
                left = 1
                right = -1
                top = 1
                bottom = -1
            }
        }

        func hit(_ point: CGPoint) -> Key? {
            guard point.x >= left && point.x <= right && point.y >= top && point.y <= bottom else { return nil }
            guard var j = vertices.last else { return nil }

            var inside = false
            for i in vertices {
                if (i.y > point.y) != (j.y > point.y) && (point.x < (j.x - i.x) * (point.y - i.y) / (j.y - i.y) + i.x) {
                    inside = !inside
                }
                j = i
            }
            
            if inside {
                return key
            }
            else {
                return nil
            }
        }
    }
    private struct Span {
        var left: Int
        var right: Int
        var keys: [Key]
        
        func hit(_ point: CGPoint) -> Key? {
            guard (Int(point.x) >= left && Int(point.x) < Int(right)) else { return nil }
            let idx = (Int(point.x) - left) * keys.count / (right - left)
            return keys[idx]
        }
    }
    
    private struct Row {
        var top: Int
        var bottom: Int
        var spans: [Span]
        
        func hit(_ point: CGPoint) -> Key? {
            guard (Int(point.y) >= top && Int(point.y) < bottom) else { return nil }
            for span in spans {
                if let key = span.hit(point) {
                    return key
                }
            }
            
            return nil
        }
    }
    
    private struct Layout {
        var rows: [Row]
        var polygons: [Polygon]
        
        init(rows: [Row], polygons: [Polygon] = []) {
            self.rows = rows
            self.polygons = polygons
        }
        
        func hit(_ point: CGPoint) -> Key? {
            for row in rows {
                if let key = row.hit(point) {
                    return key
                }
            }
            for polygon in polygons {
                if let key = polygon.hit(point) {
                    return key
                }
            }
            
            return nil
        }
    }

    public var imageName: String
    public var toggleKeys: [Key: String]
    public var keyboardSymbols: KeyboardSymbols
    
    public func hit(_ point: CGPoint) -> Key? {
        return layout.hit(point)
    }
    
    private var layout: Layout
       
    private init(c64ImageName: String, lockIsShift: Bool = true, poundIsYen: Bool = false, rows: [Int], topHalfLeft: Int, topHalfRight: Int, bottomHalfLeft: Int, bottomHalfRight: Int, functionKeysLeft: Int, functionKeysRight: Int, spaceLeft: Int, spaceRight: Int, ctrlRight: Int, restoreLeft: Int, returnLeft: Int, leftShiftLeft: Int, leftShiftRight: Int, rightShiftLeft: Int, rightShiftRight: Int) {
        self.imageName = c64ImageName
        if lockIsShift {
            self.toggleKeys = [.ShiftLock: c64ImageName + " ShiftLock"]
        }
        else {
            self.toggleKeys = [.CommodoreLock: c64ImageName + " ShiftLock"]
        }
        self.layout = Layout(rows: [
            Row(top: rows[0], bottom: rows[1], spans: [
                Span(left: topHalfLeft, right: topHalfRight, keys: [
                    .ArrowLeft, .Char("1"), .Char("2"), .Char("3"), .Char("4"), .Char("5"), .Char("6"), .Char("7"), .Char("8"), .Char("9"), .Char("0"), .Char("+"), .Char("-"), .Char("£"), .ClearHome, .InsertDelete
                ]),
                Span(left: functionKeysLeft, right: functionKeysRight, keys: [.F1])
            ]),
            Row(top: rows[1], bottom: rows[2], spans: [
                Span(left: topHalfLeft, right: ctrlRight, keys: [.Control]),
                Span(left: ctrlRight, right: restoreLeft, keys: [
                    .Char("q"), .Char("w"), .Char("e"), .Char("r"), .Char("t"), .Char("y"), .Char("u"), .Char("i"), .Char("o"), .Char("p"), .Char("@"), .Char("*"), .ArrowUp
                ]),
                Span(left: restoreLeft, right: topHalfRight, keys: [.Restore]),
                Span(left: functionKeysLeft, right: functionKeysRight, keys: [.F3])
            ]),
            Row(top: rows[2], bottom: rows[3], spans: [
                Span(left: bottomHalfLeft, right: returnLeft, keys: [
                    .RunStop, lockIsShift ? .ShiftLock : .CommodoreLock, .Char("a"), .Char("s"), .Char("d"), .Char("f"), .Char("g"), .Char("h"), .Char("j"), .Char("k"), .Char("l"), .Char(":"), .Char(";"), .Char("=")
                ]),
                Span(left: returnLeft, right: bottomHalfRight, keys: [.Return]),
                Span(left: functionKeysLeft, right: functionKeysRight, keys: [.F5])
            ]),
            Row(top: rows[3], bottom: rows[4], spans: [
                Span(left: bottomHalfLeft, right: leftShiftLeft, keys: [.Commodore]),
                Span(left: leftShiftLeft, right: leftShiftRight, keys: [.ShiftLeft]),
                Span(left: leftShiftRight, right: rightShiftLeft, keys: [
                    .Char("z"), .Char("x"), .Char("c"), .Char("v"), .Char("b"), .Char("n"), .Char("m"), .Char(","), .Char("."), .Char("/"),
                ]),
                Span(left: rightShiftLeft, right: rightShiftRight, keys: [.ShiftRight]),
                Span(left: rightShiftRight, right: bottomHalfRight, keys: [.CursorUpDown, .CursorLeftRight]),
                Span(left: functionKeysLeft, right: functionKeysRight, keys: [.F7])
            ]),
            Row(top: rows[4], bottom: rows[5], spans: [
                Span(left: spaceLeft, right: spaceRight, keys: [.Char(" ")])
            ])
        ])
        self.keyboardSymbols = KeyboardSymbols.c64
        if poundIsYen {
            keyboardSymbols.keyMap[.Char("£")] = KeyboardSymbols.KeySymbols(normal: .char("¥"))
        }
    }
    
    private init(plus4ImageName: String, rows: [Int], functionLeft: Int, functionRight: Int, left: Int, right: Int, leftControlRight: Int, rightControlLeft: Int,returnLeft: Int, returnRight: Int, leftShiftLeft: Int, leftShiftRight: Int, rightShiftLeft: Int, rightShiftRight: Int, spaceLeft: Int, spaceRight: Int, cursorTop: CGFloat, cursorLeft: CGFloat, cursorRight: CGFloat, cursorBottom: CGFloat) {
        self.imageName = plus4ImageName
        self.toggleKeys = [.ShiftLock: imageName + " ShiftLock"]
        
        let cursorWidth = cursorRight - cursorLeft
        let cursorHeight = cursorBottom - cursorTop

        let cursorPoints = [
            CGPoint(x: cursorLeft + cursorWidth * 0.5, y: cursorTop),
            CGPoint(x: cursorLeft + cursorWidth * 0.25, y: cursorTop + cursorHeight * 0.25),
            CGPoint(x: cursorLeft + cursorWidth * 0.75, y: cursorTop + cursorHeight * 0.25),
            CGPoint(x: cursorLeft, y: cursorTop + cursorHeight * 8.5),
            CGPoint(x: cursorLeft + cursorWidth * 0.5, y: cursorTop + cursorHeight * 8.5),
            CGPoint(x: cursorRight, y: cursorTop + cursorHeight * 8.5),
            CGPoint(x: cursorLeft + cursorWidth * 0.25, y: cursorTop + cursorHeight * 0.75),
            CGPoint(x: cursorLeft + cursorWidth * 0.75, y: cursorTop + cursorHeight * 0.75),
            CGPoint(x: cursorLeft + cursorWidth * 0.5, y: cursorBottom)
        ]
        
        self.layout = Layout(rows: [
            Row(top: rows[0], bottom: rows[1], spans: [
                Span(left: functionLeft, right: functionRight, keys: [.F1, .F2, .F3, .Help])
            ]),
            Row(top: rows[1], bottom: rows[2], spans: [
                Span(left: left, right: right, keys: [.Escape, .Char("1"), .Char("2"), .Char("3"), .Char("4"), .Char("5"), .Char("6"), .Char("7"), .Char("8"), .Char("9"), .Char("0"), .Char("+"), .Char("-"), .Char("="), .ClearHome, .InsertDelete])
            ]),
            Row(top: rows[2], bottom: rows[3], spans: [
                Span(left: left, right: leftControlRight, keys: [.Control]),
                Span(left: leftControlRight, right: rightControlLeft, keys: [.Char("q"), .Char("w"), .Char("e"), .Char("r"), .Char("t"), .Char("y"), .Char("u"), .Char("i"), .Char("o"), .Char("p"), .Char("@"), .Char("£"), .Char("*")]),
                Span(left: rightControlLeft, right: right, keys: [.Control])
            ]),
            Row(top: rows[3], bottom: rows[4], spans: [
                Span(left: left, right: returnLeft, keys: [.RunStop, .ShiftLock, .Char("a"), .Char("s"), .Char("d"), .Char("f"), .Char("g"), .Char("h"), .Char("j"), .Char("k"), .Char("l"), .Char(":"), .Char(";")]),
                Span(left: returnLeft, right: returnRight, keys: [.Return])
            ]),
            Row(top: rows[4], bottom: rows[5], spans: [
                Span(left: left, right: leftShiftLeft, keys: [.Commodore]),
                Span(left: leftShiftLeft, right: leftShiftRight, keys: [.Shift]),
                Span(left: leftShiftRight, right: rightShiftLeft, keys: [.Char("z"), .Char("x"), .Char("c"), .Char("v"), .Char("b"), .Char("n"), .Char("m"), .Char(","), .Char("."), .Char("/")]),
                Span(left: rightShiftLeft, right: rightShiftRight, keys: [.Shift])
            ]),
            Row(top: rows[5], bottom: rows[6], spans: [
                Span(left: spaceLeft, right: spaceRight, keys: [.Char(" ")])
            ])
        ], polygons: [
            Polygon(vertices: [cursorPoints[0], cursorPoints[2], cursorPoints[4], cursorPoints[1]], key: .CursorUp),
            Polygon(vertices: [cursorPoints[1], cursorPoints[4], cursorPoints[6], cursorPoints[3]], key: .CursorLeft),
            Polygon(vertices: [cursorPoints[2], cursorPoints[5], cursorPoints[7], cursorPoints[4]], key: .CursorRight),
            Polygon(vertices: [cursorPoints[4], cursorPoints[7], cursorPoints[8], cursorPoints[6]], key: .CursorDown)
        ])
        self.keyboardSymbols = KeyboardSymbols.plus4
    }

    private static var keyboards: [String: Keyboard] = [
        "C64 Keyboard": Keyboard(c64ImageName: "C64 Keyboard",
                                 rows: [ 69, 257, 446, 635, 824, 1012 ],
                                 topHalfLeft: 100,
                                 topHalfRight: 3034,
                                 bottomHalfLeft: 49,
                                 bottomHalfRight: 2984,
                                 functionKeysLeft: 3115,
                                 functionKeysRight: 3415,
                                 spaceLeft: 544,
                                 spaceRight: 2207,
                                 ctrlRight: 330,
                                 restoreLeft: 2778,
                                 returnLeft: 2681,
                                 leftShiftLeft: 283,
                                 leftShiftRight: 559,
                                 rightShiftLeft: 2341,
                                 rightShiftRight: 2681),
        "C64 Keyboard Japanese": Keyboard(c64ImageName: "C64 Keyboard Japanese",
                                 lockIsShift: false,
                                 poundIsYen: true,
                                 rows: [ 70, 263, 457, 650, 843, 1027 ],
                                 topHalfLeft: 97,
                                 topHalfRight: 3148,
                                 bottomHalfLeft: 56,
                                 bottomHalfRight: 3098,
                                 functionKeysLeft: 3219,
                                 functionKeysRight: 3532,
                                 spaceLeft: 573,
                                 spaceRight: 2288,
                                 ctrlRight: 370,
                                 restoreLeft: 2869,
                                 returnLeft: 2723,
                                 leftShiftLeft: 231,
                                 leftShiftRight: 524,
                                 rightShiftLeft: 2436,
                                 rightShiftRight: 2723),
        "C64C Keyboard": Keyboard(c64ImageName: "C64C Keyboard",
                                  rows: [ 69, 257, 446, 635, 824, 1012 ],
                                  topHalfLeft: 100,
                                  topHalfRight: 3034,
                                  bottomHalfLeft: 49,
                                  bottomHalfRight: 2984,
                                  functionKeysLeft: 3115,
                                  functionKeysRight: 3415,
                                  spaceLeft: 544,
                                  spaceRight: 2207,
                                  ctrlRight: 330,
                                  restoreLeft: 2778,
                                  returnLeft: 2681,
                                  leftShiftLeft: 283,
                                  leftShiftRight: 559,
                                  rightShiftLeft: 2341,
                                  rightShiftRight: 2681),
        "C64C New Keyboard": Keyboard(c64ImageName: "C64C New Keyboard",
                                  rows: [ 50, 233, 402, 571, 746, 917 ],
                                  topHalfLeft: 97,
                                  topHalfRight: 2853,
                                  bottomHalfLeft: 63,
                                  bottomHalfRight: 2805,
                                  functionKeysLeft: 2952,
                                  functionKeysRight: 3222,
                                  spaceLeft: 540,
                                  spaceRight: 2076,
                                  ctrlRight: 348,
                                  restoreLeft: 2603,
                                  returnLeft: 2469,
                                  leftShiftLeft: 215,
                                  leftShiftRight: 477,
                                  rightShiftLeft: 2215,
                                  rightShiftRight: 2476),
        "Max Keyboard": Keyboard(c64ImageName: "Max Keyboard",
                                  rows: [ 32, 217, 400, 588, 780, 972 ],
                                  topHalfLeft: 39,
                                  topHalfRight: 3058,
                                  bottomHalfLeft: 39,
                                  bottomHalfRight: 3058,
                                  functionKeysLeft: 3116,
                                  functionKeysRight: 3408,
                                  spaceLeft: 506,
                                  spaceRight: 2393,
                                  ctrlRight: 323,
                                  restoreLeft: 2762,
                                  returnLeft: 2671,
                                  leftShiftLeft: 230,
                                  leftShiftRight: 517,
                                  rightShiftLeft: 2390,
                                  rightShiftRight: 2671),
        "PET Style Keyboard": Keyboard(c64ImageName: "PET Style Keyboard",
                                 rows: [ 44, 194, 338, 485, 631, 772 ],
                                 topHalfLeft: 66,
                                 topHalfRight: 2388,
                                 bottomHalfLeft: 37,
                                 bottomHalfRight: 2351,
                                 functionKeysLeft: 2441,
                                 functionKeysRight: 2673,
                                 spaceLeft: 434,
                                 spaceRight: 1744,
                                 ctrlRight: 275,
                                 restoreLeft: 2183,
                                 returnLeft: 2071,
                                 leftShiftLeft: 175,
                                 leftShiftRight: 391,
                                 rightShiftLeft: 1853,
                                 rightShiftRight: 2071),
        "SX64 Keyboard": Keyboard(c64ImageName: "SX64 Keyboard",
                                  rows: [ 69, 269, 469, 669, 869, 1060 ],
                                  topHalfLeft: 90,
                                  topHalfRight: 3229,
                                  bottomHalfLeft: 90,
                                  bottomHalfRight: 3229,
                                  functionKeysLeft: 3313,
                                  functionKeysRight: 3625,
                                  spaceLeft: 763,
                                  spaceRight: 2538,
                                  ctrlRight: 395,
                                  restoreLeft: 2917,
                                  returnLeft: 2837,
                                  leftShiftLeft: 286,
                                  leftShiftRight: 580,
                                  rightShiftLeft: 2543,
                                  rightShiftRight: 2837),
        "VIC-1001 Keyboard": Keyboard(c64ImageName: "PET Style Keyboard Japanese",
                                      poundIsYen: true,
                                      rows: [ 73, 224, 370, 514, 668, 811 ],
                                      topHalfLeft: 84,
                                      topHalfRight: 2463,
                                      bottomHalfLeft: 55,
                                      bottomHalfRight: 2428,
                                      functionKeysLeft: 2535,
                                      functionKeysRight: 2785,
                                      spaceLeft: 468,
                                      spaceRight: 1800,
                                      ctrlRight: 302,
                                      restoreLeft: 2234,
                                      returnLeft: 2123,
                                      leftShiftLeft: 198,
                                      leftShiftRight: 421,
                                      rightShiftLeft: 1898,
                                      rightShiftRight: 2120),
        "VIC-20 Keyboard": Keyboard(c64ImageName: "VIC-20 Keyboard",
                                 rows: [ 69, 257, 446, 635, 824, 1012 ],
                                 topHalfLeft: 100,
                                 topHalfRight: 3034,
                                 bottomHalfLeft: 49,
                                 bottomHalfRight: 2984,
                                 functionKeysLeft: 3115,
                                 functionKeysRight: 3415,
                                 spaceLeft: 544,
                                 spaceRight: 2207,
                                 ctrlRight: 330,
                                 restoreLeft: 2778,
                                 returnLeft: 2681,
                                 leftShiftLeft: 283,
                                 leftShiftRight: 559,
                                 rightShiftLeft: 2341,
                                 rightShiftRight: 2681),
    ]
    
    public static func keyboard(named name: String) -> Keyboard? {
        return keyboards[name]
    }
}