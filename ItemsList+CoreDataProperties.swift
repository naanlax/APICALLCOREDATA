import Foundation
import CoreData


extension ItemsList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemsList> {
        return NSFetchRequest<ItemsList>(entityName: "ItemsList")
    }

    @NSManaged public var name: String?
    @NSManaged public var item_id: String?
    @NSManaged public var rate: Int64
    @NSManaged public var desc: String?
    @NSManaged public var sku: String?

}

extension ItemsList : Identifiable {

}
