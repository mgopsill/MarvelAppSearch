//
//  CharacterTableViewCell.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 03/04/2021.
//

import RxSwift
import RxCocoa
import UIKit

final class CharacterTableViewCell: UITableViewCell {
    static let reuseIdentifier = "Characters"
    
    private let stackView = UIStackView()
    private let title: UILabel = UILabel()
    private let characterImageView: UIImageView = UIImageView(image: UIImage(systemName: "person.circle"))
    private let isFavouriteImageView: UIImageView = UIImageView(image: nil)
    private var disposeBag = DisposeBag()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally

        characterImageView.contentMode = .scaleAspectFit
        isFavouriteImageView.contentMode = .scaleAspectFit

        stackView.addArrangedSubview(characterImageView)
        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(isFavouriteImageView)
        contentView.addSubview(stackView)
                
        let constraints:[NSLayoutConstraint] = [
            characterImageView.widthAnchor.constraint(equalToConstant: 50),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            isFavouriteImageView.widthAnchor.constraint(equalToConstant: 30),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func bind(to viewModel: CharacterCellViewModel) {
        viewModel.output.name.drive(title.rx.text).disposed(by: disposeBag)
        viewModel.output.image.drive(characterImageView.rx.image).disposed(by: disposeBag)
        viewModel.output.isFavourite.drive(rx.isFavourite).disposed(by: disposeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
        characterImageView.image = UIImage(systemName: "person.circle")
        title.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circleImage()
    }
    
    private func circleImage() {
        characterImageView.layer.borderWidth = 1.0
        characterImageView.layer.masksToBounds = false
        characterImageView.layer.borderColor = UIColor.systemBackground.cgColor
        characterImageView.layer.cornerRadius = characterImageView.frame.size.height / 2
        characterImageView.clipsToBounds = true
    }
    
    func set(isFavourite: Bool) {
        let image = isFavourite ? UIImage(systemName: "star.fill") : nil
        isFavouriteImageView.image = image
    }
}

extension Reactive where Base: CharacterTableViewCell {
    var isFavourite: Binder<Bool> {
        Binder(base) { cell, isFavourite in
            cell.set(isFavourite: isFavourite)
        }
    }
}
