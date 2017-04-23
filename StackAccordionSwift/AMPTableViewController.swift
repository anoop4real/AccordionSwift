//
//  AMPTableViewController.swift
//  StackAccordionSwift
//
//  Created by anoopm on 07/05/16.
//  Copyright © 2016 anoopm. All rights reserved.
//

import UIKit

class AMPTableViewController: UITableViewController {
    
    var dataArray:[AMPGenericObject] = []
    var indendationLevel:Int   = 0
    var indendationWidth:CGFloat = 20.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<10 {
            
            let prod = AMPGenericObject()
            prod.name = "Region \(i)"
            prod.parentName = ""
            prod.isExpanded = false
            prod.level = 0;
            prod.type  = 0;
            // Randomly assign canBeExpanded status
            let rem = i % 2
            if(rem == 0)
            {
                prod.canBeExpanded  = true;
            }
            else
            {
                prod.canBeExpanded = false;
            }
            dataArray.append(prod)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let obj = dataArray[indexPath.row]
        // All optionals are ensured to have values, so we can safely unwrap
        cell.textLabel!.text = obj.name!;
        cell.detailTextLabel!.text = obj.parentName!;
        cell.indentationLevel = obj.level!;
        cell.indentationWidth = indendationWidth;
        // Configure the cell...
        // Show disclosure only if the cell can expand
        if(obj.canBeExpanded)
        {
            cell.accessoryView = self.viewForDisclosureForState(obj.isExpanded)
        }
        else
        {
            //cell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryView = nil;
        }

        return cell
    }

    func viewForDisclosureForState(_ isExpanded:Bool)->UIView{
        
        var imageName:String = ""
        if(isExpanded)
        {
            imageName = "ArrowD_blue";
        }
        else
        {
            imageName = "ArrowR_blue";
        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.frame = CGRect(x: 0, y: 6, width: 24, height: 24)
        view.addSubview(imageView)
        return view
    }

    func fetchChildrenforParent(_ parentProduct:AMPGenericObject){
        
        // If canBeExpanded then only we need to create child
        if(parentProduct.canBeExpanded)
        {
            // If Children are already added then no need to add again
            if(parentProduct.children.count > 0){
            return
            }
            // The children property of the parent will be filled with this objects
            // If the parent is of type region, then fetch the location.
            if (parentProduct.type == 0) {
                for i in 0..<10
                {
                    let prod = AMPGenericObject()
                    prod.name = "Location \(i)"
                    prod.level  = parentProduct.level! + 1;
                    prod.parentName = "Child \(i) of Level \(prod.level!)"
                    // This is used for setting the indentation level so that it look like an accordion view
                    prod.type = 1 //OBJECT_TYPE_LOCATION;
                    prod.isExpanded = false;
                    
                    if(i % 2 == 0)
                    {
                        prod.canBeExpanded = true
                    }
                    else
                    {
                        prod.canBeExpanded = false
                    }
                    parentProduct.children.append(prod)
                }
            }
                // If tapping on Location, fetch the users
            else{
                
                for i in 0..<10
                {
                    let prod = AMPGenericObject()
                    prod.name = "User \(i)"
                    prod.level  = parentProduct.level! + 1;
                    prod.parentName = "Child \(i) of Level \(prod.level!)"
                    // This is used for setting the indentation level so that it look like an accordion view
                    prod.type = 1 //OBJECT_TYPE_LOCATION;
                    prod.isExpanded = false;
                    // Users need not expand
                    prod.canBeExpanded = false
                    parentProduct.children.append(prod)
                }
            }
            
        }
    }

    func collapseCellsFromIndexOf(_ prod:AMPGenericObject,indexPath:IndexPath,tableView:UITableView)->Void{
        
        // Find the number of childrens opened under the parent recursively as there can be expanded children also
        let collapseCol = self.numberOfCellsToBeCollapsed(prod)
        // Find the end index by adding the count to start index+1
        let end = indexPath.row + 1 + collapseCol
        // Find the range from the parent index and the length to be removed.
        let collapseRange =  ((indexPath.row+1) ..< end)
        // Remove all the objects in that range from the main array so that number of rows are maintained properly
        dataArray.removeSubrange(collapseRange)
        prod.isExpanded = false
        // Create index paths for the number of rows to be removed
        var indexPaths = [IndexPath]()
        for i in 0..<collapseRange.count {
            indexPaths.append(IndexPath.init(row: collapseRange.lowerBound+i, section: 0))
        }
        // Animate and delete
        tableView.deleteRows(at: indexPaths, with: .left)
        
    }
    
    func expandCellsFromIndexOf(_ prod:AMPGenericObject,indexPath:IndexPath,tableView:UITableView)->Void{
        
        // Create dummy children
        self.fetchChildrenforParent(prod)
        
        
        // Expand only if children are available
        if(prod.children.count>0)
        {
            prod.isExpanded = true
            var i = 0;
            // Insert all the child to the main array just after the parent
            for prodData in prod.children {
                dataArray.insert(prodData, at: indexPath.row+i+1)
                i += 1;
            }
            // Find the range for insertion
            let expandedRange = NSMakeRange(indexPath.row, i)
            
            var indexPaths = [IndexPath]()
            // Create index paths for the range
            for i in 0..<expandedRange.length {
                indexPaths.append(IndexPath.init(row: expandedRange.location+i+1, section: 0))
            }
            // Insert the rows
            tableView.insertRows(at: indexPaths, with: .left)
        }
    }
    
    func numberOfCellsToBeCollapsed(_ prod:AMPGenericObject)->Int{
        
        var total = 0
        
        if(prod.isExpanded)
        {
            // Set the expanded status to no
            prod.isExpanded = false
            let child = prod.children
            total = child.count
            
            // traverse through all the children of the parent and get the count.
            for prodData in child{
                
                total += self.numberOfCellsToBeCollapsed(prodData)
            }
        }
        return total
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let prod = dataArray[indexPath.row]
        let selectedCell = tableView.cellForRow(at: indexPath)
        
        if(prod.canBeExpanded)
        {
            if(prod.isExpanded){
            self.collapseCellsFromIndexOf(prod, indexPath: indexPath, tableView: tableView)
            selectedCell?.accessoryView = self.viewForDisclosureForState(false)
            }
            else{
                self.expandCellsFromIndexOf(prod, indexPath: indexPath, tableView: tableView)
                selectedCell?.accessoryView = self.viewForDisclosureForState(true)
            }
        }

    }

}
