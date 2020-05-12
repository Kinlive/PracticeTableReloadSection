//
//  ViewController.swift
//  DemoTableContainTable
//
//  Created by Thinkpower on 2020/5/11.
//  Copyright © 2020 Thinkpower. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    lazy var outsideTableView: UITableView = {
        let tableView = UITableView(frame: self.view.frame)
        tableView.backgroundColor = UIColor(red: 75 / 255.0, green: 100 / 255.0, blue: 235 / 255.0, alpha: 1)
        
    
        tableView.register(ListCell.self, forCellReuseIdentifier: "ListCell")
        
        return tableView
    }()

    private let dataSources = [
        ["one", "two", "three", "four"],
        ["one", "two", "three", "four"],
        ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "zero",
        "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "zero",
        "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "zero",
        "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "zero",
        "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "zero",
        "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "zero",
        "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "zero",
        "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "zero",
        "one", "two", "three"]
    ]
    
    private var needToReloadDatas: [String] = []
    private var previousReloadDatas: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        needToReloadDatas = dataSources[2]
                                .enumerated()
                                .compactMap { $0.offset < 10 ? $0.element : nil }
        
        outsideTableView.delegate = self
        outsideTableView.dataSource = self
        
        view.addSubview(outsideTableView)
        outsideTableView.translatesAutoresizingMaskIntoConstraints = false
        
        outsideTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        outsideTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        outsideTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        outsideTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    private func setInsetOfTableBottom(additionalHeight: CGFloat) {
        DispatchQueue.main.async {
             self.outsideTableView.contentInset.bottom = additionalHeight
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSources.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section != 2 ? dataSources[section].count : needToReloadDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ListCell.self)) as? ListCell else { return UITableViewCell() }
        
        let displayText = indexPath.section != 2 ? dataSources[indexPath.section][indexPath.row] : needToReloadDatas[indexPath.row]
        cell.title.text = displayText
        cell.backgroundColor = .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = ListHeaderView()
        switch section {
        case 0:
            view.configureAboutHeader(title: "one")
        case 1:
            view.configureAboutHeader(title: "two")
        case 2:
            view.configureAboutHeader(title: "three")
            view.reloadOfOne = {
                self.needToReloadDatas = self.dataSources[2]
                                        .enumerated()
                                        .compactMap { $0.offset < 10 ? $0.element : nil }
                
                var additional: CGFloat = 0
                
                if self.needToReloadDatas.count < self.previousReloadDatas.count {
                    let diffCount = self.previousReloadDatas.count - self.needToReloadDatas.count
                    additional = CGFloat(diffCount - 1) * 70
                    self.setInsetOfTableBottom(additionalHeight: additional)
                }
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.outsideTableView.performBatchUpdates({
                        self.outsideTableView.reloadSections([section], with: .none)
                    }, completion: { _ in
                        if additional == 0 {
                            self.setInsetOfTableBottom(additionalHeight: additional)
                        }
                    })
                }
            }
            
            view.reloadOfTwo = {
                self.needToReloadDatas = self.dataSources[2]
                    .enumerated()
                    .compactMap { $0.element }
                
                var additional: CGFloat = 0
                
                if self.needToReloadDatas.count < self.previousReloadDatas.count {
                    let diffCount = self.previousReloadDatas.count - self.needToReloadDatas.count
                    additional = CGFloat(diffCount - 1) * 70
                    self.setInsetOfTableBottom(additionalHeight: additional)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.outsideTableView.performBatchUpdates({
                        self.outsideTableView.reloadSections([section], with: .none)
                    }, completion: { _ in
                        if additional == 0 {
                            self.setInsetOfTableBottom(additionalHeight: additional)
                        }
                    })
                }
            }
            
            view.reloadOfThree = {
                self.previousReloadDatas = self.needToReloadDatas
                    
                self.needToReloadDatas = self.dataSources[2]
                    .enumerated()
                    .compactMap { ($0.offset >= 20 && $0.offset < 23) ? $0.element : nil }
                
                var additional: CGFloat = 0
                
                if self.needToReloadDatas.count < self.previousReloadDatas.count {
                    let diffCount = self.previousReloadDatas.count - self.needToReloadDatas.count
                    
                    let diffHeightWithTable = tableView.frame.height
                            - CGFloat(self.needToReloadDatas.count) * 70 // will show cells height
                            - 44 // status bar height
                            - 100 // headerView
                            - (tableView.adjustedContentInset.bottom) // paddings
                    
                    additional = min(CGFloat(diffCount - 1) * 70, diffHeightWithTable) // cell height
                    
                    DispatchQueue.main.async {
                        // 若需要墊高，在更新section前做
                         self.outsideTableView.contentInset.bottom = additional
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.outsideTableView.performBatchUpdates({
                        self.outsideTableView.reloadSections([section], with: .none)
                    }, completion: {_ in
                        if additional == 0 {
                            DispatchQueue.main.async {
                                // 若不需要墊高，在更新後做
                                 self.outsideTableView.contentInset.bottom = additional
                            }
                        }
                    })
                }
            }
            
        default: return nil
        }
        
         return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

class ListCell: UITableViewCell {
    lazy var title: UILabel = {
        let label = UILabel(frame: self.frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(title)
        title.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        title.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
    }
    
}

class ListHeaderView: UIView {
    lazy var title: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        return label
    }()
    
    lazy var button1: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.setTitle("test1", for: .normal)
        btn.addTarget(self, action: #selector(onSelectedOne), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        addSubview(btn)
        return btn
    }()
    
    lazy var button2: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.setTitle("test2", for: .normal)
        btn.addTarget(self, action: #selector(onSelectedTwo), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        addSubview(btn)
        return btn
    }()
    
    lazy var button3: UIButton = {
        let btn = UIButton(frame: .zero)
        
        btn.setTitle("test3", for: .normal)
        btn.addTarget(self, action: #selector(onSelectedThree), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        addSubview(btn)
        return btn
    }()
    
    var reloadOfOne: (() -> Void)?
    var reloadOfTwo: (() -> Void)?
    var reloadOfThree: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 75 / 255.0, green: 150 / 255.0, blue: 235 / 255.0, alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupConstraints()
    }
    
    func configureAboutHeader(title: String) {
        self.title.text = title
        
    }
    
    private func setupConstraints() {
        title.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
        title.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        button1.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10).isActive = true
        button1.widthAnchor.constraint(equalToConstant: 50).isActive = true
        //button1.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button1.leadingAnchor.constraint(equalTo: title.leadingAnchor).isActive = true
        button1.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: 10).isActive = true
        
        button2.topAnchor.constraint(equalTo: button1.topAnchor).isActive = true
        button2.leadingAnchor.constraint(equalTo: button1.trailingAnchor, constant: 10).isActive = true
        button2.widthAnchor.constraint(equalTo: button1.widthAnchor).isActive = true
        //button2.heightAnchor.constraint(equalTo: button1.heightAnchor).isActive = true
        button2.bottomAnchor.constraint(equalTo: button1.bottomAnchor).isActive = true
        
        button3.topAnchor.constraint(equalTo: button1.topAnchor).isActive = true
        button3.leadingAnchor.constraint(equalTo: button2.trailingAnchor, constant: 10).isActive = true
        button3.widthAnchor.constraint(equalTo: button1.widthAnchor).isActive = true
        //button3.heightAnchor.constraint(equalTo: button1.heightAnchor).isActive = true
        button3.bottomAnchor.constraint(equalTo: button1.bottomAnchor).isActive = true
        
    }
    
    @objc private func onSelectedOne() {
        reloadOfOne?()
    }
    
    @objc private func onSelectedTwo() {
        reloadOfTwo?()
    }

    @objc private func onSelectedThree() {
        reloadOfThree?()
    }
}
