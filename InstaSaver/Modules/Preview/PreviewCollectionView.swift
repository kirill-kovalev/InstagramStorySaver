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
	private let gestureZone = UIView(frame: .zero)
	let gesture = UIPanGestureRecognizer()
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
		gestureZone.addGestureRecognizer(gesture)
		self.addSubview(gestureZone)
		self.addSubview(pageIndicator)
		self.addSubview(backButton)
	}
	private func setupConstraints() {
		gestureZone.snp.makeConstraints {
			$0.top.left.right.width.equalTo(frameLayoutGuide)
			$0.bottom.equalTo(frameLayoutGuide).dividedBy(3)
		}
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
	private var looper: AVPlayerLooper!
	var url: URL? {
		didSet {
			downloadButton.isHidden = true
			downloadIndidcator.isHidden = false
			if let url = url {
				let item = AVPlayerItem(url: url)
				looper = AVPlayerLooper(player: player, templateItem: item)
				player.replaceCurrentItem(with: item)
				playerLayer.player = self.player
				downloadButton.isHidden = false
				downloadIndidcator.isHidden = true
			}
		}
	}
	var player: AVQueuePlayer = AVQueuePlayer()
	
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
	
	weak var exportDelegate: ExportDelegateProtocol?
}
protocol ExportDelegateProtocol: UIViewController {
	func export(items: [Any])
}
extension ExportDelegateProtocol {
	func export(items: [Any]) {
		let actionVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
		if UserDefaults.standard.bool(forKey: "skip") {
			self.present(actionVC, animated: true, completion: nil)
		} else {
			let alert = UIAlertController(title: nil, message: "Now you can copy and share it in your stories or post!", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
				self.present(actionVC, animated: true, completion: nil)
			}))
			alert.addAction(UIAlertAction(title: "Don't remind", style: .default, handler: { (_) in
				UserDefaults.standard.setValue(true, forKey: "skip")
				self.present(actionVC, animated: true, completion: nil)
			}))
			self.present(alert, animated: true, completion: nil)
		}

	}
}
