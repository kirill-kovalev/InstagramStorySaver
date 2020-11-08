//
//  ViewController.swift
//  InstaSaver
//
//  Created by Кирилл on 19.10.2020.
//

import UIKit
import SnapKit
import RxSwift

class ViewController<ContentView: ContentViewProtocol>: UIViewController {
	var rootView: ContentView {self.view as! ContentView}
	override func loadView() {
		self.view = ContentView()
	}
	
	@available(iOS 13.0, *)
	static var preview: ContainterView<ViewController> {
		ContainterView()
	}
	
}

import SwiftUI
@available(iOS 13.0, *)
struct ContainterView<Controller: UIViewController>: UIViewControllerRepresentable {
	func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
	func makeUIViewController(context: Context) -> some UIViewController {Controller()}
}
@available(iOS 13.0, *)
struct PreviewContainer: UIViewControllerRepresentable {
	var view: UIView
	func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
	func makeUIViewController(context: Context) -> some UIViewController {
		let c = UIViewController()
		c.view.addSubview(self.view)
		view.snp.makeConstraints { (make) in
			make.center.equalToSuperview()
			make.left.top.greaterThanOrEqualToSuperview()
			make.bottom.right.lessThanOrEqualToSuperview()
		}
		return c
	}
}
@available(iOS 13.0, *)
extension UIView {
	static var preview: PreviewContainer {
		PreviewContainer(view: Self.init())
	}
}
