//
//  ChatViewController.swift
//  TextureSwiftDemo
//
//  Created by 李晨 on 2019/1/17.
//  Copyright © 2019 李晨. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

struct Message {
    let type: String
    let text: String
    let image: UIImage
}

struct Chatter {
    let name: String
    let avatar: UIImage
}

struct MessageNode {
    let chatter: Chatter
    let message: Message
    var showAvatar: Bool
    let reactions: [String]
}

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var messageNodes: [MessageNode] = []
    var heights: [CGFloat] = []
    var nodes: [ChatCellNode] = []
    var tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.tableView)
        self.tableView.frame = UIScreen.main.bounds
        self.tableView.backgroundColor = UIColor.yellow
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "demo")
        self.setupData()
    }

    func setupData() {
        let messages: [Message] = [
            Message(type: "text", text: "This is text", image: UIImage(named: "4")!),
            Message(type: "text", text: "An optional property that provides a minimum RELATIVE size bound for a layout element. If provided, this restriction will always be enforced. If a parent layout element’s minimum relative size is smaller than its child’s minimum relative size, the child’s minimum relative size will be enforced and its size will extend out of the layout spec’s.", image: UIImage(named: "4")!),
            Message(type: "text", text: "Warning: calling the getter when the size's width or height are relative will cause an assert.", image: UIImage(named: "4")!),
            Message(type: "image", text: "This is a Texture demo ", image: UIImage(named: "4")!),
            Message(type: "image", text: "This is a Texture demo ", image: UIImage(named: "5")!),
            Message(type: "image", text: "This is a Texture demo ", image: UIImage(named: "6")!)
        ]

        let chatters: [Chatter] = [
            Chatter(name: "people 1", avatar: UIImage(named: "1")!),
            Chatter(name: "people 2", avatar: UIImage(named: "2")!),
            Chatter(name: "people 3", avatar: UIImage(named: "3")!),
        ]

        let reactions: [[String]] = [[], ["haha"], ["haha", "cry"]]

        var lastc: Chatter?
        for _ in 0...100 {
            let c = chatters[Int(arc4random() % 3)]
            let m = messages[Int(arc4random() % 6)]
            let r = reactions[Int(arc4random() % 3)]
            let showAvatar = lastc == nil || lastc!.name != c.name
            let messageNode = MessageNode(chatter: c, message: m, showAvatar:showAvatar, reactions: r)
            lastc = c
            self.messageNodes.append(messageNode)
            let node = ChatCellNode()
            node.node = messageNode
            let size = node.layoutThatFits(ASSizeRange(min: CGSize.zero, max: UIScreen.main.bounds.size)).size
            nodes.append(node)
            heights.append(size.height)
        }

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageNodes.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heights[indexPath.row]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "demo") as? ChatTableViewCell {
            cell.backgroundColor = UIColor.gray
            cell.node = self.nodes[indexPath.row]
            cell.height = self.heights[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class ChatTableViewCell: UITableViewCell {

    var node: ChatCellNode? {
        didSet {
            oldValue?.view.removeFromSuperview()
            if let node = self.node {
                self.contentView.addSubnode(node)
            }
        }
    }

    var height: CGFloat = 0 {
        didSet {
            self.node?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
        }
    }
}

class ChatCellNode: ASDisplayNode {
    var avatarNode: AvatarNode = AvatarNode()
    var bubbleNode: BubbleNode = BubbleNode()

    override init() {
        super.init()
        self.automaticallyManagesSubnodes = true

        self.style.maxSize = CGSize(width: UIScreen.main.bounds.width, height: 1000)
    }

    var node: MessageNode? {
        didSet {
            guard let node = self.node else { return }
            self.avatarNode.image = self.node?.chatter.avatar
            self.bubbleNode.node = node
            self.setNeedsLayout()
        }
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        var leftView: [ASLayoutElement] = []
        if let node = self.node, node.showAvatar {
            leftView.append(self.avatarNode)
        }

        let leftSpec = ASWrapperLayoutSpec(layoutElements: leftView)
        leftSpec.style.minSize = CGSize(width: 44, height: 0)

        let stack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .start, children: [leftSpec, bubbleNode])

        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), child: stack)
    }
}

class AvatarNode: ASDisplayNode {

    var imageView: UIImageView?

    var image: UIImage? {
        didSet {
            self.imageView?.image = image
        }
    }

    override init() {
        super.init()
        self.setViewBlock { [weak self] () -> UIView in
            guard let `self` = self else {
                return UIView()
            }

            if self.imageView == nil {
                self.imageView = UIImageView()
                self.imageView?.image = self.image
            }
            return self.imageView!
        }
        self.automaticallyManagesSubnodes = true

        self.style.preferredSize = CGSize(width: 44, height: 44)
    }
}

class BubbleNode: ASDisplayNode {

    var contentNode: ContentNode?
    var reactionNode: ReactionNode?


    var node: MessageNode? {
        didSet {
            guard let node = self.node else { return }
            if node.message.type == "text" {
                self.contentNode = TextNode()
            } else {
                self.contentNode = ImageNode()
            }
            self.contentNode?.message = node.message

            if node.reactions.isEmpty {
                self.reactionNode = nil
            } else {
                self.reactionNode = ReactionNode()
                self.reactionNode?.reactions = node.reactions
            }
            self.setNeedsLayout()
        }
    }
    override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
        self.backgroundColor = UIColor.white
        self.style.flexShrink = 1
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var inset: CGFloat = 0
        var childrens: [ASDisplayNode] = []
        if let content = self.contentNode {
            childrens.append(content)
        }

        if let reaction = self.reactionNode {
            inset = 10
            childrens.append(reaction)
        }

        let stack = ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: .start, alignItems: .start, children: childrens)
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset), child: stack)
    }
}

class ContentNode: ASDisplayNode {
    override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
    }

    var message: Message?
}

class TextNode: ContentNode {
    var label: UILabel = UILabel()

    override var message: Message? {
        didSet {
            self.label.numberOfLines = 0
            self.label.text = message?.text ?? ""
            self.label.font = UIFont.systemFont(ofSize: 16)
        }
    }

    override init() {

        super.init()
        self.setViewBlock { [weak self] () -> UIView in
            guard let `self` = self else {
                return UIView()
            }
            return self.label
        }
        self.style.flexShrink = 1
        self.label.backgroundColor = UIColor.lightGray
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spec = ASWrapperLayoutSpec(layoutElements: [])
        let size = self.label.sizeThatFits(CGSize(width: constrainedSize.max.width, height: 10000))
        spec.style.preferredSize = size
        return spec
    }
}

class ImageNode: ContentNode {
    var imageView: UIImageView?

    override var message: Message? {
        didSet {
            self.imageView?.image = message?.image
        }
    }

    override init() {

        super.init()
        self.setViewBlock { [weak self] () -> UIView in
            guard let `self` = self else {
                return UIView()
            }

            if self.imageView == nil {
                self.imageView = UIImageView()
                self.imageView?.image = self.message?.image
            }
            return self.imageView!
        }

        self.style.preferredSize = CGSize(width: 200, height: 100)
    }
}

class ReactionNode: ASDisplayNode {

    var reactions: [String] = []

    override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
    }


    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var views: [ASTextNode] = []

        for s in self.reactions {
            let t = ASTextNode()
            t.attributedText = NSAttributedString(string: s)
            t.backgroundColor = UIColor.gray
            views.append(t)
        }

        return ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: .start, alignItems: .start, children: views)
    }

}
