//
//  SearchChatViewController.swift
//  Gardener
//
//  Created by 유현진 on 2/19/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SearchChatRoomViewController: UIViewController {

    var disposeBag = DisposeBag()
    
    private lazy var searchChatView: SearchChatView = {
        return SearchChatView()
    }()
    
    private lazy var searchBar: UISearchBar = {
        var searchBar = UISearchBar(frame: .init(x: 0, y: 0, width: self.view.bounds.width - 20, height: 0))
        searchBar.placeholder = "관심있는 키워드를 검색해 보세요."
        return searchBar
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initSearchBar()
        initChatListTableView()
    }
    
    private func initUI(){
        self.view.backgroundColor = .systemBackground
        
        self.view.addSubview(searchChatView)
        
        searchChatView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
        }
    }
    
    private func initSearchBar(){
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.searchBar)
        
        searchBar.rx
            .searchButtonClicked
            .bind{ text in
                self.searchBar.resignFirstResponder()
            }.disposed(by: disposeBag)
    }
    
    private func initChatListTableView(){
        searchChatView.searchChatListTableView.register(SearchChatRoomTableViewCell.self, forCellReuseIdentifier: "searchChatRoomCell")
        
        searchChatView.searchChatListTableView.rowHeight = 150
        
        
    }
}
