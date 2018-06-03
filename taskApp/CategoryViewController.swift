//
//  CategoryViewController.swift
//  taskApp
//
//  Created by 内山由基 on 2018/05/31.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{

    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var addCategoryTextField: UITextField!

    let realm = try! Realm()
    var category = Category()

    
    var categoryArray = try! Realm().objects(Category.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
        addCategoryTextField.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = categoryTableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].categoryTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let taskEditArray = realm.objects(Task.self).filter("taskCategory like '\(self.categoryArray[indexPath.row].categoryTitle)'")
            print(taskEditArray)
            if taskEditArray.count != 0{
                taskEditArray.forEach{_ in
                    try! realm.write{
                        taskEditArray.setValue("", forKey: "taskCategory")
                        realm.add(taskEditArray, update: true)
                    }
                }
            }
            try! realm.write{
                self.realm.delete(self.categoryArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addCategoryTextField.resignFirstResponder()
        return true
    }
    
    @IBAction func addNewCategory(_ sender: Any) {
        if addCategoryTextField.text != ""{
            try! realm.write{
                self.category.id = categoryArray.max(ofProperty: "id")! + 1
                self.category.categoryTitle = self.addCategoryTextField.text!
                self.realm.add(self.category, update: true)
            }
            addCategoryTextField.text = ""
            categoryTableView.reloadData()
            categoryArray = try! Realm().objects(Category.self)
            category = Category()
            addCategoryTextField.resignFirstResponder()
        }
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
