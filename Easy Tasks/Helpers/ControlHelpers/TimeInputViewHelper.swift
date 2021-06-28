//
//  TimeInputViewHelper.swift
//  Homework Tasks
//
//  Created by Nikita on 11/8/20.
//

import UIKit
import SnapKit

class TimeInputViewHelper {
    
    var rangeHandler: (String) -> Void = { _ in }
    
    lazy private var timeInputView: TimeInputView? = {
        let inputView = TimeInputView(frame: .zero)
        return inputView
    }()
    
    lazy private var visualEffectView: UIVisualEffectView? = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        return view
    }()
    
    init(with superview: UIView) {
        guard
            let timeInputView = self.timeInputView,
            let visualEffectView = self.visualEffectView else {
            return
        }
        
        superview.addSubview(visualEffectView)
        visualEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        visualEffectView.alpha = 0
        
        superview.addSubview(timeInputView)
        timeInputView.snp.makeConstraints { make in
            make.height.equalTo(300)
            make.top.equalTo(superview.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        addObservers()
    }
    
    func configure(with string: String) {
        self.timeInputView?.configure(for: string)
    }
    
    func show() {
        animateIn(popup: timeInputView, visualEffectView: visualEffectView)
    }
}

extension TimeInputViewHelper {
    private func addObservers() {
        timeInputView?.rangeHandler = { string in
            self.rangeHandler(string)
            animateOut(popup: self.timeInputView, visualEffectView: self.visualEffectView) {
                self.timeInputView = nil
                self.visualEffectView = nil
            }
        }
        timeInputView?.closeHandler = {
            animateOut(popup: self.timeInputView, visualEffectView: self.visualEffectView) {
                self.timeInputView = nil
                self.visualEffectView = nil
            }
        }
    }
}
