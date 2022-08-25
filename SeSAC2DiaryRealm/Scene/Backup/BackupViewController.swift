//
//  BackupViewController.swift
//  SeSAC2DiaryRealm
//
//  Created by 김태현 on 2022/08/25.
//

import UIKit
import Zip

class BackupViewController: BaseViewController {

    let mainView = BackupView()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "백업페이지"
        
        mainView.backupTableView.delegate = self
        mainView.backupTableView.dataSource = self
        
        mainView.backupButton.addTarget(self, action: #selector(backupButtonClicked), for: .touchUpInside)
        mainView.resetButton.addTarget(self, action: #selector(restoreButtonClicked), for: .touchUpInside)
    }
    

}


extension BackupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}


extension BackupViewController {
    
    @objc
    func backupButtonClicked() {
        
        var urlPaths = [URL]()
       
        // 1. 도큐먼트 위치에 백업 파일 확인
        
        // ~~~~~~~~~/Documents
        guard let path = documentDirectoryPath() else {
            showAlertMessage(title: "도큐먼트 위치에 오류가 있습니다")
            return
        }
        
        // realm파일 설정시 파일명을 지정해주지 않았을때 기본 파일명 => default.realm
        // ~~~~~~~~~/Documents/default.realm
        let realmFile = path.appendingPathComponent("default.realm")
        
        guard FileManager.default.fileExists(atPath: realmFile.path) else {
            showAlertMessage(title: "백업할 파일이 없습니다")
            return
        }
        
        urlPaths.append(URL(string: realmFile.path)!)
        
        // 백업 파일을 압축
        do {
            let zipFilePath = try Zip.quickZipFiles(urlPaths, fileName: "SeSACDiary_1")
            print("Archive Location: \(zipFilePath)")
            
            showActivityViewController()
        } catch {
            showAlertMessage(title: "압축을 실패했습니다")
            
        }
        
        // ActivityViewController
    }
    
    
    func showActivityViewController() {
        
        guard let path = documentDirectoryPath() else {
            showAlertMessage(title: "도큐먼트 위치에 오류가 있습니다")
            return
        }
        
        let backupFileURL = path.appendingPathComponent("SeSACDiary_1.zip")
        
        let vc = UIActivityViewController(activityItems: [backupFileURL], applicationActivities: [])
        self.present(vc, animated: true)
    }
    
    @objc
    func restoreButtonClicked() {
        
        // 파일앱 내 압축파일 유지
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.archive], asCopy: true)
        documentPicker.delegate = self
        
        // 여러개 선택 방지
        documentPicker.allowsMultipleSelection = false
        
        self.present(documentPicker, animated: true)
    }
}

extension BackupViewController: UIDocumentPickerDelegate {
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print(#function)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        // 내파일 내 압축파일 경로
        guard let selectedFileURL = urls.first else {
            showAlertMessage(title: "선택하신 파일을 찾을 수 없습니다")
            return
        }
        
        // 저장할 documents 경로
        guard let path = documentDirectoryPath() else {
            showAlertMessage(title: "도큐먼트 위치에 오류가 있습니다")
            return
        }
        // "/SeSACDiary_1" 추가
        // 경로만 명시된 것
        let sandboxFileURL = path.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
            
            let fileURL = path.appendingPathComponent("SeSACDiary_1.zip")
            
            do {
                try Zip.unzipFile(fileURL, destination: path, overwrite: true, password: nil, progress: { progress in
                    print("progress: \(progress)")}, fileOutputHandler: { unzippedFile in
                        print("unzippedFile: \(unzippedFile)")
                        self.showAlertMessage(title: "복구가 완료되었습니다")
                        
                        // 앱 재시작 로직
                        // 앱 재시작 알림 -> 루트뷰 재설정
                    }
                )
            } catch {
                showAlertMessage(title: "압축 해제에 실패했습니다")
            }
            
        } else {
            
            do {
                // 파일 앱의 zip -> 도큐먼트 폴더에 복사
                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
                
                let fileURL = path.appendingPathComponent("SeSACDiary_1.zip")
                
                try Zip.unzipFile(fileURL, destination: path, overwrite: true, password: nil, progress: { progress in
                    print("progress: \(progress)")}, fileOutputHandler: { unzippedFile in
                        print("unzippedFile: \(unzippedFile)")
                        self.showAlertMessage(title: "복구가 완료되었습니다")
                        
                        // 앱 재시작 로직
                        // 앱 재시작 알림 -> 루트뷰 재설정
                    }
                )
            } catch {
                showAlertMessage(title: "압축 해제에 실패했습니다")
            }
            
        }
    }
}
