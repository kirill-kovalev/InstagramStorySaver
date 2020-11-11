//
//  Login.swift
//  InstaSaver
//
//  Created by Кирилл on 08.11.2020.
//

import UIKit
import WebKit

import RxSwift

import ComposableRequestCrypto
import Swiftagram
import SwiftagramCrypto

class LoginViewController: UIViewController {
	/// The completion handler.
	
	/// The web view.
	var webView: WKWebView? {
		didSet {
			guard let webView = webView else { return }
			webView.frame = view.frame
			view.addSubview(webView)
		}
	}
	
	var bag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		ISAPI.needsAuth.subscribe(onNext: { [weak self] in
			if !$0 {self?.dismiss(animated: true, completion: nil)}
		}).disposed(by: bag)
		// Authenticate.
		WebViewAuthenticator(storage: ComposableRequestCrypto.KeychainStorage<Secret>()) {
			self.webView = $0
		}.authenticate {
			switch $0 {
				case .failure(let error): print(error.localizedDescription)
					
				case .success(let secret):
					ISAPI.auth(secret)
			}
		}
	}
	
}
