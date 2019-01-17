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

class Message {
    let type: String
    let text: String
    let image: UIImage
    var showAll: Bool

    init(type: String, text: String, image: UIImage, showAll: Bool = true) {
        self.type = type
        self.text = text
        self.image = image
        self.showAll = showAll
    }

    func copy() -> Message {
        return Message(type: type, text: text, image: image, showAll: self.showAll)
    }
}

struct Chatter {
    let name: String
    let avatar: UIImage
}

class MessageNode: NSObject {
    let chatter: Chatter
    let message: Message
    var showAvatar: Bool
    let reactions: [String]

    init(chatter: Chatter, message: Message, showAvatar:Bool, reactions: [String]) {
        self.chatter = chatter
        self.message = message
        self.showAvatar = showAvatar
        self.reactions = reactions
        super.init()
    }
}

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChatTableViewCellDelegate {

    var messageNodes: [MessageNode] = []
    var heights: [CGFloat] = []
    var tableView = UITableView()
    var timer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.tableView)
        self.tableView.frame = UIScreen.main.bounds
        self.tableView.backgroundColor = UIColor.yellow
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "demo")

        self.timer = Timer(timeInterval: 1, repeats: false) { [weak self] (_) in
            self?.setupData()
        }
        RunLoop.main.add(self.timer!, forMode: .default)
    }

    var lastc: Chatter?

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

        DispatchQueue.global().async {
            for _ in 0..<100 {
                let c = chatters[Int(arc4random() % 3)]
                let m = messages[Int(arc4random() % 6)].copy()
                let r = reactions[Int(arc4random() % 3)]
                let showAvatar = self.lastc == nil || self.lastc!.name != c.name
                let messageNode = MessageNode(chatter: c, message: m, showAvatar:showAvatar, reactions: r)
                self.lastc = c
                self.messageNodes.append(messageNode)
                let node = ChatCellNode()
                node.node = messageNode
                let size = node.layoutThatFits(ASSizeRange(min: CGSize.zero, max: UIScreen.main.bounds.size)).size
                self.heights.append(size.height)
            }

            DispatchQueue.main.async {
//                self.tableView.insertRows(at: [IndexPath(row: self.messageNodes.count - 1, section: 0)], with: .none)
                self.tableView.reloadData()
            }
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
            cell.message = self.messageNodes[indexPath.row]
            cell.height = self.heights[indexPath.row]
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func update(message: MessageNode, node: ChatCellNode) {
        if let index = self.messageNodes.firstIndex(where: { (n) -> Bool in
            return n == message
        }) {
            heights[index] = node.layoutThatFits(ASSizeRange(min: CGSize.zero, max: UIScreen.main.bounds.size)).size.height
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }
    }
}

protocol ChatTableViewCellDelegate {
    func update(message: MessageNode, node: ChatCellNode)
}

class ChatTableViewCell: UITableViewCell {

    var delegate: ChatTableViewCellDelegate?

    var message: MessageNode? {
        didSet {
            self.node.node = message
        }
    }

    var node: ChatCellNode = ChatCellNode()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubnode(self.node)

        self.node.updateBlock = { [weak self] in
            guard let `self` = self else {
                return
            }
            self.delegate?.update(message: self.message!, node: self.node)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var height: CGFloat = 0 {
        didSet {
            self.node.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
        }
    }
}

class ChatCellNode: ASDisplayNode {
    var avatarNode: AvatarNode = AvatarNode()
    var bubbleNode: BubbleNode = BubbleNode()

    var updateBlock: () -> Void = {} {
        didSet {
            self.bubbleNode.updateBlock = updateBlock
        }
    }

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

    var updateBlock: () -> Void = {} {
        didSet {
            self.contentNode?.updateBlock = updateBlock
        }
    }

    var node: MessageNode? {
        didSet {
            guard let node = self.node else { return }
            if node.message.type == "text" {
                self.contentNode = TextNode()
                self.contentNode?.updateBlock = self.updateBlock
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

    var updateBlock: () -> Void = {}

    var message: Message?
}

class TextNode: ContentNode {
    lazy var label: UILabel = UILabel()
    override var message: Message? {
        didSet {
            // *******
            doWhenLoaded { [weak self] in
                self?.label.numberOfLines = (self?.message?.showAll ?? true) ? 0 : 2
                self?.label.text = self?.message?.text ?? ""
            }
        }
    }

    override init() {
        super.init()
        self.setViewBlock { [weak self] () -> UIView in
            guard let `self` = self else {
                return UIView()
            }
            self.label.backgroundColor = UIColor.lightGray
            self.label.font = UIFont.systemFont(ofSize: 16)
            self.label.isUserInteractionEnabled = true
            self.loadBlock?()
            self.loadBlock = nil
            return self.label
        }
        self.style.flexShrink = 1
    }

    override func didLoad() {
        super.didLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(clickCell))
        self.view.addGestureRecognizer(tap)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spec = ASWrapperLayoutSpec(layoutElements: [])

        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineSpacing = 2

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .paragraphStyle: paragraphStyle
        ]

        if self.message!.showAll {
            let text = (self.message?.text ?? "") as NSString
            let size = text.boundingRect(
                with: CGSize(width: constrainedSize.max.width, height: 10000),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: attributes,
                context: nil).size
            spec.style.preferredSize = size
        } else {
            let maxWidth = constrainedSize.max.width.isInfinite ? 10000 : constrainedSize.max.width
            spec.style.preferredSize = CGSize(width: maxWidth, height: 44)
        }

        return spec
    }

    var loadBlock: (() -> Void)?
    func doWhenLoaded(_ blcok: @escaping () -> Void) {
        if self.isNodeLoaded {
            blcok()
        } else {
            self.loadBlock = blcok
        }
    }

    @objc
    func clickCell() {
        self.message!.showAll = !self.message!.showAll
        self.updateBlock()
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
