//
//  ViewController.swift
//  SeSAC2DiaryRealm
//
//  Created by jack on 2022/08/21.
//

import UIKit
import Zip

// 0825
class ViewController: BaseViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

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
    
    func restoreButtonClicked() {
        
    }
}

