//
//  ViewController.swift
//  TableViewSectionApp
//
//  Created by Mohammad Noor on 27/10/24.
//

import UIKit

class ViewController: UIViewController {
    
    var technologies = [["optional", "variable", "table view", "collection", "view", "protocol", "closure", "optional", "variable", "table view", "collection", "view", "protocol", "closure", "optional", "variable", "table view"],
                        ["view", "protocol", "closure"],
                        ["optional", "variable", "table view"],
                        ["view", "protocol", "closure"],
                        ["optional", "variable", "table view", "collection view"],
                        ["view", "protocol", "closure"]]
    
    var selectedCells: [Int : Set<Int>] = [:]
    let selectAllSection = UIButton(type: .system)
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setTableViewFunctionalities()
        updateHeaderAndFooter()
    }
    
    func setTableViewFunctionalities() {
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.dropDelegate = self
        self.tableView.dragDelegate = self
        self.tableView.dragInteractionEnabled = true
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func updateHeaderAndFooter() {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60))
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 250))
        
        headerView.backgroundColor = .systemBackground
        
        selectAllSection.setTitle(isAllSecSelected() ? "DeSelect All" : "Select All", for: .normal)
        selectAllSection.setTitleColor(.white, for: .normal)
        selectAllSection.backgroundColor = .systemBlue  // Optional: To make the button filled
        selectAllSection.frame = CGRect(x: headerView.frame.width - 110, y: 10, width: 100, height: 40)
        selectAllSection.layer.cornerRadius = 10
        selectAllSection.autoresizingMask = [.flexibleLeftMargin]  // Ensure it stays on the right side when the header resizes
        selectAllSection.addTarget(self, action: #selector(selectAllSectionButtonTap), for: .touchUpInside)
        
        headerView.addSubview(selectAllSection)
        tableView.tableHeaderView = headerView
        
        footerView.backgroundColor = .systemRed
        
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView
    }
    
    func isAllSecSelected()-> Bool {
        return technologies.indices.allSatisfy { isAllSelected($0) }
    }
    
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return technologies[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = technologies[indexPath.section][indexPath.row]
        cell.backgroundColor = .systemTeal
        //cell.accessoryType = (selectedCells[indexPath] ?? false) ? .checkmark : .none
        
        var isSelected : Bool = false
        if(selectedCells[indexPath.section] != nil && selectedCells[indexPath.section]!.contains(indexPath.row))
        {
            isSelected = true
        }
        cell.accessoryType = (isSelected) ? .checkmark : .none
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        technologies.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        "section \(section)"
    //    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionView = UIView()
        sectionView.backgroundColor = .brown
        
        let sectionHeaderImage = UIImage(named: "scene111")
        let sectionHeaderImageView = UIImageView(image: sectionHeaderImage)
        sectionHeaderImageView.frame = CGRect(x: 3, y: 10, width: 30, height: 20)
        sectionView.addSubview(sectionHeaderImageView)
        
        let sectionHeaderLabel = UILabel()
        sectionHeaderLabel.text = "section \(section+1)"
        sectionHeaderLabel.textColor = .white
        sectionHeaderLabel.font = UIFont.boldSystemFont(ofSize: 20)
        sectionHeaderLabel.frame = CGRect(x: 43, y: 5, width: 250, height: 30)
        sectionView.addSubview(sectionHeaderLabel)
        
        let selectAllButton = UIButton(type: .system)
        selectAllButton.translatesAutoresizingMaskIntoConstraints = false  // Enable Auto Layout
        selectAllButton.tag = section
        selectAllButton.setTitle(isAllSelected(section) ? "Deselect All" : "Select All", for: .normal)
        selectAllButton.tintColor = .white
        selectAllButton.backgroundColor = .systemBlue  // Filled background color
        selectAllButton.layer.cornerRadius = 10
        selectAllButton.addTarget(self, action: #selector(selectAllButtonTap), for: .touchUpInside)
        sectionView.addSubview(selectAllButton)
        
        NSLayoutConstraint.activate([
            selectAllButton.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor, constant: -16), // Right side with some padding
            selectAllButton.centerYAnchor.constraint(equalTo: sectionView.centerYAnchor),                  // Center vertically
            selectAllButton.widthAnchor.constraint(equalToConstant: 100),                                  // Set width
            selectAllButton.heightAnchor.constraint(equalToConstant: 30)                                   // Set height
        ])
        
        return sectionView
    }
    
    
    
    func isAllSelected(_ section: Int) -> Bool {
        
        return selectedCells[section]?.count == technologies[section].count
    }
    
}

extension ViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if selectedCells[indexPath.section] == nil {
            selectedCells[indexPath.section] = [indexPath.row]
        }
        else if selectedCells[indexPath.section]?.contains(indexPath.row) ?? false {
            selectedCells[indexPath.section]?.remove(indexPath.row)
        }
        else {
            selectedCells[indexPath.section]?.insert(indexPath.row)
        }
        
        //tableView.cellForRow(at: indexPath)?.accessoryType = (selectedCells[indexPath.section]!.contains(indexPath)) ? .checkmark : .none
        print(selectedCells)
        
        tableView.reloadSections([indexPath.section], with: .automatic)
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectAllSection.setTitle(isAllSecSelected() ? "Deselect All" : "Select All", for: .normal)
    }
    
    @objc func selectAllButtonTap(_ sender: UIButton) {
        
        let section = sender.tag
        let isAllSelected = isAllSelected(section)
        
        selectAll(section: section, isSelect: isAllSelected)
        
        selectAllSection.setTitle(isAllSecSelected() ? "Deselect All" : "Select All", for: .normal)
    }
    
    @objc func selectAllSectionButtonTap() {
        
        let x = isAllSecSelected()
        
        for sec in 0..<technologies.count
        {
            selectAll(section : sec, isSelect : x)
        }
        
        selectAllSection.setTitle(isAllSecSelected() ? "Deselect All" : "Select All", for: .normal)
    }
    
    func selectAll ( section: Int,  isSelect: Bool)
    {
        
        if isSelect
        {
            selectedCells[section] = nil
        }
        else
        {
            for row in 0..<technologies[section].count {
                
                if selectedCells[section] == nil {
                    selectedCells[section] = [row]
                }
                else
                {
                    selectedCells[section]?.insert(row)
                }
            }
        }
        
        tableView.reloadSections([section], with: .automatic)
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //is used to create a "Delete" action.
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            
            guard let self = self else { return } //unwrapping the weak
            
            self.technologies[indexPath.section].remove(at: indexPath.row)
            
            updateSelectedCellDrop(indexPath: indexPath)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            self.selectAllSection.setTitle(self.isAllSecSelected() ? "Deselect All" : "Select All", for: .normal)
            
            completionHandler(true) //finalizes the deletion and dismisses the swipe action.
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false // will show a delete action button before deleting if its false
        
        return configuration
    }
    
    
}

extension ViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = self.technologies[indexPath.section][indexPath.row]
        let itemProider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProider)
        dragItem.localObject = indexPath
        return [dragItem]
    }
}

extension ViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, performDropWith coordinator: any UITableViewDropCoordinator) {
        
        guard let destinationIndexPath = coordinator.destinationIndexPath else {
            return
        }
        
        for item in coordinator.items {
            guard let sourceIndexPath = item.dragItem.localObject as? IndexPath else {
                continue
            }
            
            tableView.performBatchUpdates({
                let movedItem = technologies[sourceIndexPath.section].remove(at: sourceIndexPath.row)
                
                technologies[destinationIndexPath.section].insert(movedItem, at:destinationIndexPath.row)
                
                if selectedCells[sourceIndexPath.section] != nil && selectedCells[sourceIndexPath.section]!.contains(sourceIndexPath) {
                    updateSelectedCellDrop(indexPath: sourceIndexPath)
                    insertDestCell(indexPath: destinationIndexPath)
                }
                
                tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
                tableView.insertRows(at: [destinationIndexPath], with: .automatic)
            })
        }
        tableView.reloadData()
        //print(technologies)
    }
    
    func updateSelectedCellDrop(indexPath: IndexPath)
    {
        guard var selectedSet = selectedCells[indexPath.section] else {
            return
        }
        
        if selectedSet.contains(indexPath.row) {
            selectedSet.remove(indexPath.row)
        }
        
        let updatedSet = selectedSet.map {
            $0 > indexPath.row ? $0 - 1 : $0
        }
        selectedCells[indexPath.section] = Set(updatedSet).isEmpty ? nil : Set(updatedSet)
    }
    
    
    func insertDestCell(indexPath: IndexPath) {
        if selectedCells[indexPath.section] == nil {
            selectedCells[indexPath.section] = [indexPath.row]
            return
        }
        
        var updatedSet = selectedCells[indexPath.section]!.map {
            $0 >= indexPath.row ? $0 + 1 : $0
        }
        
        updatedSet.append(indexPath.row)
        
        
        selectedCells[indexPath.section] = Set(updatedSet)
    }
    
    
    func tableView(_ tableView: UITableView, canHandle session: any UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
        //method ensures that only NSString types can be dragged and dropped in the table view
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        //provides a drop proposal specifying that the operation is a move action and items should be inserted at the destination indexPath
    }
    
}
