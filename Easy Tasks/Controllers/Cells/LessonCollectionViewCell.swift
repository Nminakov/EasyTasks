//
//  LessonCollectionViewCell.swift
//  Homework Tasks
//
//  Created by Nikita on 17.10.2020.
//

import UIKit

class LessonCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var roundView: UIView! {
        didSet {
            roundView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tasksCountLabel: UILabel!
    
    private var model: LessonModel? {
        didSet {
            guard
                let model = model else {
                return
            }
            self.nameLabel.text = model.name
            self.tasksCountLabel.text = "\(model.tasks.count) задач"
        }
    }
    
    var deleteHandler: (String) -> Void = { _ in }
    
    func configure(for model: LessonModel) {
        self.model = model
        roundView.backgroundColor = color(from: model.color)
        roundView.isUserInteractionEnabled = true
        let interaction = UIContextMenuInteraction(delegate: self)
        roundView.addInteraction(interaction)
    }
    
    private func color(from value: String) -> UIColor {
        if value != "" {
            return value.hexColor
        }
        else {
            return .gray
        }
    }
    
}

extension LessonCollectionViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            return self.makeContextMenu()
        })
    }
    
    func makeContextMenu() -> UIMenu {
        guard
            let id = model?.id else {
            fatalError()
        }
        
        let delete = UIAction(title: "Удалить основную задачу", image: #imageLiteral(resourceName: "delete-icon").scale(to: CGSize(width: 15, height: 15))) { action in
            self.deleteHandler(id)
        }
        return UIMenu(title: "", children: [delete])
    }
    
}
