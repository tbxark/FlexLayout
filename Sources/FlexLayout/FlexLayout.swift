//
//  FlexLayout.swift
//  FlexLayout
//
//  Created by tbxark on 06/04/2020.
//  Copyright (c) 2020 tbxark. All rights reserved.
//

import UIKit

public typealias FL = FlexLayout

// MARK: - FlexLayoutViewType
public protocol FlexLayoutViewType: AnyObject {
    var frame: CGRect { get set }
}

extension UIView: FlexLayoutViewType {}

extension FlexLayoutViewType {
    public func with(main: FlexLayout.Size, cross: FlexLayout.Cross = .grow) -> FlexLayout {
        return FlexLayout(view: self, main: main, cross: cross)
    }
}


protocol FlexLayoutBuilderContainer: FlexLayoutViewType {
    var builder: (CGRect) -> Void {get }
}

public protocol _FlexLayout {
    func flatten() -> [FlexLayout]
}

extension Array: _FlexLayout where Element: _FlexLayout {
    public func flatten() -> [FlexLayout] {
        return self.flatMap({ $0.flatten() })
    }
}

// MARK: - FlexLayout
@resultBuilder
public struct FlexLayout: _FlexLayout {
       
    public var view: FlexLayoutViewType
    public var main: Size
    public var cross: Cross
    
    public func flatten() -> [FlexLayout] {
        return [self]
    }
    
    public static func buildBlock(_ components: _FlexLayout...) -> [FlexLayout] {
        return components.flatMap({ $0.flatten() })
    }

    public static func buildIf(_ content: _FlexLayout?) -> _FlexLayout {
        return content ?? [FlexLayout]()
    }

    public static func buildEither(first: _FlexLayout) -> _FlexLayout {
        return first
    }

    public static func buildEither(second: _FlexLayout) -> _FlexLayout {
        return second
    }
}

extension FlexLayout {
    public typealias Insets = (start: CGFloat, end: CGFloat)

    public enum Size {
        public static let grow = Size.stretch(1)
        case fixed(CGFloat)
        case stretch(CGFloat)
    }
    
    public enum Align {
        case start
        case center
        case end
    }
    
    public enum Direction {
        case vertical
        case horizontal
    }
    
    public enum Cross {
        public static let grow = Cross.stretch(margin: (start: 0, end: 0))
        public static func start(_ value: CGFloat) -> Cross {
            return .fixed(value, offset: 0, align: .start)
        }
        public static func center(_ value: CGFloat) -> Cross {
            return .fixed(value, offset: 0, align: .center)
        }
        public static func end(_ value: CGFloat) -> Cross {
            return .fixed(value, offset: 0, align: .end)
        }
        
        /// - Parameters:
        ///   - value: size on the cross axis
        ///   - offset: inset from the aligned edge, a positive value moves the view inward
        case fixed(CGFloat, offset: CGFloat, align: Align)
        case stretch(margin: (start: CGFloat, end: CGFloat))
    }
    
}

extension FlexLayout {
    public class Space: FlexLayoutViewType {
        public var frame: CGRect = .zero
        public init() {
        }
        
        public static func fixed(_ value: CGFloat) -> FlexLayout {
            return Space().with(main: .fixed(value))
        }
        
        public static func grow() -> FlexLayout {
            return Space().with(main: .grow)
        }
        
        public static func stretch(_ value: CGFloat) -> FlexLayout {
            return Space().with(main: .stretch(value))
        }
    }
    
    public class Virtual: FlexLayoutBuilderContainer {
        public var frame: CGRect = .zero
        public var builder: (CGRect) -> Void
        
        public init(_ builder: @escaping (CGRect) -> Void) {
            self.builder = builder
        }
    }
    
    public class Bind: FlexLayoutBuilderContainer {
        public var view: FlexLayoutViewType
        public var builder: (CGRect) -> Void
        
        public var frame: CGRect {
            get {
                return view.frame
            }
            set {
                view.frame = newValue
            }
        }
        
        
        public init(_ view: FlexLayoutViewType, _ builder: @escaping (CGRect) -> Void) {
            self.view = view
            self.builder = builder
        }
    }
}


extension FlexLayout {
    public enum FlexLayoutError: String, Error {
        case valueIsNaN
        case valueIsInfinite
    }
    

    private static func checkCGFloatIsValid(_ value: CGFloat) throws -> CGFloat {
        if value.isNaN {
            throw FlexLayoutError.valueIsNaN
        } else if value.isInfinite {
            throw FlexLayoutError.valueIsInfinite
        }
        return value
    }
    
    
    private static func layoutMainAxis(layouts: [FlexLayout], direction: FlexLayout.Direction, align: FlexLayout.Align, start: CGFloat, end: CGFloat) throws {
        var totalSize = CGFloat.zero
        var totalGrow = CGFloat.zero
        
        for l in layouts {
            switch l.main {
            case .fixed(let value):
                totalSize += value
            case .stretch(let scale):
                totalGrow += scale
            }
        }
        let growValue = totalGrow.isZero ? 0 :  try checkCGFloatIsValid(max((end - start - totalSize) / totalGrow, 0))
        var startPosition = start
        
        if totalGrow.isZero {
            switch align {
            case .start:
                startPosition = start
            case .center:
                startPosition = start + (end - start - totalSize) / 2
            case .end:
                startPosition = end - totalSize
            }
        }
        
        switch direction {
        case .horizontal:
            for l in layouts {
                switch l.main {
                case .stretch(let scale):
                    l.view.frame.origin.x = startPosition
                    l.view.frame.size.width = try checkCGFloatIsValid(scale * growValue)
                    startPosition = l.view.frame.maxX
                case .fixed(let value):
                    l.view.frame.origin.x = startPosition
                    l.view.frame.size.width = try checkCGFloatIsValid(value)
                    startPosition = l.view.frame.maxX
                }
            }
        case .vertical:
            for l in layouts {
                switch l.main {
                case .stretch(let scale):
                    l.view.frame.origin.y = startPosition
                    l.view.frame.size.height = try checkCGFloatIsValid(scale * growValue)
                    startPosition = l.view.frame.maxY
                case .fixed(let value):
                    l.view.frame.origin.y = startPosition
                    l.view.frame.size.height = try checkCGFloatIsValid(value)
                    startPosition = l.view.frame.maxY
                }
            }
            
        }
    }
    
     private static func layoutCrossAxis(layouts: [FlexLayout], direction: FlexLayout.Direction,  start: CGFloat, end: CGFloat) throws {
        switch direction {
        case .horizontal:
            for l in layouts {
                switch l.cross {
                case .fixed(let value, let offset, let align):
                    l.view.frame.size.height = try checkCGFloatIsValid(value)
                    switch align {
                    case .start:
                        l.view.frame.origin.y = start + offset
                    case .center:
                        l.view.frame.origin.y = start + ((end - start) - value) / 2 + offset
                    case .end:
                        l.view.frame.origin.y = end - value - offset
                    }
                case .stretch(let margin):
                    l.view.frame.size.height = try checkCGFloatIsValid(max(end - start - margin.start - margin.end, 0))
                    l.view.frame.origin.y = start + margin.start
                }
            }
        case .vertical:
            for l in layouts {
                switch l.cross {
                case .fixed(let value, let offset, let align):
                    l.view.frame.size.width = try checkCGFloatIsValid(value)
                    switch align {
                    case .start:
                        l.view.frame.origin.x = start + offset
                    case .center:
                        l.view.frame.origin.x = start + ((end - start) - value) / 2 + offset
                    case .end:
                        l.view.frame.origin.x = end - value - offset
                    }
                case .stretch(let margin):
                    l.view.frame.size.width = try checkCGFloatIsValid(max(end - start - margin.start - margin.end, 0))
                    l.view.frame.origin.x = start + margin.start
                }
            }
        }
    }

    /// Layout stack
    /// - Parameters:
    ///   - direction: Main axis direction
    ///   - align: Main axis align
    ///   - ms: Main axis start value
    ///   - me: Main axis end value
    ///   - cs: Cross axis start value
    ///   - ce: Cross axis end value
    ///   - builder: builder
    public static func layout(_ direction: FlexLayout.Direction, align: FlexLayout.Align = .start, ms: CGFloat = 0, me: CGFloat, cs: CGFloat = 0, ce: CGFloat, @FlexLayout _ builder: () -> [FlexLayout]) throws {
        try checkCGFloatIsValid(ms)
        try checkCGFloatIsValid(me)
        try checkCGFloatIsValid(cs)
        try checkCGFloatIsValid(ce)
        let layout = builder().flatMap({ $0.flatten() })
        try FlexLayout.layoutMainAxis(layouts: layout, direction: direction, align: align, start: ms, end: me)
        try FlexLayout.layoutCrossAxis(layouts: layout, direction: direction, start: cs, end: ce)
        for l in layout {
            if let v = l.view as? FlexLayoutBuilderContainer {
                v.builder(v.frame)
            }
        }
    }
}



extension FlexLayout {
    
    @discardableResult public static func H(_ align: FlexLayout.Align = .start,  frame: CGRect, @FlexLayout _ builder: () -> [FlexLayout]) -> Error? {
        return layout(.horizontal, align: align, frame: frame, builder)
    }
    
    @discardableResult public static func H(_ align: FlexLayout.Align = .start,  size: CGSize, @FlexLayout _ builder: () -> [FlexLayout]) -> Error?  {
        return layout(.horizontal, align: align, size: size, builder)
    }
    
    @discardableResult public static func V(_ align: FlexLayout.Align = .start,  frame: CGRect, @FlexLayout _ builder: () -> [FlexLayout]) -> Error? {
        return layout(.vertical, align: align, frame: frame, builder)
    }
    
    @discardableResult public static func V(_ align: FlexLayout.Align = .start,  size: CGSize, @FlexLayout _ builder: () -> [FlexLayout]) -> Error? {
        return layout(.vertical, align: align, size: size, builder)
    }
        
    @discardableResult public static func layout(_ direction: FlexLayout.Direction, align: FlexLayout.Align = .start, size: CGSize, @FlexLayout _ builder: () -> [FlexLayout]) -> Error? {
        return layout(direction, align: align, frame: CGRect(origin: CGPoint.zero, size: size), builder)
    }
    
    @discardableResult public static func layout(_ direction: FlexLayout.Direction, align: FlexLayout.Align = .start, frame: CGRect, @FlexLayout _ builder: () -> [FlexLayout]) -> Error? {
        var result: Error?
        do {
            switch direction {
            case .horizontal:
                try layout(direction, align: align, ms: frame.minX, me: frame.maxX, cs: frame.minY, ce: frame.maxY, builder)
            case .vertical:
                try layout(direction, align: align, ms: frame.minY, me: frame.maxY, cs: frame.minX, ce: frame.maxX, builder)
            }
        } catch {
            result = error
        }
        return result
    }
}
