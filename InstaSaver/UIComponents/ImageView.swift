//
//  ImageView.swift
//  spendwisor
//
//  Created by Кирилл on 14.01.2021.
//  Copyright © 2021 Cuberto. All rights reserved.
//

import Foundation
import Kingfisher

@IBDesignable
class ImageView: UIImageView {

	@IBInspectable var placeholder: UIImage? {
		didSet {
			if image == nil || image == oldValue {
				image = placeholder
			}
		}
	}
	@IBInspectable var placeholderCenterContentMode: Bool = false {
		didSet {
			contentMode = (placeholderCenterContentMode && image == placeholder) ? .center : defaultContentMode
			if image == nil || image == placeholder {
				image = placeholder
			}
		}
	}
	@IBInspectable var useTransition: Bool = true
	@IBInspectable var keepCurrentImageWhileLoading: Bool = false

	lazy var defaultContentMode: UIView.ContentMode = .scaleAspectFill
	var renderingMode: UIImage.RenderingMode?

	override var image: UIImage? {
		get { return super.image }
		set {
			contentMode = (placeholderCenterContentMode && newValue == placeholder) ? .center : defaultContentMode
			super.image = newValue
		}
	}

	var imageLoadedHandler: (() -> Void)?
	private var downloadTask: DownloadTask?

	var url: URL? {
		willSet {
			guard newValue != url || downloadTask == nil else { return }

			guard let newValue = newValue else {
				image = placeholder
				downloadTask?.cancel()

				return
			}

			var options: KingfisherOptionsInfo = [.keepCurrentImageWhileLoading, .onlyLoadFirstFrame]

			if !keepCurrentImageWhileLoading {
				image = placeholder
			}

			if useTransition { options.append(.transition(.fade(0.15))) }
			if let renderingMode = renderingMode {
				options.append(.imageModifier(AnyImageModifier(modify: { $0.withRenderingMode(renderingMode) })))
			}

			downloadTask?.cancel()
			downloadTask = kf.setImage(
				with: newValue,
				placeholder: nil,
				options: options,
				progressBlock: nil) { [weak self] result in

				guard let strongSelf = self else { return }
				strongSelf.downloadTask = nil

				switch result {
				case .success:
					strongSelf.imageLoadedHandler?()
				case .failure:
					break
				}
			}
		}
	}
}
