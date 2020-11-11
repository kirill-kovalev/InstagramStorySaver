//
//  PreviewCollectionView.swift
//  InstaSaver
//
//  Created by Кирилл on 09.11.2020.
//

import UIKit
import AVKit

class PreviewCollectionView: UICollectionView {
	let backButton: UIButton = {
		let btn = UIButton(frame: .zero)
		btn.setImage(Asset.Icons.arrowBack.image.withRenderingMode(.alwaysTemplate), for: .normal)
		btn.imageView?.tintColor = Asset.Colors.purple.color
		return btn
	}()
	
	let downloadButton: UIButton = {
		let btn = UIButton(frame: .zero)
		btn.setImage(Asset.Icons.download.image, for: .normal)
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
	private let playerLayer = AVPlayerLayer()
	private var looper: AVPlayerLooper?
	var player: AVPlayer? {
		didSet {
			oldValue?.pause()
			if let player = player,
			   let item = player.currentItem?.copy() as? AVPlayerItem {
				let queuePlayer = AVQueuePlayer(playerItem: item)
				self.looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
				playerLayer.isHidden = false
				playerLayer.player = player
				player.externalPlaybackVideoGravity = .resizeAspect
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

	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		container.frame = contentView.frame
		playerLayer.frame = container.layer.frame
	}
	
}
