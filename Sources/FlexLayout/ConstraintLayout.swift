//
//  ConstraintLayout.swift
//  FlexLayout
//
//  Created by tbxark on 01/22/2021.
//  Copyright (c) 2021 tbxark. All rights reserved.
//

import UIKit

infix operator |== : ComparisonPrecedence
infix operator |>= : ComparisonPrecedence
infix operator |<= : ComparisonPrecedence

public typealias CL = ConstraintLayout

public protocol ConstraintLayoutValue {
    func flatten() -> [NSLayoutConstraint]
}


extension NSLayoutConstraint: ConstraintLayoutValue {
    public func flatten() -> [NSLayoutConstraint] {
        return [self]
    }
}

extension Array: ConstraintLayoutValue where Element: ConstraintLayoutValue {
    public func flatten() -> [NSLayoutConstraint] {
        return self.flatMap({ $0.flatten() })
    }
}

extension UIView {
    public var sizeAnchor: [NSLayoutDimension] {
        return [widthAnchor, heightAnchor]
    }
}

@resultBuilder
public struct ConstraintLayout {
    
    public static func buildBlock(_ components: ConstraintLayoutValue...) -> [NSLayoutConstraint] {
        return components.flatMap({ $0.flatten() })
    }

    public static func buildIf(_ content: ConstraintLayoutValue?) -> ConstraintLayoutValue {
        return content ?? [NSLayoutConstraint]()
    }

    public static func buildEither(first: ConstraintLayoutValue) -> ConstraintLayoutValue {
        return first
    }

    public static func buildEither(second: ConstraintLayoutValue) -> ConstraintLayoutValue {
        return second
    }
}

extension ConstraintLayout {
    public static func layout(_ view: UIView, @ConstraintLayout _ builder: () -> [NSLayoutConstraint]) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(builder())
    }
    public static func layout(@ConstraintLayout _ builder: () -> [NSLayoutConstraint]) {
        NSLayoutConstraint.activate(builder())
    }
}

public func & <Layout, Anchor>(lhs: Layout, rhs: Layout) -> [Layout] where Layout: NSLayoutAnchor<Anchor>, Anchor: AnyObject {
    return [lhs, rhs]
}

public func & <Layout, Anchor>(lhs: [Layout], rhs: Layout) -> [Layout] where Layout: NSLayoutAnchor<Anchor>, Anchor: AnyObject {
    return [lhs, [rhs]].flatMap({ $0 })
}

public func & <Layout, Anchor>(lhs: Layout, rhs: [Layout]) -> [Layout] where Layout: NSLayoutAnchor<Anchor>, Anchor: AnyObject {
    return [[lhs], rhs].flatMap({ $0 })
}

public func & <Layout, Anchor>(lhs: [Layout], rhs: [Layout]) -> [Layout] where Layout: NSLayoutAnchor<Anchor>, Anchor: AnyObject {
    return [lhs, rhs].flatMap({ $0 })
}

// MARK: - NSLayoutDimension
public func |== (lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    return lhs.constraint(equalToConstant: rhs)
}

public func |>= (lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    return lhs.constraint(greaterThanOrEqualToConstant: rhs)
}

public func |<= (lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    return lhs.constraint(lessThanOrEqualToConstant: rhs)
}

public func |== (lhs: [NSLayoutDimension], rhs: CGFloat) -> ConstraintLayoutValue {
    return lhs.map { $0.constraint(equalToConstant: rhs) }
}

public func |>= (lhs: [NSLayoutDimension], rhs: CGFloat) -> ConstraintLayoutValue {
    return lhs.map { $0.constraint(greaterThanOrEqualToConstant: rhs) }
}

public func |<= (lhs: [NSLayoutDimension], rhs: CGFloat) -> ConstraintLayoutValue {
    return lhs.map { $0.constraint(lessThanOrEqualToConstant: rhs) }
}

// MARK: - NSLayoutAnchor
public func |== <Anchor>(lhs: NSLayoutAnchor<Anchor>, rhs: NSLayoutAnchor<Anchor>) -> NSLayoutConstraint where Anchor: AnyObject {
    return lhs.constraint(equalTo: rhs)
}

public func |>= <Anchor>(lhs: NSLayoutAnchor<Anchor>, rhs: NSLayoutAnchor<Anchor>) -> NSLayoutConstraint where Anchor: AnyObject {
    return lhs.constraint(greaterThanOrEqualTo: rhs)
}

public func |<= <Anchor>(lhs: NSLayoutAnchor<Anchor>, rhs: NSLayoutAnchor<Anchor>) -> NSLayoutConstraint where Anchor: AnyObject {
    return lhs.constraint(lessThanOrEqualTo: rhs)
}

public func |== <Anchor>(lhs: [NSLayoutAnchor<Anchor>], rhs: NSLayoutAnchor<Anchor>) -> ConstraintLayoutValue where Anchor: AnyObject {
    return lhs.map { $0.constraint(equalTo: rhs) }
}

public func |>= <Anchor>(lhs: [NSLayoutAnchor<Anchor>], rhs: NSLayoutAnchor<Anchor>) -> ConstraintLayoutValue where Anchor: AnyObject {
    return lhs.map { $0.constraint(greaterThanOrEqualTo: rhs) }
}

public func |<= <Anchor>(lhs: [NSLayoutAnchor<Anchor>], rhs: NSLayoutAnchor<Anchor>) -> ConstraintLayoutValue where Anchor: AnyObject {
    return lhs.map { $0.constraint(lessThanOrEqualTo: rhs) }
}

// MARK: - NSLayoutAnchorWithConst
public typealias NSLayoutAnchorWithConst<Anchor: AnyObject> = (anchor: NSLayoutAnchor<Anchor>, constant: CGFloat)

public func + <Anchor>(lhs: NSLayoutAnchor<Anchor>, constant: CGFloat) -> NSLayoutAnchorWithConst<Anchor> where Anchor: AnyObject {
    return (anchor: lhs, constant: constant)
}

public func - <Anchor>(lhs: NSLayoutAnchor<Anchor>, constant: CGFloat) -> NSLayoutAnchorWithConst<Anchor> where Anchor: AnyObject {
    return (anchor: lhs, constant: -constant)
}

public func |== <Anchor>(lhs: NSLayoutAnchor<Anchor>, rhs: NSLayoutAnchorWithConst<Anchor>) -> NSLayoutConstraint where Anchor: AnyObject {
    return lhs.constraint(equalTo: rhs.anchor, constant: rhs.constant)
}

public func |>= <Anchor>(lhs: NSLayoutAnchor<Anchor>, rhs: NSLayoutAnchorWithConst<Anchor>) -> NSLayoutConstraint where Anchor: AnyObject {
    return lhs.constraint(greaterThanOrEqualTo: rhs.anchor, constant: rhs.constant)
}

public func |<= <Anchor>(lhs: NSLayoutAnchor<Anchor>, rhs: NSLayoutAnchorWithConst<Anchor>) -> NSLayoutConstraint where Anchor: AnyObject {
    return lhs.constraint(lessThanOrEqualTo: rhs.anchor, constant: rhs.constant)
}

public func |== <Anchor>(lhs: [NSLayoutAnchor<Anchor>], rhs: NSLayoutAnchorWithConst<Anchor>) -> ConstraintLayoutValue where Anchor: AnyObject {
    return lhs.map { $0.constraint(equalTo: rhs.anchor, constant: rhs.constant) }
}

public func |>= <Anchor>(lhs: [NSLayoutAnchor<Anchor>], rhs: NSLayoutAnchorWithConst<Anchor>) -> ConstraintLayoutValue where Anchor: AnyObject {
    return lhs.map { $0.constraint(greaterThanOrEqualTo: rhs.anchor, constant: rhs.constant) }
}

public func |<= <Anchor>(lhs: [NSLayoutAnchor<Anchor>], rhs: NSLayoutAnchorWithConst<Anchor>) -> ConstraintLayoutValue where Anchor: AnyObject {
    return lhs.map { $0.constraint(lessThanOrEqualTo: rhs.anchor, constant: rhs.constant) }
}

// MARK: - NSLayoutAnchorWithMultiplier
public typealias NSLayoutAnchorWithMultiplier = (anchor: NSLayoutDimension, multiplier: CGFloat, constant: CGFloat)

public func * (lhs: NSLayoutDimension, multiplier: CGFloat) -> NSLayoutAnchorWithMultiplier {
    return (anchor: lhs, multiplier: multiplier, constant: 0)
}

public func + (lhs: NSLayoutAnchorWithMultiplier, value: CGFloat) -> NSLayoutAnchorWithMultiplier {
    return (anchor: lhs.anchor, multiplier: lhs.multiplier, constant: lhs.constant + value)
}

public func |== (lhs: NSLayoutDimension, rhs: NSLayoutAnchorWithMultiplier) -> NSLayoutConstraint {
    return lhs.constraint(equalTo: rhs.anchor, multiplier: rhs.multiplier, constant: rhs.constant)
}

public func |>= (lhs: NSLayoutDimension, rhs: NSLayoutAnchorWithMultiplier) -> NSLayoutConstraint {
    return lhs.constraint(greaterThanOrEqualTo: rhs.anchor, multiplier: rhs.multiplier, constant: rhs.constant)
}

public func |<= (lhs: NSLayoutDimension, rhs: NSLayoutAnchorWithMultiplier) -> NSLayoutConstraint {
    return lhs.constraint(lessThanOrEqualTo: rhs.anchor, multiplier: rhs.multiplier, constant: rhs.constant)
}

public func |== (lhs: [NSLayoutDimension], rhs: NSLayoutAnchorWithMultiplier) -> ConstraintLayoutValue {
    return lhs.map { $0.constraint(equalTo: rhs.anchor, multiplier: rhs.multiplier, constant: rhs.constant) }
}

public func |>= (lhs: [NSLayoutDimension], rhs: NSLayoutAnchorWithMultiplier) -> ConstraintLayoutValue {
    return lhs.map { $0.constraint(greaterThanOrEqualTo: rhs.anchor, multiplier: rhs.multiplier, constant: rhs.constant) }
}

public func |<= (lhs: [NSLayoutDimension], rhs: NSLayoutAnchorWithMultiplier) -> ConstraintLayoutValue {
    return lhs.map { $0.constraint(lessThanOrEqualTo: rhs.anchor, multiplier: rhs.multiplier, constant: rhs.constant) }
}
