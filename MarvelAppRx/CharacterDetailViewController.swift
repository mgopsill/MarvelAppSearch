//
//  CharacterDetailViewController.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 03/04/2021.
//

import RxSwift
import RxCocoa
import UIKit

final class CharacterDetailViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let headerImageView = UIImageView()
    private let stackView = UIStackView()
    private let titleStackView = UIStackView()
    private let titleLabel = UILabel()
    private let favouriteButton = UIButton()
    private let descriptionLabel = UILabel()
    private let websiteButton = UIButton()
    
    private let viewModel: CharacterDetailViewModelProtocol
    private let onDismiss: (() -> Void)?
    
    init(viewModel: CharacterDetailViewModelProtocol, onDismiss: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        bindUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            onDismiss?()
        }
    }
    
    private func setupUI() {
        view.addSubview(headerImageView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 20
        stackView.axis = .vertical
        
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.distribution = .equalCentering
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(favouriteButton)
        
        stackView.addArrangedSubview(titleStackView)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(websiteButton)
        view.addSubview(stackView)
        
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.clipsToBounds = true
        
        titleLabel.font = .boldSystemFont(ofSize: 30)
        favouriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        favouriteButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
        descriptionLabel.font = .systemFont(ofSize: 10)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        websiteButton.setTitleColor(.systemBlue, for: .normal)
        websiteButton.titleLabel?.lineBreakMode = .byWordWrapping
        websiteButton.titleLabel?.numberOfLines = 0
        websiteButton.titleLabel?.textAlignment = .center
            
        NSLayoutConstraint.activate([
            headerImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            headerImageView.heightAnchor.constraint(equalToConstant: 320),
            stackView.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            titleStackView.heightAnchor.constraint(equalToConstant: 40),
            favouriteButton.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func bindUI() {
        websiteButton.rx.tap.bind(to: viewModel.input.buttonTap).disposed(by: disposeBag)
        favouriteButton.rx.tap
            .map { [unowned self] _ in favouriteButton.isSelected }
            .bind(to: viewModel.input.favouriteTap)
            .disposed(by: disposeBag)
        
        viewModel.output.characterImage.drive(headerImageView.rx.image).disposed(by: disposeBag)
        viewModel.output.characterName.drive(titleLabel.rx.text).disposed(by: disposeBag)
        viewModel.output.characterName.drive(rx.title).disposed(by: disposeBag)
        viewModel.output.characterDescription.drive(descriptionLabel.rx.text).disposed(by: disposeBag)
        viewModel.output.buttonText.drive(websiteButton.rx.title(for: .normal)).disposed(by: disposeBag)
        viewModel.output.isFavourite.drive(favouriteButton.rx.isSelected).disposed(by: disposeBag   )
    }
}
