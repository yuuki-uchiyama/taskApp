//
//  Task.swift
//  taskApp
//
//  Created by 内山由基 on 2018/05/29.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import RealmSwift

class Task: Object{
    @objc dynamic var id = 0
    
    @objc dynamic var title = ""
    
    @objc dynamic var taskCategory = ""
    
    @objc dynamic var contents = ""
    
    @objc dynamic var date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
