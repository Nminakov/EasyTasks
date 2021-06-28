//
//  TaskCell.swift
//  Homework Tasks
//
//  Created by Nikita on 11/7/20.
//

import UIKit

protocol TaskCellDelegate: class {
    func onEditAction(task: TaskModel)
}

class TaskCell: UITableViewCell {
    
    weak var delegate: TaskCellDelegate?
    
    @IBOutlet weak var whiteView: UIView! {
        didSet {
            whiteView.layer.cornerRadius = 10
            whiteView.backgroundColor = .white
        }
    }
    @IBOutlet weak var checkMarkView: UIView! {
        didSet {
            checkMarkView.layer.cornerRadius = 12
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction private func onEdit(_ sender: UIButton) {
        sender.animateTap {
            guard
                let task = self.task else {
                return
            }
            self.delegate?.onEditAction(task: task)
        }
    }
    
    private var task: TaskModel? {
        didSet {
            guard
                let task = task else {
                return
            }
            let colorFinished = #colorLiteral(red: 1, green: 0.3781786561, blue: 0.4905191064, alpha: 1)
            let colorNotFinished = #colorLiteral(red: 0.6955176592, green: 0.7638463378, blue: 0.8163332343, alpha: 1)
            checkMarkView.backgroundColor = task.isFinished ? colorFinished : colorNotFinished
            titleLabel.attributedText = prepare(for: task.name, isFinished: task.isFinished)
        }
    }
    
    func configure(with task: TaskModel) {
        self.task = task
        
        let selectedView = UIView()
        selectedView.backgroundColor = .clear
        self.selectedBackgroundView = selectedView
    }
    
    private func prepare(for text: String, isFinished: Bool) -> NSAttributedString {
        let colorFinished = #colorLiteral(red: 1, green: 0.3781786561, blue: 0.4905191064, alpha: 1)
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: isFinished ? colorFinished : UIColor.black,
                                                         .font: UIFont.systemFont(ofSize: 16)]
        let attributedText = NSMutableAttributedString(string: text, attributes: attributes)
        
        let range = NSRange(location: 0, length: attributedText.length)
        if isFinished {
            attributedText.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        }
        
        return attributedText
    }

}
