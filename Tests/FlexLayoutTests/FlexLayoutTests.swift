import XCTest
import UIKit
import FlexLayout

final class FlexLayoutTests: XCTestCase {

    // MARK: - Main axis

    func testHorizontalFixedLayout() {
        let first = UIView()
        let second = UIView()
        let error = FL.H(size: CGSize(width: 100, height: 50)) {
            first.with(main: .fixed(40))
            FL.Space.fixed(10)
            second.with(main: .fixed(30))
        }
        XCTAssertNil(error)
        XCTAssertEqual(first.frame, CGRect(x: 0, y: 0, width: 40, height: 50))
        XCTAssertEqual(second.frame, CGRect(x: 50, y: 0, width: 30, height: 50))
    }

    func testMainAxisGrowDistribution() {
        let first = UIView()
        let second = UIView()
        FL.H(size: CGSize(width: 100, height: 50)) {
            first.with(main: .fixed(20))
            second.with(main: .grow)
        }
        XCTAssertEqual(first.frame, CGRect(x: 0, y: 0, width: 20, height: 50))
        XCTAssertEqual(second.frame, CGRect(x: 20, y: 0, width: 80, height: 50))
    }

    func testMainAxisStretchScale() {
        let first = UIView()
        let second = UIView()
        FL.H(size: CGSize(width: 100, height: 50)) {
            first.with(main: .fixed(20))
            second.with(main: .stretch(2))
        }
        XCTAssertEqual(second.frame.width, 80, accuracy: 0.001)
    }

    func testMainAxisAlignStartCenterEnd() {
        // main-axis align is only applied when there is no stretchable space,
        // so align each case in its own container.
        let started = UIView()
        FL.H(.start, size: CGSize(width: 100, height: 50)) {
            started.with(main: .fixed(40))
        }
        XCTAssertEqual(started.frame.minX, 0)

        let centered = UIView()
        FL.H(.center, size: CGSize(width: 100, height: 50)) {
            centered.with(main: .fixed(40))
        }
        XCTAssertEqual(centered.frame.minX, 30)

        let ended = UIView()
        FL.H(.end, size: CGSize(width: 100, height: 50)) {
            ended.with(main: .fixed(40))
        }
        XCTAssertEqual(ended.frame.minX, 60)

        let verticalCenter = UIView()
        FL.V(.center, size: CGSize(width: 50, height: 100)) {
            verticalCenter.with(main: .fixed(40))
        }
        XCTAssertEqual(verticalCenter.frame.minY, 30)
    }

    func testVerticalLayout() {
        let first = UIView()
        let second = UIView()
        FL.V(size: CGSize(width: 100, height: 90)) {
            first.with(main: .fixed(30), cross: .stretch(margin: (start: 10, end: 20)))
            second.with(main: .grow)
        }
        XCTAssertEqual(first.frame, CGRect(x: 10, y: 0, width: 70, height: 30))
        XCTAssertEqual(second.frame, CGRect(x: 0, y: 30, width: 100, height: 60))
    }

    // MARK: - Cross axis

    func testCrossAxisFixedAlignStartCenterEnd() {
        let startView = UIView()
        let centerView = UIView()
        let endView = UIView()
        FL.H(size: CGSize(width: 100, height: 60)) {
            startView.with(main: .grow, cross: .fixed(20, offset: 5, align: .start))
            centerView.with(main: .grow, cross: .fixed(20, offset: 10, align: .center))
            endView.with(main: .grow, cross: .fixed(20, offset: 5, align: .end))
        }
        XCTAssertEqual(startView.frame.minY, 5, accuracy: 0.001)
        XCTAssertEqual(startView.frame.maxY, 25, accuracy: 0.001)
        // centered, then inset 10pt from the center line
        XCTAssertEqual(centerView.frame.minY, 30, accuracy: 0.001)
        XCTAssertEqual(centerView.frame.maxY, 50, accuracy: 0.001)
        XCTAssertEqual(endView.frame.minY, 35, accuracy: 0.001)
        XCTAssertEqual(endView.frame.maxY, 55, accuracy: 0.001)
    }

    func testCrossAxisCenterWithoutOffset() {
        let view = UIView()
        FL.H(size: CGSize(width: 100, height: 60)) {
            view.with(main: .grow, cross: .center(20))
        }
        XCTAssertEqual(view.frame.minY, 20, accuracy: 0.001)
    }

    func testCrossAxisStretchMargin() {
        let view = UIView()
        FL.H(size: CGSize(width: 100, height: 60)) {
            view.with(main: .grow, cross: .stretch(margin: (start: 10, end: 15)))
        }
        XCTAssertEqual(view.frame.origin.y, 10, accuracy: 0.001)
        XCTAssertEqual(view.frame.height, 35, accuracy: 0.001)
    }

    // MARK: - Containers

    func testNestedVirtualAndBind() {
        let container = UIView()
        let bound = UIView()
        var virtualRect: CGRect?
        var bindRect: CGRect?

        FL.V(size: CGSize(width: 100, height: 100)) {
            FL.Bind(bound) { rect in
                bindRect = rect
                FL.H(frame: rect) {
                    bound.with(main: .fixed(50))
                }
            }.with(main: .fixed(40))
            FL.Virtual { rect in
                virtualRect = rect
                FL.V(frame: rect) {
                    container.with(main: .grow)
                }
            }.with(main: .grow, cross: .stretch(margin: (start: 10, end: 10)))
        }

        XCTAssertEqual(bindRect, CGRect(x: 0, y: 0, width: 100, height: 40))
        XCTAssertEqual(bound.frame, CGRect(x: 0, y: 0, width: 50, height: 40))
        XCTAssertEqual(virtualRect, CGRect(x: 10, y: 40, width: 80, height: 60))
        XCTAssertEqual(container.frame, CGRect(x: 10, y: 40, width: 80, height: 60))
    }

    func testBuildIfAndEither() {
        let included = UIView()
        let excluded = UIView()
        let flag = true
        FL.H(size: CGSize(width: 100, height: 50)) {
            if flag {
                included.with(main: .grow)
            } else {
                excluded.with(main: .grow)
            }
            if !flag {
                excluded.with(main: .grow)
            }
        }
        XCTAssertEqual(included.frame.width, 100, accuracy: 0.001)
        XCTAssertEqual(excluded.frame, .zero)
    }

    // MARK: - Errors

    func testNaNValueReturnsError() {
        let view = UIView()
        let error = FL.H(size: CGSize(width: 100, height: 50)) {
            view.with(main: .fixed(CGFloat.nan))
        }
        XCTAssertEqual(error as? FlexLayout.FlexLayoutError, .valueIsNaN)
    }

    func testInfiniteValueReturnsError() {
        let view = UIView()
        let error = FL.V(size: CGSize(width: 100, height: 50)) {
            view.with(main: .fixed(.infinity))
        }
        XCTAssertEqual(error as? FlexLayout.FlexLayoutError, .valueIsInfinite)
    }

    func testInvalidBoundsReturnError() {
        let view = UIView()
        XCTAssertThrowsError(try FL.layout(.horizontal, ms: 0, me: .nan, cs: 0, ce: 50) {
            view.with(main: .fixed(10))
        }) { error in
            XCTAssertEqual(error as? FlexLayout.FlexLayoutError, .valueIsNaN)
        }
        XCTAssertThrowsError(try FL.layout(.vertical, ms: 0, me: 100, cs: 0, ce: .infinity) {
            view.with(main: .fixed(10))
        }) { error in
            XCTAssertEqual(error as? FlexLayout.FlexLayoutError, .valueIsInfinite)
        }
        XCTAssertFalse(view.frame.size.width.isNaN)
        XCTAssertFalse(view.frame.size.height.isNaN)
    }

    // MARK: - Overflow

    func testOverflowClampsStretchToZero() {
        let first = UIView()
        let second = UIView()
        FL.H(size: CGSize(width: 50, height: 50)) {
            first.with(main: .fixed(60))
            second.with(main: .grow)
        }
        XCTAssertEqual(first.frame.width, 60, accuracy: 0.001)
        XCTAssertEqual(second.frame.width, 0, accuracy: 0.001)
    }

    func testCrossOverflowClampsStretchToZero() {
        let view = UIView()
        FL.H(size: CGSize(width: 100, height: 20)) {
            view.with(main: .grow, cross: .stretch(margin: (start: 15, end: 15)))
        }
        XCTAssertEqual(view.frame.height, 0, accuracy: 0.001)
        XCTAssertEqual(view.frame.origin.y, 15, accuracy: 0.001)
    }
}
