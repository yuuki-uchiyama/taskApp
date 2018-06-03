
import RealmSwift

class Category: Object{
    @objc dynamic var id = 0
    
    @objc dynamic var categoryTitle = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
