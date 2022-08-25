//
//  HomeViewController.swift
//  SeSAC2DiaryRealm
//
//  Created by jack on 2022/08/22.
//

import UIKit
import SnapKit
import RealmSwift //Realm 1. import

class HomeViewController: BaseViewController {
    
    let localRealm = try! Realm() // Realm 2.
    
    // 0823
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.rowHeight = 100
        view.delegate = self
        view.dataSource = self
        return view
    }() // 즉시 실행 클로저
    
    var tasks: Results<UserDiary>! {
        didSet {
            //화면 갱신은 화면 전환 코드 및 생명 주기 실행 점검 필요!
            //present, overCurrentContext, overFullScreen > viewWillAppear X
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "cell")
         
        fetchDocumentZipFile()
    }
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
        
        fetchRealm()
    }
    
    // 0823
    func fetchRealm() {
        //Realm 3. Realm 데이터를 정렬해 tasks 에 담기
        tasks = localRealm.objects(UserDiary.self).sorted(byKeyPath: "diaryTitle", ascending: true)
    }
    
    override func configure() {
        view.addSubview(tableView)
        
        let toBackupButton = UIBarButtonItem(title: "백업", style: .plain, target: self, action: #selector(toBackupVC))
        let plusButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(plusButtonClicked))
        navigationItem.rightBarButtonItems = [toBackupButton, plusButton]
        
        // 0823
        let sortButton = UIBarButtonItem(title: "정렬", style: .plain, target: self, action: #selector(sortButtonClicked))
        let filterButton = UIBarButtonItem(title: "필터", style: .plain, target: self, action: #selector(filterButtonClicked))
        navigationItem.leftBarButtonItems = [sortButton, filterButton]
    }
    
    override func setConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    @objc func toBackupVC() {
        let vc = BackupViewController()
        
        transition(vc, transitionStyle: .presentFullNavigation)
    }
    
    @objc func plusButtonClicked() {
        let vc = WriteViewController()
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
        
        transition(vc, transitionStyle: .presentFullNavigation)
    }
    
    // 0823
    @objc func sortButtonClicked() {
        
        tasks = localRealm.objects(UserDiary.self).sorted(byKeyPath: "regdate", ascending: true)
    }
    
    // 0823
    // realm filter query, NSPredicate
    @objc func filterButtonClicked() {
        
//        tasks = localRealm.objects(UserDiary.self).filter("diaryTitle = '오늘의 일기961'")
        tasks = localRealm.objects(UserDiary.self).filter("diaryTitle CONTAINS[c] '일기'")
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? HomeTableViewCell else { return UITableViewCell() }
        cell.setData(data: tasks[indexPath.row])
        
        cell.diaryImageView.image = loadImageFromDocument(fileName: "\(tasks[indexPath.row].objectId)")
        return cell
    }
    
    // 0823
    // 참고. TableView Editing Mode 알아보기
    // 테이블뷰 셀 높이가 작을 경우, 이미지가 없을 때, 시스템 이미지가 아닌 경우
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let favorite = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
            
            // realm data update
            try! self.localRealm.write {
                self.tasks[indexPath.row].favorite = !self.tasks[indexPath.row].favorite
                
                // 하나의 테이블에 특정 컬럼 전체 값을 변경
//                self.tasks.setValue(true, forKey: "favorite")
                
                // 하나의 레코드에서 여러 컬럼들이 변경
//                self.localRealm.create(UserDiary.self, value: [
//                    "objectId": self.tasks[indexPath.row].objectId,
//                    "diaryTitle": "제목임",
//                    "diaryContent": "변경테스트"
//                ], update: .modified)
            }
            
            // 선택
            // 1. 스와이프한 셀 하나만 ReloadRows 코드를 구현 => 상대적 효율성
            // 2. 데이터가 변경되었으니 다시 realm에서 데이터를 가지고 오기 => didSet 일관적 형태로 갱신
            self.fetchRealm()
        }
        
        // realm 데이터 기준
        let image = tasks[indexPath.row].favorite ? "star.fill" : "star"
        favorite.image = UIImage(systemName: image)
        favorite.backgroundColor = .systemPink
        
        return UISwipeActionsConfiguration(actions: [favorite])
    }
    
    // 0823
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let favorite = UIContextualAction(style: .normal, title: "즐겨찾기") { action, view, completionHandler in
            
            print("favorite Button Clicked")
        }
        
        let example = UIContextualAction(style: .normal, title: "예시") { action, view, completionHandler in
            
            print("example Button Clicked")
        }
        
        return UISwipeActionsConfiguration(actions: [favorite, example])
    }
}
