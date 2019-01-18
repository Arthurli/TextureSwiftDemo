//
//  AnimationDemoController.swift
//  TextureSwiftDemo
//
//  Created by 李晨 on 2019/1/17.
//  Copyright © 2019 李晨. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class AnimationDemoController: UIViewController {

    var node = TransitionNode()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubnode(node)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let size = self.node.layoutThatFits(ASSizeRange(min: CGSize.zero, max: self.view.frame.size)).size
        self.node.frame = CGRect(origin: CGPoint(x: 0, y: 100), size: size)
    }
}

class TransitionNode: ASDisplayNode {
    var text1 = ASTextNode()
    var text2 = ASTextNode()

    var bt1 = ASButtonNode()
    var bt2 = ASButtonNode()

    var left: Bool = false // 是否优先左边显示
    var height: Bool = false // 是否限制显示高度

    override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
        self.defaultLayoutTransitionDuration = 1
        self.backgroundColor = UIColor.red

        text1.attributedText = NSAttributedString(string: "In some cases, you can substantially improve your app’s performance by using layers instead of views. We recommend enabling layer-backing in any custom node that doesn’t need touch handling. With UIKit, manually converting view-based code to layers is laborious due to the difference in APIs. Worse, if at some point you need to enable touch handling or other view-specific functionality, you have to manually convert everything back (and risk regressions!).")
        text1.backgroundColor = UIColor.white

        text2.attributedText = NSAttributedString(string: "In some cases, you can substantially improve your app’s performance by using layers instead of views. We recommend enabling layer-backing in any custom node that doesn’t need touch handling. With UIKit, manually converting view-based code to layers is laborious due to the difference in APIs. Worse, if at some point you need to enable touch handling or other view-specific functionality, you have to manually convert everything back (and risk regressions!).")
        text2.backgroundColor = UIColor.blue

        bt1.setTitle("height", with: nil, with: nil, for: .normal)
        bt1.backgroundColor = UIColor.yellow
        bt2.setTitle("left", with: nil, with: nil, for: .normal)
        bt2.backgroundColor = UIColor.gray

        bt1.addTarget(self, action: #selector(clickBtn1), forControlEvents: .touchUpInside)
        bt2.addTarget(self, action: #selector(clickBtn2), forControlEvents: .touchUpInside)

        bt1.style.flexGrow = 1
        bt2.style.flexGrow = 1
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        self.text1.maximumNumberOfLines = self.height ? 2 : 1000
        self.text2.maximumNumberOfLines = self.height ? 2 : 1000

        self.text1.style.flexShrink = self.left ? 3 : 1
        self.text2.style.flexShrink = self.left ? 1 : 3
        self.text1.style.maxSize = CGSize(width: UIScreen.main.bounds.width / 3 * 2, height: 1000)
        self.text2.style.maxSize = CGSize(width: UIScreen.main.bounds.width / 3 * 2, height: 1000)

        let stack1 = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: .start, children: [self.text1, self.text2])

        stack1.style.maxSize = CGSize(width: UIScreen.main.bounds.width, height: 1000)

        let stack2 = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: .start, children: [self.bt1, self.bt2])
        stack2.style.flexShrink = 2
        return ASStackLayoutSpec(direction: .vertical, spacing: 10, justifyContent: .start, alignItems: .start, children: [stack1, stack2])
    }

    @objc
    func clickBtn1() {
        self.height = !self.height

//        self.setNeedsLayout()
        self.transitionLayout(withAnimation: true, shouldMeasureAsync: false, measurementCompletion: nil)
    }

    @objc
    func clickBtn2() {
        self.left = !self.left
//        self.setNeedsLayout()
        self.transitionLayout(withAnimation: true, shouldMeasureAsync: false, measurementCompletion: nil)
    }

    override func animateLayoutTransition(_ context: ASContextTransitioning) {
        UIView.animate(withDuration: 0.5, animations: {
            self.text1.frame = context.finalFrame(for: self.text1)
            self.text2.frame = context.finalFrame(for: self.text2)
        }) { (finish) in
            context.completeTransition(finish)
        }
    }
}
