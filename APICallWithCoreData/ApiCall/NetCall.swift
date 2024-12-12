import Foundation
import UIKit

class NetCall
{
    var itemId : String = ""
    
    var postData: [String: Any] = [:]
    
    var items: [ItemsList] = []
    
    var request: URLRequest?
    
    private let manageObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let oauthToken = "Zoho-oauthtoken 1000.fb485a8ac0801f6640e0f647ec6fa643.08885bfa16dd33c96387fe49995ec01d"
    
    private var hasFetchedData = false
    
    var serviceUrl : URL
    {
        return URL(string: "https://www.zohoapis.com/books/v3/items/\(itemId)?organization_id=863010973")!
    }
    
    func postDataAndPutData(
        methodPerformed : String,
        messagePassed : ItemsList,
        completion: @escaping (ItemsList) -> Void)
    {
        if methodPerformed == "POST"
        {
            request = URLRequest(url: serviceUrl)
            request?.httpMethod = "POST"
        }
        else
        {
            itemId = messagePassed.item_id ?? ""
            request = URLRequest(url: serviceUrl)
            request?.httpMethod = "PUT"
        }
        
        postData["name"] = messagePassed.name
        postData["sku"] = messagePassed.sku
        postData["rate"] = messagePassed.rate
        postData["description"] = messagePassed.desc
        
        guard let jsonData = try? JSONSerialization.data(
            withJSONObject: postData,
            options: []
        )
        else
        {
            print("Error: Unable to serialize JSON");
            fatalError()
        }
        
        request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request?.addValue("\(oauthToken)", forHTTPHeaderField: "Authorization")
        request?.httpBody = jsonData
        
        if let request
        {
            let task = URLSession.shared.dataTask(with: request)
            {
                data, response, error in
                if let error = error
                {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse
                {
                    print("HTTP Status Code: \(httpResponse.statusCode)")
                }
                
                if let data = data
                {
                    do
                    {
                        let responseObject = try JSONSerialization.jsonObject(
                            with: data,
                            options: .mutableContainers) as? [String : Any]
                        
                        if let jsonResponse = responseObject?["item"] as? [String: Any]
                        {
                            let item_id = jsonResponse["item_id"] as? String
                            messagePassed.item_id = item_id
                            
                            try! self.manageObjectContext.save()
                            completion(messagePassed)
                        }
                    }
                    catch
                    {
                        print("Error parsing response JSON: \(error)")
                    }
                }
            }
            task.resume()
        }
    }
    
    func deleteData(itemIDPassed : String, completion : @escaping (Int) -> Void)
    {
        request?.httpMethod = "DELETE"
        request?.addValue("\(oauthToken)", forHTTPHeaderField: "Authorization")
        
        if let request
        {
            let task = URLSession.shared.dataTask(with: request)
            {
                data, response, error in
                if let error = error
                {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse
                {
                    print("HTTP Status Code: \(httpResponse.statusCode)")
                    completion(httpResponse.statusCode)
                }
                
                if let data = data
                {
                    do
                    {
                        let responseObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any]
                    }
                    catch
                    {
                        print("Error parsing response JSON: \(error)")
                    }
                }
            }
            task.resume()
        }
    }

    func getData(
        completion: @escaping ([ItemsList]) -> Void
    )
    {
        if hasFetchedData
        {
            print("Data already fetched. Returning cached items.")
            completion(self.items)
            return
        }
        
        hasFetchedData = true
        
        request?.httpMethod = "GET"
        request?.addValue("\(oauthToken)", forHTTPHeaderField: "Authorization")
        
        if let request
        {
            let task = URLSession.shared.dataTask(with: request)
            {
                data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    self.hasFetchedData = false
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Status Code: \(httpResponse.statusCode)")
                    print(httpResponse)
                }
                
                if let data = data
                {
                    do
                    {
                        let responseObject = try JSONSerialization.jsonObject(
                            with: data,
                            options: .mutableContainers
                        )
                        
                        if let jsonResponse = responseObject as? [String: Any],
                           let itemsArray = jsonResponse["items"] as? [[String: Any]]
                        {
                            for item in itemsArray
                            {
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
                    catch
                    {
                        print("Error parsing response JSON: \(error)")
                        self.hasFetchedData = false
                    }
                }
            }
            task.resume()
        }
    }
}
