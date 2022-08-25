//
//  BackupView.swift
//  SeSAC2DiaryRealm
//
//  Created by 김태현 on 2022/08/25.
//

import UIKit
import SnapKit

class BackupView: BaseView {

    let backupButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = .red
        view.setTitle("백업버튼", for: .normal)
        return view
    }()
    
    let resetButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = .blue
        view.setTitle("복구버튼", for: .normal)
        return view
    }()
    
    let backupTableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    override func configureUI() {
        [backupButton, resetButton, backupTableView].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        
        backupButton.snp.makeConstraints { make in
            
            make.top.equalTo(self.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(self).offset(20)
            make.width.equalTo(resetButton.snp.width)
            make.trailing.equalTo(resetButton.snp.leading).offset(-20)
            make.height.equalTo(backupButton.snp.width).multipliedBy(1)
        }
        
        resetButton.snp.makeConstraints { make in
            
            make.top.equalTo(self.safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(self).offset(-20)
            make.height.equalTo(resetButton.snp.width).multipliedBy(1)
        }
        
        backupTableView.snp.makeConstraints { make in
            
            make.top.equalTo(backupButton.snp.bottom).offset(20)
            make.trailing.equalTo(self).offset(20)
            make.leading.equalTo(self).offset(-20)
            make.bottom.equalTo(self)
        }
    }

}
