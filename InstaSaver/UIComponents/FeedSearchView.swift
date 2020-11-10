//
//  FeedSearchView.swift
//  InstaSaver
//
//  Created by Кирилл on 28.10.2020.
//

import UIKit
import RxSwift
import RxCocoa

class FeedSearchView: UIView, ContentViewProtocol {
	let bag = DisposeBag()
	required init() {
		super.init(frame: .zero)
		addViews()
		setupConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func addViews() {
		self.addSubview(backButton)
		self.addSubview(textField)
		
		backButton.layer.opacity = 0
	}
	
	func setupConstraints() {
		var const = NSLayoutConstraint()
		backButton.snp.makeConstraints { (make) in
			const = make.left.equalToSuperview().offset(-35).constraint.layoutConstraints.first ?? const
			make.top.bottom.equalToSuperview()
			make.width.equalTo(30)
		}
		textField.snp.makeConstraints { (make) in
			make.left.equalTo(backButton.snp.right).offset(15)
			make.top.right.bottom.equalToSuperview()
		}
		
		let subj = PublishSubject<Float>()
		self.textField.textfield.rx.controlEvent(.editingDidBegin).map {_ in  return Float(1) }.bind(to: subj).disposed(by: bag)
		self.textField.textfield.rx.controlEvent(.editingDidEnd).map {_ in return Float(0) }.bind(to: subj).disposed(by: bag)
		subj.subscribe({ (e) in
			UIView.animate(withDuration: 0.3) {
				const.constant = (CGFloat(e.element ?? 0) - 1)*(self.backButton.frame.width+15)
				self.backButton.layer.opacity = Float(e.element ?? 0)
				self.superview?.layoutIfNeeded()
			}
		}).disposed(by: bag)
		
		backButton.rx.tap.subscribe { (_) in
			self.textField.textfield.text = nil
			self.textField.textfield.resignFirstResponder()
		}.disposed(by: bag)
	}
	
	public var RXbutton: Reactive<UIButton> {self.backButton.rx}
	public var RXtextfield: Reactive<UITextField> {self.textField.textfield.rx}
	
	private let backButton: UIButton = {
		let btn = UIButton(frame: .zero)
		btn.setImage(Asset.Icons.arrowBack.image.withRenderingMode(.alwaysTemplate), for: .normal)
		btn.imageView?.tintColor = Asset.Colors.black4.color
		btn.imageView?.snp.removeConstraints()
		btn.imageView?.snp.makeConstraints({ (make) in
			make.height.equalTo(28)
			make.center.equalToSuperview()
		})
		return btn
	}()
	private var textField = ISTextField()
	
}
