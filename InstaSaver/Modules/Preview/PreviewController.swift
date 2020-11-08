//
//  PreviewController.swift
//  InstaSaver
//
//  Created by Кирилл on 04.11.2020.
//

import UIKit
import RxSwift
import RxCocoa



class PreviewController: UICollectionViewController , UICollectionViewDelegateFlowLayout{
	
	let bag = DisposeBag()
	
	override func loadView() {
		self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
		self.collectionView.register(PreviewCell.self, forCellWithReuseIdentifier: "\(PreviewCell.self)")
		(collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
		(collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing = 0
		collectionView.isPagingEnabled = true
		
		
    }
	
	var content:[ISPreviewable] = [] {
		didSet{
			self.collectionView.reloadData()
		}
	}
	
	


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {1}


	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { content.count }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(PreviewCell.self)", for: indexPath)
		let element = self.content[indexPath.item]
		if let thumb = element.link,
		   let cell = cell as? PreviewCell {
			ISNetwork.shared.load(thumb).compactMap(UIImage.init).bind(to: cell.container.rx.image).disposed(by: bag)
		}
        return cell
    }

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		collectionView.frame.size
	}


}

class PreviewCell: UICollectionViewCell {
	let container:UIImageView = {
		let v = UIImageView(frame: .zero)
		v.contentMode = .scaleAspectFit
		return v
	}()
	
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.contentView.addSubview(container)
		contentView.snp.makeConstraints {
			$0.edges.equalToSuperview()
			$0.edges.equalTo(container)
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		container.frame = contentView.frame
	}
	
	
}
