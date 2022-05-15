//
//  CustomTableViewCell.swift
//  ToDoList
//
//  Created by Bohdan on 15.05.2022.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    static let id = "CustomCell"
    
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
