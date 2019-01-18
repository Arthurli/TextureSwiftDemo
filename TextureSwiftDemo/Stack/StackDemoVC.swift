//
//  StackDemoVC.swift
//  TextureSwiftDemo
//
//  Created by 李晨 on 2019/1/18.
//  Copyright © 2019 李晨. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class StackDemoVC: ASViewController<StackDemoNode> {
    
}

class StackDemoNode: ASDisplayNode {
    let n1 = ASDisplayNode()
    let n2 = ASDisplayNode()
    let n3 = ASDisplayNode()
    let n4 = ASDisplayNode()
    let n5 = ASDisplayNode()
    let n6 = ASDisplayNode()
    let n7 = ASDisplayNode()
    let n8 = ASDisplayNode()
    let n9 = ASDisplayNode()

    override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
        self.backgroundColor = UIColor.white

        n1.style.width = ASDimension(unit: .points, value: 30)
        n1.style.height = ASDimension(unit: .points, value: 30)
        n2.style.width = ASDimension(unit: .points, value: 30)
        n2.style.height = ASDimension(unit: .points, value: 30)
        n3.style.width = ASDimension(unit: .points, value: 30)
        n3.style.height = ASDimension(unit: .points, value: 30)


        n4.style.width = ASDimension(unit: .fraction, value: 0.3)
        n4.style.height = ASDimension(unit: .fraction, value: 0.5)
        n5.style.width = ASDimension(unit: .fraction, value: 0.3)
        n5.style.height = ASDimension(unit: .fraction, value: 0.6)
        n6.style.width = ASDimension(unit: .fraction, value: 0.3)
        n6.style.height = ASDimension(unit: .fraction, value: 0.7)

//        n1.style.preferredSize = CGSize(width: 30, height: 30)
//        n2.style.preferredSize = CGSize(width: 30, height: 30)
//        n3.style.preferredSize = CGSize(width: 30, height: 30)
//        n4.style.preferredSize = CGSize(width: 30, height: 30)
//        n5.style.preferredSize = CGSize(width: 30, height: 30)
//        n6.style.preferredSize = CGSize(width: 30, height: 30)
        n7.style.preferredSize = CGSize(width: 30, height: 30)
        n8.style.preferredSize = CGSize(width: 30, height: 30)
        n9.style.preferredSize = CGSize(width: 30, height: 30)

        n1.backgroundColor = UIColor.yellow
        n2.backgroundColor = UIColor.red
        n3.backgroundColor = UIColor.blue
        n4.backgroundColor = UIColor.blue
        n5.backgroundColor = UIColor.yellow
        n6.backgroundColor = UIColor.red
        n7.backgroundColor = UIColor.red
        n8.backgroundColor = UIColor.blue
        n9.backgroundColor = UIColor.yellow
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let s0 = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .start, alignItems: .start, children: [])

        let s1 = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .start, alignItems: .start, children: [n1, n2, n3])

        let s2 = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .start, alignItems: .start, children: [n4, n5, n6])
        let s3 = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .start, alignItems: .start, children: [n7, n8, n9])

        s0.style.preferredSize = CGSize(width: 400, height: 244)
        s1.style.height = ASDimension(unit: .auto, value: 0)
        s1.style.width = ASDimension(unit: .auto, value: 0)
        s2.style.preferredSize = CGSize(width: 400, height: 44)
        s3.style.preferredSize = CGSize(width: 400, height: 44)

        return ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .start, children: [s0, s1, s2, s3])
    }

}
