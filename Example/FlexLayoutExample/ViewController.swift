//
//  ViewController.swift
//  FlexLayoutExample
//
//  Created by tbxark on 06/04/2020.
//  Copyright (c) 2020 tbxark. All rights reserved.
//

import UIKit
import FlexLayout

class ViewController: UIViewController {

    let userInfoContent = UIView()
    let avatarImgv = UIImageView()
    let titleLabel = UILabel()
    let linkName = UILabel()
    let linkLabel = UILabel()
    let bottomBar = UIView()
    let clTest = UIView()
    let clTest2 = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        userInfoContent.backgroundColor = .secondarySystemBackground

        avatarImgv.backgroundColor = .darkGray
        avatarImgv.layer.cornerRadius = 30
        avatarImgv.layer.masksToBounds = true

        titleLabel.text = "TBXark"
        titleLabel.textColor = .label

        linkName.text = "Github"
        linkName.textColor = .label
        linkName.font = .systemFont(ofSize: 10)

        linkLabel.text = "https://github.com/tbxark"
        linkLabel.textColor = .link
        linkLabel.font = .systemFont(ofSize: 10)

        bottomBar.backgroundColor = .label
        bottomBar.layer.cornerRadius = 30
        bottomBar.layer.masksToBounds = true

        clTest.backgroundColor = .systemYellow
        clTest2.backgroundColor = .systemRed

        userInfoContent.addSubview(avatarImgv)
        userInfoContent.addSubview(titleLabel)
        userInfoContent.addSubview(linkName)
        userInfoContent.addSubview(linkLabel)
        view.addSubview(userInfoContent)
        view.addSubview(bottomBar)
        view.addSubview(clTest)
        view.addSubview(clTest2)

        reloadFlexLayout()

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
    }

    private func reloadFlexLayout() {
        FL.V(frame: view.bounds) {
            FL.Space.fixed(view.safeAreaInsets.top)
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
            FL.Space.fixed(view.safeAreaInsets.bottom)
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        reloadFlexLayout()
    }
}
