//
//  CategroyViewController.swift
//  Gardener
//
//  Created by 유현진 on 2023/06/05.
//

import UIKit
import SnapKit

class CategoryViewController: UIViewController{
    
    private lazy var tableView: UITableView = {
        return UITableView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        initUI()
        initTableViewHeader()
    }
    
    private func initUI(){
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "categoryCell")
        tableView.separatorInset.left = 20
        tableView.separatorInset.right = 20
        tableView.separatorInset.top = 10
        tableView.separatorInset.bottom = 10
//        tableView.separatorStyle = .none
    }
    private func initTableViewHeader(){
        let headerView = UIView(frame: .init(x: 0, y: 0, width: view.frame.width, height: 80))
        headerView.translatesAutoresizingMaskIntoConstraints = false
        let headerLabel = UILabel(frame: headerView.bounds)
        headerLabel.text = "카테고리를 선택해 주세요."
        headerLabel.font = .boldSystemFont(ofSize: 22)
        headerView.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(30)
            make.bottom.equalToSuperview()
        }
        tableView.tableHeaderView = headerView
    }
    
    // TODO: tabelView 올라오는 최대 높이
}
extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BoardCategory.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = BoardCategory.allCases[indexPath.row].rawValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: 셀 선택 시 게시글 작성 뷰 카테고리 Label 수정
    }
}
