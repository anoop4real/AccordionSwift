//
//  AMPGenericObject.swift
//  StackAccordionSwift
//
//  Created by anoopm on 07/05/16.
//  Copyright © 2016 anoopm. All rights reserved.
//

import UIKit

class AMPGenericObject: NSObject {
    
    var name:String?
    var parentName:String?
    var canBeExpanded = false // Bool to determine whether the cell can be expanded
    var isExpanded = false    // Bool to determine whether the cell is expanded
    var level:Int?            // Indendation level of tabelview
    var type:Int?
    var children:[AMPGenericObject] = []
    
    enum ObjectType:Int{
        case OBJECT_TYPE_REGION = 0
        case OBJECT_TYPE_LOCATION
        case OBJECT_TYPE_USERS
    }

}
