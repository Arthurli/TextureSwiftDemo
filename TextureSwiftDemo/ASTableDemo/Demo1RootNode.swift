//
//  Demo1RootNode.swift
//  TextureSwiftDemo
//
//  Created by 李晨 on 2019/1/16.
//  Copyright © 2019 李晨. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class Demo1RootNode: ASDisplayNode, ASTableDelegate, ASTableDataSource {
    var tableNode: ASTableNode = ASTableNode()
    var imageCategory: String = ""
    var nodes: [Demo1DetailNode] = []
    
    override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
        self.backgroundColor = UIColor.yellow
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        self.tableNode.backgroundColor = UIColor.white

        DispatchQueue.global().async {
            for i in 1...1000 {
                let node = Demo1DetailNode()
                node.row = i
                let range = ASSizeRangeMake(CGSize(width: UIScreen.main.bounds.width, height: 0), CGSize(width: UIScreen.main.bounds.width, height: 10000))
                node.layoutThatFits(range)
                self.nodes.append(node)
            }
            DispatchQueue.main.async {
                self.tableNode.reloadData()
            }
        }

    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.tableNode.style.preferredSize = UIScreen.main.bounds.size
        return ASAbsoluteLayoutSpec(children: [self.tableNode])
    }

    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        tableNode.reloadData()
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return nodes.count
    }

    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        return nodes[indexPath.row]
    }
}

class Demo1DetailNode: ASCellNode {
    var row: Int = 0
    var cache: ASLayout?
    var imageNode: ASNetworkImageNode = ASNetworkImageNode()

    var imageURL: URL {
        let imageSize = self.calculatedSize;
        return URL(string: "http://lorempixel.com/\(Int(imageSize.width))/\(Int(imageSize.height))/cats/\(self.row%10)")!
    }

    override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
    }

    override func layoutDidFinish() {
        super.layoutDidFinish()

        self.imageNode.url = self.imageURL
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASRatioLayoutSpec(ratio: 1, child: self.imageNode)
    }

    override func calculateLayoutThatFits(_ constrainedSize: ASSizeRange, restrictedTo size: ASLayoutElementSize, relativeToParentSize parentSize: CGSize) -> ASLayout {
        if let cache = self.cache {
            return cache
        }
        let cache = super.calculateLayoutThatFits(constrainedSize, restrictedTo: size, relativeToParentSize: parentSize)
        self.cache = cache
        return cache
    }
}
