import UIKit

class CustomCell: UITableViewCell
{
    let nameLabel = UILabel()
    let skuLabel = UILabel()
    let descLabel = UILabel()
    let rateLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        skuLabel.font = UIFont.systemFont(ofSize: 14)
        skuLabel.textColor = .darkGray

        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.textColor = .black

        descLabel.font = UIFont.systemFont(ofSize: 12)
        descLabel.textColor = .gray

        rateLabel.font = UIFont.boldSystemFont(ofSize: 13)
        rateLabel.textColor = .black
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(skuLabel)
        contentView.addSubview(descLabel)
        contentView.addSubview(rateLabel)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        skuLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        rateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            descLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            descLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            skuLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            skuLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            rateLabel.topAnchor.constraint(equalTo: skuLabel.bottomAnchor, constant: 10),
            rateLabel.trailingAnchor.constraint(equalTo: skuLabel.trailingAnchor),
            rateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: self.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(item : ItemsList)
    {
        nameLabel.text = item.name
        descLabel.text = item.desc
        skuLabel.text = "SKU: \(item.sku ?? "")"
        rateLabel.text = "Rate: \(String(item.rate))"
    }
}




