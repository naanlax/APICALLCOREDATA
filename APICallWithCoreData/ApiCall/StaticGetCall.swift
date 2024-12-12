
import Foundation
import CoreData
import UIKit

class StaticGetCall {
    private var hasFetchedData = false
    private let manageObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let serviceUrl = URL(string: "https://www.zohoapis.com/books/v3/items?organization_id=863010973")
    
    private var request: URLRequest {
        var req = URLRequest(url: serviceUrl!)
        req.httpMethod = "GET"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("\(oauthToken)", forHTTPHeaderField: "Authorization")
        return req
    }
    
    private let oauthToken = "Zoho-oauthtoken 1000.fb485a8ac0801f6640e0f647ec6fa643.08885bfa16dd33c96387fe49995ec01d"
    
    var items: [ItemsList] = []
    
    func getData(completion: @escaping ([ItemsList]) -> Void) {
        if hasFetchedData {
            print("Data already fetched. Returning cached items.")
            completion(self.items)
            return
        }
        
        hasFetchedData = true
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                self.hasFetchedData = false
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            if let data = data {
                do {
                    let responseObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    
                    if let jsonResponse = responseObject as? [String: Any],
                       let itemsArray = jsonResponse["items"] as? [[String: Any]] {
                        for item in itemsArray {
                            if let name = item["name"] as? String,
                               let itemID = item["item_id"] as? String,
                               let sku = item["sku"] as? String,
                               let desc = item["description"] as? String,
                               let rate = item["rate"] as? Int
                            {
                               let itemToBeAdded = ItemsList(context: self.manageObjectContext)
                                itemToBeAdded.item_id = itemID
                                itemToBeAdded.name = name
                                itemToBeAdded.desc = desc
                                itemToBeAdded.sku = sku
                                itemToBeAdded.rate = Int64(rate)
                                
                                print(itemToBeAdded)
                                
                                try! self.manageObjectContext.save()
                            }
                        }
                    }
                    else
                    {
                        print("Invalid JSON response")
                        return
                    }
                    
                    self.items = try! self.manageObjectContext.fetch(ItemsList.fetchRequest())
                    print(self.items.count)
                    completion(self.items)
                }
                catch {
                    print("Error parsing response JSON: \(error)")
                    self.hasFetchedData = false 
                }
            }
        }
        task.resume()
    }
}
