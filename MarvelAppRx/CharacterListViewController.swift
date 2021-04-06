//
//  CharacterListViewController.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 02/04/2021.
//

import RxSwift
import RxCocoa
import UIKit

final class CharacterListViewController: UIViewController {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView()
    private let activityIndicatorView = UIActivityIndicatorView(style: .large)
    private let disposeBag = DisposeBag()
    
    private let viewModel: CharacterListViewModelProtocol
    private let imageProvider: ImageProviderProtocol
    
    init(viewModel: CharacterListViewModelProtocol = CharacterListViewModel(),
         imageProvider: ImageProviderProtocol = ImageProvider()) {
        self.viewModel = viewModel
        self.imageProvider = imageProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.searchController = searchController
        title = "Marvel Characters"
        navigationController?.navigationBar.prefersLargeTitles = true
        setupTableView()
        bindUI()
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 60
        tableView.register(CharacterTableViewCell.self, forCellReuseIdentifier: CharacterTableViewCell.reuseIdentifier)
        view.addSubview(tableView)
        
        view.addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
             tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
             tableView.topAnchor.constraint(equalTo: view.topAnchor),
             tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
             activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             activityIndicatorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)])
    }
    
    private func bindUI() {
        searchController.searchBar.rx.text.bind(to: viewModel.inputs.search).disposed(by: disposeBag)
        tableView.rx.modelSelected(MarvelCharacter.self).bind(to: viewModel.inputs.selectCharacter).disposed(by: disposeBag)
        
        viewModel.outputs.marvelCharacters
            .drive(tableView.rx.items(cellIdentifier: CharacterTableViewCell.reuseIdentifier, cellType: CharacterTableViewCell.self)) { [weak self] (row , character, cell) in
                guard let self = self else { return }
                let cellViewModel = CharacterCellViewModel(character: character, imageProvider: self.imageProvider)
                cell.bind(to: cellViewModel)
            }
            .disposed(by: disposeBag)
        
        searchController.searchBar
            .rx.searchButtonClicked
            .map { _ in false }
            .bind(to: searchController.rx.isActive)
            .disposed(by: disposeBag)
        
        viewModel.outputs.isLoading.drive(onNext: { [weak self] isLoading in
            guard let self = self else { return }
            self.tableView.isHidden = isLoading
            self.activityIndicatorView.isHidden = !isLoading
            isLoading ? self.activityIndicatorView.startAnimating() : self.activityIndicatorView.stopAnimating()
        }).disposed(by: disposeBag)
    }
}
