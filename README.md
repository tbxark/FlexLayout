# FlexLayout

`FlexLayout` is a flexible layout tool similar to SwiftUI syntax， `ConstraintLayout` is the syntactic sugar of  `NSLayoutAnchor`.

![demo](./demo.jpeg)


```swift

FL.V(frame: view.bounds) {
    FL.Space.fixed(self.view.safeAreaInsets.top)
    FL.Bind(userInfoContent) { rect in
        FL.H(size: rect.size) {
            FL.Space.fixed(20)
            self.avatarImgv.with(main: .fixed(60), cross: .fixed(60, offset: 0, align: .center))
            FL.Space.fixed(20)
            FL.Virtual { rect in
                FL.V(frame: rect) {
                    self.titleLabel.with(main: .fixed(30))
                    FL.Space.grow()
                    FL.Virtual { rect in
                        FL.H(frame: rect) {
                            self.linkName.with(main: .fixed(40))
                            self.linkLabel.with(main: .grow)
                        }
                    }.with(main: .fixed(20))
                }
            }.with(main: .grow, cross: .fixed(60, offset: 0, align: .center))
            FL.Space.fixed(20)
        }
    }.with(main: .fixed(100), cross: .stretch(margin: (start: 20, end: 20)))
    FL.Space.grow()
    self.bottomBar.with(main: .fixed(60), cross: .stretch(margin: (start: 20, end: 20)))
    FL.Space.fixed(self.view.safeAreaInsets.bottom)
}

CL.layout(clTest) {
    clTest.centerXAnchor |== view.centerXAnchor
    clTest.centerYAnchor |== view.centerYAnchor + 100
    (clTest.heightAnchor & clTest.widthAnchor) |== 100
}
CL.layout(clTest2) {
    clTest2.heightAnchor |== clTest.widthAnchor
    clTest2.widthAnchor |== clTest.widthAnchor * 2 + 100
    clTest2.centerXAnchor |== clTest.centerXAnchor
    clTest2.bottomAnchor |== bottomBar.topAnchor
}


```

## Requirements

- Swift 5.9+
- iOS 13.0+

## Installation

FlexLayout is managed with [Swift Package Manager](https://www.swift.org/package-manager/).

### Xcode

`File` > `Add Package Dependencies...` > enter `https://github.com/tbxark/FlexLayout.git` and add the `FlexLayout` library to your target.

### Package.swift

Versioned releases require a published git tag (`2.0.0` and later):

```swift
dependencies: [
    .package(url: "https://github.com/tbxark/FlexLayout.git", from: "2.0.0")
]
```

Or track the `master` branch directly:

```swift
dependencies: [
    .package(url: "https://github.com/tbxark/FlexLayout.git", branch: "master")
]
```

## Development

The Example app lives in `Example/FlexLayoutExample.xcodeproj` and depends on the local Swift package. Run the tests with:

```sh
xcodebuild test -scheme FlexLayout -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Author

tbxark, tbxark@outlook.com

## License

FlexLayout is available under the MIT license. See the LICENSE file for more info.
