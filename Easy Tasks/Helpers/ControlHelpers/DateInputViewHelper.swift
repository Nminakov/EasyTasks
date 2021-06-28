//
//  DateInputViewHelper.swift
//  Homework Tasks
//
//  Created by Nikita on 11/8/20.
//

import UIKit
import SnapKit

class DateInputViewHelper {
    
    var dateHandler: (Date) -> Void = { _ in }
    
    lazy private var dateInputView: DateInputView? = {
        let inputView = DateInputView(frame: .zero)
        return inputView
    }()
    
    lazy private var visualEffectView: UIVisualEffectView? = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        return view
    }()
    
    init(with superview: UIView) {
        guard let dateInputView = self.dateInputView, let visualEffectView = self.visualEffectView else {
            return
        }
        
        superview.addSubview(visualEffectView)
        visualEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        visualEffectView.alpha = 0
        
        superview.addSubview(dateInputView)
        dateInputView.snp.makeConstraints { make in
            make.height.equalTo(300)
            make.top.equalTo(superview.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        addObservers()
    }
    
    func configure(with date: Date) {
        dateInputView?.configure(with: date)
    }
    
    func show() {
        animateIn(popup: dateInputView, visualEffectView: visualEffectView)
    }
}

extension DateInputViewHelper {
    private func addObservers() {
        dateInputView?.dateHandler = { date in
            self.dateHandler(date)
            animateOut(popup: self.dateInputView, visualEffectView: self.visualEffectView) {
                self.dateInputView = nil
                self.visualEffectView = nil
            }
        }
        dateInputView?.closeHandler = {
            animateOut(popup: self.dateInputView, visualEffectView: self.visualEffectView) {
                self.dateInputView = nil
                self.visualEffectView = nil
            }
        }
    }
}
