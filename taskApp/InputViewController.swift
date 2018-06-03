//
//  InputViewController.swift
//  taskApp
//
//  Created by 内山由基 on 2018/05/29.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!

    //categoryTextFieldをタップした際のpickerViewのアウトレット
    var categoryPickerView: UIPickerView = UIPickerView()
    
    var task: Task!
    let realm = try! Realm()
    
    var categoryArray = try! Realm().objects(Category.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //PickerViewのデリゲート設定
        categoryPickerView.dataSource = self
        categoryPickerView.delegate = self
        

        //TextViewと結びつけるための設定＋決定ボタン・取り消しボタン設定
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(InputViewController.done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(InputViewController.cancel))
        toolbar.setItems([cancelItem, doneItem], animated: true)
        self.categoryTextField.inputView = categoryPickerView
        self.categoryTextField.inputAccessoryView = toolbar

        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        //タスク編集時に元のデータを読み込む(画面遷移時にtask内にデータを渡してある)
        titleTextField.text = task.title
        categoryTextField.text = task.taskCategory
        contentsTextView.text = task.contents
        datePicker.date = task.date
        
        //詳細記述textviewの外枠作成
        contentsTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentsTextView.layer.borderWidth = 0.2
        contentsTextView.layer.cornerRadius = 10.0
        contentsTextView.layer.masksToBounds = true
        
    }
    
    //キーボードを閉じる機能
    @objc func dismissKeyboard(){
        view.endEditing(true)
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
        self.categoryTextField.text = categoryArray[row].categoryTitle
    }
    @objc func cancel(){
        self.categoryTextField.text = ""
        self.categoryTextField.endEditing(true)
    }
    @objc func done(){
        self.categoryTextField.endEditing(true)
    }
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    @IBAction func enterTask(_ sender: Any) {
        try! realm.write{
            self.task.title = self.titleTextField.text!
            self.task.taskCategory = self.categoryTextField.text!
            self.task.contents = self.contentsTextView.text!
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: true)
        }
        setNotification(task: task)
        self.performSegue(withIdentifier: "Unwind", sender: nil)
    }
    
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        
        if task.title == ""{
            content.title = "(タイトルなし)"
        }else{
            content.title = task.title
        }
        if task.title == ""{
            content.title = "(タイトルなし)"
        }else{
            content.title = task.title
        }
        if task.contents == ""{
            content.body = "(内容なし)"
        }else{
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default()
        
        let calender = Calendar.current
        let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute], from:task.date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request){(error) in print(error ?? "ローカル通知登録　OK")
        }
        
        center.getPendingNotificationRequests {(requests: [UNNotificationRequest]) in
            for request in requests{
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
