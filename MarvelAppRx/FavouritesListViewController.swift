//
//  FavouritesListViewController.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 03/04/2021.
//

import RxCocoa
import RxSwift
import UIKit

final class FavouritesListViewController: UITableViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel: FavouritesListViewModelProtocol
    private let imageProvider: ImageProviderProtocol
    
    init(viewModel: FavouritesListViewModelProtocol = FavouritesListViewModel(),
         imageProvider: ImageProviderProtocol = ImageProvider()) {
        self.viewModel = viewModel
        self.imageProvider = imageProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Favourites"
        navigationController?.navigationBar.prefersLargeTitles = true
        configureTableView()
        bindUI()
    }
    
    private func configureTableView() {
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.rowHeight = 60
        tableView.register(CharacterTableViewCell.self, forCellReuseIdentifier: CharacterTableViewCell.reuseIdentifier)
    }
    
    private func bindUI() {
        viewModel.outputs.characters
            .drive(tableView.rx.items(cellIdentifier: CharacterTableViewCell.reuseIdentifier, cellType: CharacterTableViewCell.self)) { [weak self] (row , character, cell) in
                guard let self = self else { return }
                let cellViewModel = CharacterCellViewModel(character: character, imageProvider: self.imageProvider)
                cell.bind(to: cellViewModel)
            }
            .disposed(by: disposeBag)
        
        rx.viewWillAppear.map { _ in }.bind(to: viewModel.inputs.viewWillAppear).disposed(by: disposeBag)
        tableView.rx.itemDeleted.bind(to: viewModel.inputs.deleteIndexPath).disposed(by: disposeBag)
        tableView.rx.modelSelected(MarvelCharacter.self).bind(to: viewModel.inputs.selectCharacter).disposed(by: disposeBag)
    }
}

extension Reactive where Base: UIViewController {
    var viewWillAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
}
