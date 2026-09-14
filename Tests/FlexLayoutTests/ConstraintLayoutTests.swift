import XCTest
import UIKit
import FlexLayout

final class ConstraintLayoutTests: XCTestCase {

    func testLayoutActivatesConstraintsAndDisablesAutoresizingMask() {
        let root = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        let child = UIView()
        root.addSubview(child)
        CL.layout(child) {
            child.centerXAnchor |== root.centerXAnchor
            child.centerYAnchor |== root.centerYAnchor
            (child.widthAnchor & child.heightAnchor) |== 100
        }
        XCTAssertFalse(child.translatesAutoresizingMaskIntoConstraints)
        XCTAssertEqual(child.constraints.count, 2)
        root.layoutIfNeeded()
        XCTAssertEqual(child.frame.minX, 50, accuracy: 0.001)
        XCTAssertEqual(child.frame.minY, 50, accuracy: 0.001)
        XCTAssertEqual(child.frame.width, 100, accuracy: 0.001)
        XCTAssertEqual(child.frame.height, 100, accuracy: 0.001)
    }

    func testAnchorWithConstant() {
        let root = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let leadingView = UIView()
        let trailingView = UIView()
        root.addSubview(leadingView)
        root.addSubview(trailingView)
        CL.layout(leadingView) {
            leadingView.leadingAnchor |== root.leadingAnchor + 10
        }
        CL.layout(trailingView) {
            trailingView.trailingAnchor |== root.trailingAnchor - 20
        }
        root.layoutIfNeeded()
        XCTAssertEqual(leadingView.frame.minX, 10, accuracy: 0.001)
        XCTAssertEqual(trailingView.frame.maxX, 80, accuracy: 0.001)
    }

    func testMultiplierConstraint() {
        let root = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        let child = UIView()
        root.addSubview(child)
        CL.layout(child) {
            child.topAnchor |== root.topAnchor
            child.leadingAnchor |== root.leadingAnchor
            child.widthAnchor |== root.widthAnchor * 0.5
            child.heightAnchor |== root.heightAnchor * 0.5 + 10
        }
        root.layoutIfNeeded()
        XCTAssertEqual(child.frame.width, 100, accuracy: 0.001)
        XCTAssertEqual(child.frame.height, 60, accuracy: 0.001)
    }

    func testSizeAnchorArray() {
        let root = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let child = UIView()
        root.addSubview(child)
        CL.layout(child) {
            child.sizeAnchor |>= 50
            child.centerXAnchor |== root.centerXAnchor
            child.centerYAnchor |== root.centerYAnchor
        }
        XCTAssertEqual(child.constraints.count, 2)
    }

    func testInequalities() {
        let view = UIView()
        let greater = view.widthAnchor |>= 10
        let less = view.heightAnchor |<= 20
        XCTAssertEqual(greater.relation, .greaterThanOrEqual)
        XCTAssertEqual(greater.constant, 10)
        XCTAssertEqual(less.relation, .lessThanOrEqual)
        XCTAssertEqual(less.constant, 20)
    }
}
