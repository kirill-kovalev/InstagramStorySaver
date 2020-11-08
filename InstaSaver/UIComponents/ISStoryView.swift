//
//  ISStoryView.swift
//  InstaSaver
//
//  Created by Кирилл on 01.11.2020.
//

import UIKit

class ISStoryView:UIStackView {
	private lazy var storyImageShadowLayer:CALayer = {
		let l = CALayer()
		l.shadowColor = UIColor.purple.cgColor
		l.shadowRadius = 30
		return l
	}()
	lazy var storyImage:UIImageView = {
		let v = UIImageView(frame: .zero)
		v.contentMode = .scaleAspectFill
		v.layer.addSublayer(storyImageShadowLayer)
		
		v.backgroundColor = Asset.Colors.black2.color
		v.layer.cornerRadius = 20
		v.layer.masksToBounds = true
		return v
	}()
	let timestampText:UILabel = {
		let v = UILabel(frame: .zero)
		v.font = .subtitleGray
		v.textColor = Asset.Colors.black5.color
		v.textAlignment = .center
		v.text = "...hours ago"
		return v
	}()
	convenience init(a:Int) {
		self.init(frame:.zero)
		setup()
	}
	private func setup() {
		self.axis = .vertical
		self.addArrangedSubview(storyImage)
		self.addArrangedSubview(timestampText)
//		storyImage.layer.addSublayer(storyImageShadowLayer)
		storyImage.snp.makeConstraints { (make) in
			make.height.equalTo(self.snp.width).multipliedBy(1.7)
		}
		
		self.layer.cornerRadius = 20
		self.layer.masksToBounds = true
	}
}

public class EdgeShadowLayer: CAGradientLayer {

	public enum Edge {
		case Top
		case Left
		case Bottom
		case Right
	}

	public init(forView view: UIView,
				edge: Edge = Edge.Top,
				shadowRadius radius: CGFloat = 20.0,
				toColor: UIColor = UIColor.white,
				fromColor: UIColor = UIColor.black) {
		super.init()
		self.colors = [fromColor.cgColor, toColor.cgColor]
		self.shadowRadius = radius

		let viewFrame = view.frame

		switch edge {
			case .Top:
				startPoint = CGPoint(x: 0.5, y: 0.0)
				endPoint = CGPoint(x: 0.5, y: 1.0)
				self.frame = CGRect(x: 0.0, y: 0.0, width: viewFrame.width, height: shadowRadius)
			case .Bottom:
				startPoint = CGPoint(x: 0.5, y: 1.0)
				endPoint = CGPoint(x: 0.5, y: 0.0)
				self.frame = CGRect(x: 0.0, y: viewFrame.height - shadowRadius, width: viewFrame.width, height: shadowRadius)
			case .Left:
				startPoint = CGPoint(x: 0.0, y: 0.5)
				endPoint = CGPoint(x: 1.0, y: 0.5)
				self.frame = CGRect(x: 0.0, y: 0.0, width: shadowRadius, height: viewFrame.height)
			case .Right:
				startPoint = CGPoint(x: 1.0, y: 0.5)
				endPoint = CGPoint(x: 0.0, y: 0.5)
				self.frame = CGRect(x: viewFrame.width - shadowRadius, y: 0.0, width: shadowRadius, height: viewFrame.height)
		}
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

