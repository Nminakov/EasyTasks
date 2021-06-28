//
//  LessonInputViewHelper.swift
//  Homework Tasks
//
//  Created by Nikita on 25.10.2020.
//

import UIKit
import SnapKit

class LessonInputViewHelper {
    var resultHandler: (_ color: UIColor, _ name: String) -> Void = { _, _ in }
    
    lazy private var lessonInputView: LessonInputView? = {
        let inputView = LessonInputView(frame: .zero)
        return inputView
    }()
    
    lazy private var visualEffectView: UIVisualEffectView? = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        return view
    }()
    
    init(with superview: UIView) {
        guard
            let lessonInputView = self.lessonInputView,
            let visualEffectView = self.visualEffectView else {
            return
        }
        
        superview.addSubview(visualEffectView)
        visualEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        visualEffectView.alpha = 0
        
        superview.addSubview(lessonInputView)
        lessonInputView.snp.makeConstraints { make in
            make.height.equalTo(230)
            make.top.equalTo(superview.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        addObservers()
    }
    
    func show() {
        animateIn(popup: lessonInputView, visualEffectView: visualEffectView)
    }
}

extension LessonInputViewHelper {
    private func addObservers() {
        lessonInputView?.resultHandler = { color, name in
            self.resultHandler(color, name)
            animateOut(popup: self.lessonInputView, visualEffectView: self.visualEffectView) {
                self.lessonInputView = nil
                self.visualEffectView = nil
            }
        }
        lessonInputView?.closeHandler = {
            animateOut(popup: self.lessonInputView, visualEffectView: self.visualEffectView) {
                self.lessonInputView = nil
                self.visualEffectView = nil
            }
        }
    }
}
