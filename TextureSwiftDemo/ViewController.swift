//
//  ViewController.swift
//  TextureSwiftDemo
//
//  Created by 李晨 on 2019/1/14.
//  Copyright © 2019 李晨. All rights reserved.
//

import UIKit
import AsyncDisplayKit

struct Node {
    var title: String
    var block: () -> Void
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView = UITableView()
    var nodes: [Node] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.view.addSubview(self.tableView)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.frame = UIScreen.main.bounds
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "demo")

        self.nodes = [
            Node(title: "AStable", block: {
                let node1 = Demo1RootNode()
                let vc1 = Demo1ViewController(node: node1)
                self.navigationController?.pushViewController(vc1, animated: true)
            }),
            Node(title: "普通动画", block: {
                let vc2 = AnimationDemoController()
                self.navigationController?.pushViewController(vc2, animated: true)
            }),
            Node(title: "原生Table复杂demo", block: {
                let vc3 = ChatViewController()
                self.navigationController?.pushViewController(vc3, animated: true)
            })
        ]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nodes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "demo") {
            cell.textLabel?.text = self.nodes[indexPath.row].title
            return cell
        }
        return UITableViewCell(style: .default, reuseIdentifier: "demo")
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.nodes[indexPath.row].block()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

