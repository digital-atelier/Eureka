//
//  SamExampleViewController.swift
//  Example
//
//  Created by Sam Dean on 04/05/2018.
//  Copyright © 2018 Xmartlabs. All rights reserved.
//

import Foundation
import UIKit

import Eureka

// Fake customer data - I guess this would be the view model passed out from the ViewModel layer (I'm assuming MVVM, obvs)
struct CustomerViewModel {

    struct Comment {
        let date: String
        let value: String
    }

    let title: String? = "MR"
    let firstName = "TOM"
    let surname = "ARNOLD"

    let comments = [
        Comment(date: "10/7/2018", value: "He is a property developer"),
        Comment(date: "10/4/2018", value: "He will be opn holiday Nov 2017 - Jan 2018 -- loves brown leather")
    ]
}

final class SamExampleViewController: FormViewController {

    let stylist = Stylist()

    var customer: CustomerViewModel? {
        didSet {
            guard let customer = self.customer else {
                return
            }

            UIView.performWithoutAnimation {

                let detailsSection = Section()

                <<< LabelRow() {
                    $0.title = "ABOUT \(customer.firstName)"
                    $0.value = "EDIT"
                    }.onCellSelection { cell, row in
                        print("Go to EDIT for \(customer.firstName)")
                }

                self.form.removeAll(keepingCapacity: true)

                if let prefix = customer.title {
                    detailsSection <<< TwoColumnRow {
                        $0.value = [ ColumnContent(title: "PREFIX", value: prefix) ]
                    }
                }

                detailsSection <<< TwoColumnRow {
                        $0.value = [ ColumnContent(title: "FIRST NAME", value: customer.firstName),
                                     ColumnContent(title: "LAST NAME", value: customer.surname) ]
                    }

                self.form +++ detailsSection


                self.form +++
                    Section()

                    <<< LabelRow() {
                        $0.title = "WHO IS \(customer.firstName)"
                        $0.value = "ADD"
                        }.onCellSelection { cell, row in
                            print("Go to ADD COMMENT for \(customer.firstName)")
                    }

                for comment in customer.comments {
                    form.last! <<< LabelRow {
                        $0.title = comment.value

                        let moreAction = SwipeAction(style: .normal, title: "EDIT", handler: { (action, row, completionHandler) in
                            print("EDIT \(comment)")
                            completionHandler?(true)
                        })

                        let deleteAction = SwipeAction(style: .destructive, title: "DELETE") { (action, row, completionHandler) in
                            print("DELETE \(comment)")
                            completionHandler?(true)
                        }

                        $0.trailingSwipe.actions = [deleteAction,moreAction]
                    }
                }

                let products = [Product(title: "TAG HEUER CARRERA",
                                       price: "5,630,00€",
                                       description: "43 MM BLUE DIAL WITH STEEL STRAP"),
                                Product(title: "TAG HEUER FORMULA 1",
                                        price: "4,930,00€",
                                        description: "43 MM BLACK DIAL WITH STEEL STRAP")]



                let purchases = [PurchaseHistoryContent(date: "17/09/2012",
                                                        totalPrice: "120.2€",
                                                        store: "There",
                                                        products: products),
                                 PurchaseHistoryContent(date: "12/12/2012",
                                                        totalPrice: "1000.0€",
                                                        store: "There",
                                                        products: products),
                                 PurchaseHistoryContent(date: "13/01/2014",
                                                        totalPrice: "500.0€",
                                                        store: "Here",
                                                        products: []),
                                 PurchaseHistoryContent(date: "17/09/2016",
                                                        totalPrice: "420.90€",
                                                        store: "There",
                                                        products: products)]
                //Add purchases history section
                for purchase in purchases {
                    form.last! <<< PurchaseHistoryRow() {
                        $0.value = purchase
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60

        self.form.inlineRowHideOptions = InlineRowHideOptions.Never

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.customer = CustomerViewModel()
        }
    }

    override func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {
        self.style(rows: rows)

        super.rowsHaveBeenAdded(rows, at: indexes)
    }

    override func sectionsHaveBeenAdded(_ sections: [Section], at indexes: IndexSet) {
        self.style(rows: sections.map { Array($0) }.flatMap { $0 })

        super.sectionsHaveBeenAdded(sections, at: indexes)
    }

    private func style(rows: [BaseRow]) {
        let stylables = rows.compactMap { $0.baseCell as? StylableCell }

        stylables.forEach {
            $0.style(with: self.stylist)
        }
    }
}

protocol StylableCell {
    func style(with stylist: Stylist)
}

final class TwoColumnRow: Row<TwoColumnCell>, RowType {

    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<TwoColumnCell>(nibName: "TwoColumnCell")
    }
}

// TODO: There is scope for abstraction here ;)
final class TwoColumnCell: Cell<[ColumnContent]>, CellType, StylableCell {

    @IBOutlet var title1: UILabel!
    @IBOutlet var label1: UILabel!
    @IBOutlet var title2: UILabel!
    @IBOutlet var label2: UILabel!

    override func update() {
        super.update()

        self.contents = self.row.value ?? []
    }

    var contents: [ColumnContent] = [] {
        didSet {
            title1.text = nil
            label1.text = nil
            title2.text = nil
            label2.text = nil

            if let content = contents.first {
                title1.text = content.title
                label1.text = content.value
            }

            if contents.count > 1 {
                let content = contents[1]
                title2.text = content.title
                label2.text = content.value
            }
        }
    }

    func style(with stylist: Stylist) {
        self.title1.font = stylist.titleFont
        self.title2.font = stylist.titleFont

        self.label1.font = stylist.bodyFont
        self.label2.font = stylist.bodyFont

        self.title1.textColor = stylist.titleColor
        self.title2.textColor = stylist.titleColor

        self.label1.textColor = stylist.bodyColor
        self.label2.textColor = stylist.bodyColor
    }
}

final class ThreeColumnCell: Cell<PurchaseHistoryContent>, CellType, StylableCell {
    func style(with stylist: Stylist) {
        self.dateLabel.font = stylist.bodyFont
        self.amountLabel.font = stylist.bodyFont
        self.storeLabel.font = stylist.bodyFont
    }

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var storeLabel: UILabel!
    @IBOutlet weak var expandButton: UIButton!

    @IBAction func buttonPressed(_ sender: Any) {
        guard let inline = self.row as? PurchaseHistoryRow else {
            return
        }
        inline.toggleInlineRow()

    }

    func refresh(isExpanded: Bool) {
        self.expandButton.isSelected = isExpanded
    }

    override func update() {
        super.update()
        self.contents = self.row.value!
    }

    var contents: PurchaseHistoryContent! {
        didSet {
            dateLabel.text = contents.date
            amountLabel.text = contents.totalPrice
            storeLabel.text = contents.store
        }
    }

}

struct ColumnContent: Equatable {
    let title: String
    let value: String
}

// Mock the stylist architecture here

struct Stylist {

    let titleFont = UIFont(name: "Menlo-Regular", size: 12)
    let titleColor = UIColor.gray

    let bodyFont = UIFont(name: "Menlo-Regular", size: 14)
    let bodyColor = UIColor.black

    let accessoryFont = UIFont(name: "Menlo-Regular", size: 14)
    let accessoryColor = UIColor.red
}

// We can make the Eureka cells use the stylist as well, which is nice

extension LabelCellOf: StylableCell {

    func style(with stylist: Stylist) {
        self.textLabel?.font = stylist.bodyFont
        self.textLabel?.textColor = stylist.bodyColor

        self.detailTextLabel?.font = stylist.accessoryFont
        self.detailTextLabel?.textColor = stylist.accessoryColor
    }
}

struct PurchaseHistoryContent: Equatable {
    let date: String
    let totalPrice: String
    let store: String
    let products: [Product]

}

struct Product: Equatable {
    let title: String
    let price: String
    let description: String
}


final class PurchaseHistoryRow: Row<ThreeColumnCell>, RowType, InlineRowType {

    func setupInlineRow(_ inlineRow: PurchaseHistoryDetailsRow) {
        print("setup inline row")
    }

    typealias InlineRow = PurchaseHistoryDetailsRow

    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<ThreeColumnCell>(nibName: "ThreeColumnCell")
        onExpandInlineRow { cell, row, _ in
            cell.refresh(isExpanded: true)
        }

        onCollapseInlineRow { cell, row, _ in
            cell.refresh(isExpanded: false)
        }
    }

    public override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            toggleInlineRow()
        }
    }
}


final class PurchaseHistoryDetailsRow: Row<PurchaseHistoryDetailsCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<PurchaseHistoryDetailsCell>(nibName: "PurchaseHistoryDetailsCell")
    }
}


final class PurchaseHistoryDetailsCell: Cell<PurchaseHistoryContent>, CellType, StylableCell {

    func style(with stylist: Stylist) {
        self.stylist = stylist
    }


    @IBOutlet weak var stackView: UIStackView!
    var stylist: Stylist!

    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        accessoryType = .none
        editingAccessoryType =  .none
    }

    open override func update() {
        super.update()
        selectionStyle = row.isDisabled ? .none : .default
        self.contents = self.row.value
    }

    open override func didSelect() {
        super.didSelect()
        row.deselect()
    }

    var contents: PurchaseHistoryContent! {
        didSet {
            let products = self.contents.products
            for product in products {
                let view = Bundle.main.loadNibNamed("SinglePurchaseView",
                                         owner: nil,
                                         options: nil)!.first as! SinglePurchaseView

                view.stylist = self.stylist
                view.configure(with: product)
                view.translatesAutoresizingMaskIntoConstraints = false
                self.stackView.addArrangedSubview(view)
            }
        }
    }
}

final class SinglePurchaseView: UIView {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    var stylist: Stylist! {
        didSet {
            titleLabel.font = stylist.titleFont
            descriptionLabel.font = stylist.bodyFont
            priceLabel.font = stylist.accessoryFont
        }
    }

    func configure(with product: Product) {
        self.titleLabel.text = product.title
        self.descriptionLabel.text = product.description
        self.priceLabel.text = product.price

        self.productImageView.image = UIImage(named: "AppIcon")
    }
}
