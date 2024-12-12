import UIKit

protocol ItemCreationDelegate
{
    func displayItem(itemToBeDisplayed : ItemsList)
    
    func updateItem(itemId : String, itemToBeDisplayed: ItemsList)
}

class CreateItemVC : UIViewController
{
    let manageObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let networkCall = NetworkCall()
    
    var delegate : ItemCreationDelegate?
    
    var itemToEdit : ItemsList?
    
    let titleLabel = UILabel()
    
    let nameL = UILabel()
    let descL = UILabel()
    let skuL = UILabel()
    let rateL = UILabel()
    
    var goBackButton = UIButton()
    var name = UITextField()
    var desc = UITextField()
    var sku = UITextField()
    var rate = UITextField()
    
    var submit = UIButton()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        print("View did load")
        
        view.backgroundColor = .systemBackground
        
        view.contentMode = .scaleToFill
        
        setUpCreation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        submit.isEnabled = true
        submit.backgroundColor = .systemBlue
        name.text = ""
        desc.text = ""
        sku.text = ""
        rate.text = ""
    }
    
    func setUpCreation()
    {
        titleLabel.text = "ITEM CREATION"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        titleLabel.textColor = .black
        view.addSubview(titleLabel)
        
        goBackButton.setTitle("Back", for: .normal)
        goBackButton.tintColor = .systemBlue
        goBackButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        goBackButton.translatesAutoresizingMaskIntoConstraints = false
        goBackButton.addTarget(self, action: #selector(goBackButtonPressed), for: .touchUpInside)
        view.addSubview(goBackButton)
        
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.layer.cornerRadius = 10
        submit.setTitle("Submit", for: .normal)
        submit.backgroundColor = .systemBlue
        submit.tintColor = .black
        submit.isEnabled = true
        submit.addTarget(
            self,
            action: #selector(submitPressed),
            for: .touchUpInside
        )
        
        [name, desc, sku, rate].forEach
        {
            textfield in
            textfield.translatesAutoresizingMaskIntoConstraints = false
            textfield.backgroundColor = .white
            textfield.textColor = .black
            textfield.textAlignment = .center
            textfield.layer.cornerRadius = 10
            textfield.layer.borderWidth = 0.7
            textfield.layer.borderColor = UIColor.black.cgColor
            textfield.widthAnchor.constraint(equalToConstant: 200).isActive = true
            view.addSubview(textfield)
        }
        
        [nameL, descL, skuL, rateL].forEach
        {
            label in
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = .black
            view.addSubview(label)
            label.font = .systemFont(ofSize: 18)
            label.adjustsFontSizeToFitWidth = true
        }
        
        nameL.text = "Name: "
        descL.text = "Description: "
        skuL.text = "SKU: "
        rateL.text = "Selling Price: "
        
        let nameHorizontal = UIStackView(arrangedSubviews: [nameL, name])
        let descHorizontal = UIStackView(arrangedSubviews: [descL, desc])
        let rateHorizontal = UIStackView(arrangedSubviews: [rateL, rate])
        let skuHorizontal = UIStackView(arrangedSubviews: [skuL, sku])
        
        [nameHorizontal, descHorizontal, rateHorizontal, skuHorizontal].forEach
        {
            stackView in
            stackView.axis = .horizontal
            stackView.distribution = .fill
            stackView.spacing = 40
            stackView.alignment = .fill
            stackView.layer.masksToBounds = true
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            stackView.widthAnchor.constraint(equalToConstant: 350).isActive = true
            stackView.heightAnchor.constraint(equalToConstant: 75).isActive = true
            
            view.addSubview(stackView)
        }
        
        let stackView = UIStackView(
            arrangedSubviews: [nameHorizontal, descHorizontal, skuHorizontal, rateHorizontal, submit]
        )
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.layer.masksToBounds = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        stackView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        NSLayoutConstraint.activate([
            goBackButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            goBackButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func showToast(message : String, font: UIFont)
    {
        DispatchQueue.main.async {
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
                options: [],
                animations: {
                    toastLabel.alpha = 0.0
                },
                completion: { _ in
                    toastLabel.removeFromSuperview()
                }
            )
        }
    }
    
    @objc func submitPressed()
    {
        if let itemToEdit = itemToEdit
        {
            itemToEdit.name = name.text
            itemToEdit.desc = desc.text
            itemToEdit.sku = sku.text
            
            if let rateText = rate.text, let rateValue = Int64(rateText)
            {
                itemToEdit.rate = rateValue
            }
            if name.text != "" && rate.text != ""
            {
                networkCall.postDataAndPutData(methodPerformed : "PUT", messagePassed: itemToEdit)
                { [self]
                    messagePassed in
                    DispatchQueue.main.async
                    {
                        self.dismiss(animated: true, completion: nil)
                    }
                    self.delegate?.updateItem(
                        itemId: messagePassed.item_id ?? "",
                        itemToBeDisplayed : itemToEdit
                    )
                }
                
            }
            else
            {
                self.showToast(message: "Enter the Item ID or Item Rate", font: .systemFont(ofSize: 16.0))
            }
        }
        else
        {
            let itemToBeAdded = ItemsList(context: self.manageObjectContext)
            itemToBeAdded.name = name.text
            itemToBeAdded.desc = desc.text
            itemToBeAdded.sku = sku.text
            
            if let rateText = rate.text, let rateValue = Int64(rateText)
            {
                itemToBeAdded.rate = rateValue
            }
            
            try! self.manageObjectContext.save()
            
            if name.text != "" && rate.text != "" && sku.text != ""
            {
                networkCall.postDataAndPutData(
                    methodPerformed : "POST",
                    messagePassed: itemToBeAdded
                )
                {
                    messagePassed in
                    
                    self.delegate?.displayItem(
                        itemToBeDisplayed: messagePassed
                    )
                    self.showToast(
                        message: "Item added successfully !!!",
                        font: .systemFont(ofSize: 16.0)
                    )
                }
                
                submit.isEnabled = true
                submit.backgroundColor = .systemBlue
                name.text = ""
                desc.text = ""
                sku.text = ""
                rate.text = ""
                
            }
            else
            {
                self.showToast(message: "Enter the specified Details to proceed with submission", font: .systemFont(ofSize: 16.0))
            }
        }
    }
    
    @objc func goBackButtonPressed()
    {
        tabBarController?.selectedIndex = 0
    }
    
}
