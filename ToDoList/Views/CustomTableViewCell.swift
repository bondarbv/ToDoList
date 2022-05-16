//
//  CustomTableViewCell.swift
//  ToDoList
//
//  Created by Bohdan on 15.05.2022.
//

import UIKit
import SnapKit

class CustomTableViewCell: UITableViewCell {
    
    static let id = "CustomCell"
    
    let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    let button: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle"), for: .selected)
        button.tintColor = .systemGreen
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        button.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layout() {
        contentView.addSubview(label)
        contentView.addSubview(button)
        
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalTo(button.snp.leading).inset(-10).priority(.required)
            make.centerY.equalToSuperview()
        }
        
        button.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(35)
            make.centerY.equalToSuperview()
        }
    }
    
}
