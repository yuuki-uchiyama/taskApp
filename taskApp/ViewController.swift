//
//  ViewController.swift
//  taskApp
//
//  Created by 内山由基 on 2018/05/26.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryFilterTextField: UITextField!
    var filterPickerView: UIPickerView = UIPickerView()
    
    //初期設定のためのプロパティとインスタンス
    var setting = 0
    let userDefaults = UserDefaults.standard

    //realmのインスタンス作成
    let realm = try! Realm()
    
    //Task.swift、Category.swiftからデータをresults型として取り出す
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    var categoryArray = try! Realm().objects(Category.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //テーブルビューのデリゲート設定
        tableView.delegate = self
        tableView.dataSource = self
        
        //textfield PickerViewのデリゲート設定
        filterPickerView.dataSource = self
        filterPickerView.delegate = self
        
        userDefaults.register(defaults: ["settingKey": 0])
        setting = readData()
        //カテゴリ初期入力
        if setting == 0{
            let preCategory1 = Category()
            preCategory1.id = 0
            preCategory1.categoryTitle = "仕事"
            
            let preCategory2 = Category()
            preCategory2.id = 1
            preCategory2.categoryTitle = "プライベート"
            
            let preCategory3 = Category()
            preCategory3.id = 2
            preCategory3.categoryTitle = "その他"
            
            try! realm.write{
                self.realm.add(preCategory1, update: true)
                self.realm.add(preCategory2, update: true)
                self.realm.add(preCategory3, update: true)
            }
            setting = 1
            saveData(int: setting)
        }
            print(taskArray)
 
        //TextViewと結びつけるための設定＋決定ボタン・取り消しボタン設定
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ViewController.done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ViewController.cancel))
        toolbar.setItems([cancelItem, doneItem], animated: true)
        self.categoryFilterTextField.inputView = filterPickerView
        self.categoryFilterTextField.inputAccessoryView = toolbar

    }
    
    func saveData(int: Int){
        userDefaults.set(int, forKey: "settingKey")
        userDefaults.synchronize()
    }
    
    func readData() -> Int {
        let int: Int = userDefaults.object(forKey: "settingKey") as! Int
        return int
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //UITableViewDataSourceの中のメソッドを指定
    //cellの数（列）を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // cellの内容を指定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    //UITableViewDelegateの中のメソッド
    // cellをタップした時の動作を指定
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "inputCellSegue", sender: nil)
    }
    // cellが削除可能なことを伝える
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    //削除した時の動作を指定
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            //taskプロパティを作り、削除指定したタスク内容を取得
            let task = self.taskArray[indexPath.row]
            //該当するローカル通知を取得し、削除
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            //realmから該当するデータを削除
            try! realm.write{
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            //ログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests{
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    
    //pickerviewのプロトコル
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryArray[row].categoryTitle
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.categoryFilterTextField.text = categoryArray[row].categoryTitle
        taskArray = realm.objects(Task.self).filter("taskCategory like '\(String(describing: self.categoryFilterTextField.text!))'")
        tableView.reloadData()
    }
    @objc func cancel(){
        self.categoryFilterTextField.text = ""
        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
        tableView.reloadData()
        self.categoryFilterTextField.endEditing(true)
    }
    @objc func done(){
        self.categoryFilterTextField.endEditing(true)
    }
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    // segueで遷移した時の動作設定
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        //InputViewControllerに遷移した時の動作
        self.categoryFilterTextField.text = ""
        self.categoryFilterTextField.endEditing(true)
        
        if (segue.identifier?.contains("input"))!{
            let inputViewController:InputViewController = segue.destination as! InputViewController

            // cellをタップして遷移する場合は、タップしたcellのタスク内容を取得し、InputViewControllerに送る
            if segue.identifier == "inputCellSegue"{
                let indexPath = self.tableView.indexPathForSelectedRow
                inputViewController.task = taskArray[indexPath!.row]
            }else{
                //＋ボタンをタップして遷移する場合は、新しいタスクとして設定
                let task = Task()
                task.date = Date()
                let taskArray = realm.objects(Task.self)
                if taskArray.count != 0{
                    task.id = taskArray.max(ofProperty: "id")! + 1
                }
                inputViewController.task = task
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
        tableView.reloadData()
        }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue){
    }
}

