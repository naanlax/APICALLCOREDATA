import UIKit
import CoreData

class DisplayItemVC : UITableViewController, UISearchBarDelegate, ItemCreationDelegate
{
    
    var itemsList : [ItemsList] = []
    
    var networkCall = NetworkCall()
    
    let customCell = CustomCell()
    
    let staticCell = StaticGetCall()
    
    var searching: Bool = false
    
    var textToBeSearched: String = ""
    
    let manageObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ItemsList.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do
        {
            try self.manageObjectContext.execute(deleteRequest)
        }
        catch
        {
            print(error.localizedDescription)
        }
        
        staticCell.getData()
        {
            messagePassed in
            DispatchQueue.main.async
            {
                self.fetchitem()
            }
        }
        
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        tableView.reloadData()
    }
    
    func updateItem(itemId: String, itemToBeDisplayed : ItemsList)
    {
        if let index = itemsList.firstIndex(where: { $0.item_id == itemId })
        {
            itemsList[index] = itemToBeDisplayed
            
            fetchitem()
        }
    }
    
    func fetchitem()
    {
        self.itemsList = try! manageObjectContext.fetch(ItemsList.fetchRequest())
        DispatchQueue.main.async
        {
            self.tableView.reloadData()
        }
    }
    
    func displayItem(itemToBeDisplayed: ItemsList)
    {
        fetchitem()
    }
    
    func setUpUI()
    {
        tableView.register(CustomCell.self, forCellReuseIdentifier: "cellId")
        tableView.estimatedRowHeight = 100
        tableView.backgroundColor = .systemBackground
    }
    
    func searchItems() -> [ItemsList]
    {
        if !searching {
            return itemsList
        }
        let request = ItemsList.fetchRequest() as NSFetchRequest<ItemsList>
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@ OR sku CONTAINS[cd] %@", textToBeSearched, textToBeSearched)
        request.predicate = predicate
        itemsList = try! manageObjectContext.fetch(request)
        return itemsList
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        textToBeSearched = searchText.lowercased()
        
        searching = !searchText.isEmpty
        if !searching
        {
            fetchitem()
        }
        //tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searching ? searchItems().count : itemsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as? CustomCell else {
            fatalError("Unable to dequeue CustomTableViewCell")
        }
        
        let item = searching ? searchItems()[indexPath.row] : itemsList[indexPath.row]
        
        cell.configure(item: item)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let action = UIContextualAction(
            style: .normal, title: "Edit") { [self]
                (action, view, completionhandler) in
                
                let itemToEdit = self.itemsList[indexPath.row]
                
                let itemCreationVC = CreateItemVC()
                
                itemCreationVC.itemToEdit = itemToEdit
                itemCreationVC.name.text = itemToEdit.name
                itemCreationVC.desc.text = itemToEdit.desc
                itemCreationVC.rate.text = String(itemToEdit.rate)
                itemCreationVC.sku.text = itemToEdit.sku
                
                /*
                itemCreationVC.delegate = self
                itemCreationVC.modalPresentationStyle = .fullScreen
                 */
                
                tabBarController?.selectedIndex = 1
                //present(itemCreationVC, animated: true, completion: nil)
        }
        
        action.backgroundColor = .systemGreen
        
        let swipeAction = UISwipeActionsConfiguration(actions: [action])
        return swipeAction
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(
            style: .destructive, title: "Delete")
        {
                (action, view, completionhandler) in
                
                let itemToRemove = self.itemsList[indexPath.row]
                
                self.networkCall.deleteData(itemIDPassed: itemToRemove.item_id ?? "")
                {
                    responseCode in
                    if responseCode >= 200 && responseCode < 300
                    {
                        self.manageObjectContext.delete(itemToRemove)
                        try! self.manageObjectContext.save()
                        self.fetchitem()
                    }
                    else
                    {
                        self.showToast(
                            message: "Sorry The selected item is in Transaction",
                            font: UIFont.systemFont(ofSize: 12)
                        )
                    }
                }
        }
        
        let swipeAction = UISwipeActionsConfiguration(actions: [action])
        return swipeAction
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)

        let titleLabel = UILabel()
        titleLabel.text = "Items"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let searchBar = UISearchBar()
        searchBar.placeholder = "Search items"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(titleLabel)
        headerView.addSubview(searchBar)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),

            searchBar.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            searchBar.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])

        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func showToast(message : String, font: UIFont)
    {
        DispatchQueue.main.async{
            let toastLabel = UILabel()
            toastLabel.backgroundColor = UIColor.systemBlue
            toastLabel.textColor = UIColor.white
            toastLabel.font = font
            toastLabel.textAlignment = .center
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 30
            toastLabel.clipsToBounds = true
            toastLabel.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.addSubview(toastLabel)
            
            NSLayoutConstraint.activate([
                toastLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                toastLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100),
                toastLabel.widthAnchor.constraint(equalToConstant: 300),
                toastLabel.heightAnchor.constraint(equalToConstant: 75)
            ])
            
            UIView.animate(
                withDuration: 5.0,
                delay: 0.1,
                options: .curveEaseInOut,
                animations: {
                    toastLabel.alpha = 0.0
                },
                completion: { _ in
                    toastLabel.removeFromSuperview()
                }
            )
        }
    }
}
