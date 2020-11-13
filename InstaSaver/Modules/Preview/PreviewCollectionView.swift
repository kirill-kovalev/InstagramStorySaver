//
//  PreviewCollectionView.swift
//  InstaSaver
//
//  Created by Кирилл on 09.11.2020.
//

import UIKit
import AVKit
import Photos

class PreviewCollectionView: UICollectionView {
	let backButton: UIButton = {
		let btn = UIButton(frame: .zero)
		btn.setImage(Asset.Icons.arrowBack.image.withRenderingMode(.alwaysTemplate), for: .normal)
		btn.imageView?.tintColor = Asset.Colors.purple.color
		return btn
	}()
		
	let pageIndicator: UIPageControl = {
		let c = UIPageControl(frame: .zero)
		c.hidesForSinglePage = true
		c.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
		c.currentPageIndicatorTintColor = Asset.Colors.purple.color
		return c
	}()
		
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	init() {
		let layout = UICollectionViewFlowLayout()
		super.init(frame: .zero, collectionViewLayout: layout)
		layout.scrollDirection = .horizontal
		layout.minimumLineSpacing = 0
		self.isPagingEnabled = true
		self.showsHorizontalScrollIndicator = false
		addViews()
		setupConstraints()
	}
	
	private func addViews() {
		self.addSubview(pageIndicator)
		self.addSubview(backButton)
	}
	private func setupConstraints() {
		backButton.snp.makeConstraints { (make) in
			make.height.width.equalTo(50)
			make.left.equalTo(frameLayoutGuide).offset(30)
			make.top.equalTo(safeAreaLayoutGuide).offset(20)
		}
		pageIndicator.snp.makeConstraints { (make) in
			make.centerX.equalTo(frameLayoutGuide)
			make.bottom.equalTo(frameLayoutGuide).inset(10)
		}
	}
	
}




class PreviewCell: UICollectionViewCell {
	let container: UIImageView = {
		let v = UIImageView(frame: .zero)
		v.contentMode = .scaleAspectFit
		return v
	}()
	let downloadButton: UIButton = {
		let btn = UIButton(frame: .zero)
		btn.setImage(Asset.Icons.downloadFill.image, for: .normal)
		btn.setImage(Asset.Icons.download.image, for: .highlighted)
		btn.isHidden = true
		return btn
	}()
	let downloadIndidcator: UIActivityIndicatorView = {
		let btn = UIActivityIndicatorView(frame: .zero)
		btn.startAnimating()
		btn.style = .whiteLarge
		btn.color = Asset.Colors.purple.color
		return btn
	}()
	
	private let playerLayer = AVPlayerLayer()
	
	var url: URL? {
		didSet {
			if let url = url {
				downloadButton.isHidden = false
				downloadIndidcator.isHidden = true
				self.player = AVPlayer(url: url)
			} else {
				downloadButton.isHidden = true
				downloadIndidcator.isHidden = false
			}
		}
	}
	var player: AVPlayer? {
		didSet {
			oldValue?.pause()
			if let player = player {
				playerLayer.isHidden = false
				playerLayer.player = player
			} else {
				playerLayer.isHidden = true
			}
		}
	}
	
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.contentView.addSubview(container)
		self.container.layer.addSublayer(playerLayer)
		contentView.snp.makeConstraints {
			$0.edges.equalToSuperview()
			$0.edges.equalTo(container)
		}
		self.contentView.addSubview(downloadIndidcator)
		self.contentView.addSubview(downloadButton)
		downloadButton.snp.makeConstraints { (make) in
			make.centerX.equalTo(container)
			make.bottom.equalTo(safeAreaLayoutGuide).inset(35)
			make.width.height.equalTo(50)
		}
		downloadIndidcator.snp.makeConstraints { $0.edges.equalTo(downloadButton)}
		downloadButton.addTarget(self, action: #selector(downloadButtonPressed), for: .touchUpInside)
	}
	
	@objc func downloadButtonPressed(_ sender: Any) {
		if let url = self.url {
			exportDelegate?.export(items: [url])
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		container.frame = contentView.frame
		playerLayer.frame = container.layer.frame
	}
	
	weak var exportDelegate:ExportDelegateProtocol?
}
protocol ExportDelegateProtocol: UIViewController {
	func export(items:[Any])
}
extension ExportDelegateProtocol {
	func export(items:[Any]){
		let actionVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
		self.present(actionVC, animated: true, completion: nil)
	}
}
