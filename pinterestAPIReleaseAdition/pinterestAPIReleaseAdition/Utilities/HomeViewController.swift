//
//  HomeViewController.swift
//  pinterestAPIReleaseAdition
//
//  Created by BCL Device 5 on 8/5/25.
//


import UIKit

class HomeViewController: UIViewController {
    private let accessToken: String
    private var boards: [Board] = []
    private var pins: [Pin] = []
    
    private enum Section: Int, CaseIterable {
        case boards
        case pins
    }
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(BoardCell.self, forCellWithReuseIdentifier: BoardCell.identifier)
        cv.register(PinCell.self, forCellWithReuseIdentifier: PinCell.identifier)
        cv.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.identifier)
        return cv
    }()
    
    init(accessToken: String) {
        self.accessToken = accessToken
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pinterest"
        view.backgroundColor = .white
        setupCollectionView()
        fetchBoards()
        fetchPins()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func fetchBoards() {
        guard let url = URL(string: "https://api.pinterest.com/v5/boards") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching boards: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let boardsResponse = try JSONDecoder().decode(BoardsResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.boards = boardsResponse.items
                    self?.collectionView.reloadData()
                }
            } catch {
                print("Error decoding boards response: \(error)")
            }
        }.resume()
    }
    
    private func fetchPins() {
        guard let url = URL(string: "https://api.pinterest.com/v5/pins") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching pins: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let pinsResponse = try JSONDecoder().decode(PinsResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.pins = pinsResponse.items
                    self?.collectionView.reloadData()
                }
            } catch {
                print("Error decoding pins response: \(error)")
            }
        }.resume()
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        
        switch section {
        case .boards:
            return boards.count
        case .pins:
            return pins.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        
        switch section {
        case .boards:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoardCell.identifier, for: indexPath) as! BoardCell
            let board = boards[indexPath.item]
            cell.configure(with: board)
            return cell
        case .pins:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PinCell.identifier, for: indexPath) as! PinCell
            let pin = pins[indexPath.item]
            cell.configure(with: pin)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.identifier, for: indexPath) as! SectionHeaderView
            
            guard let section = Section(rawValue: indexPath.section) else {
                return headerView
            }
            
            switch section {
            case .boards:
                headerView.titleLabel.text = "Boards"
            case .pins:
                headerView.titleLabel.text = "Pins"
            }
            
            return headerView
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let section = Section(rawValue: indexPath.section) else {
            return .zero
        }
        
        let width = collectionView.bounds.width
        
        switch section {
        case .boards:
            return CGSize(width: width / 2 - 20, height: 200)
        case .pins:
            return CGSize(width: width / 3 - 20, height: 150)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
}