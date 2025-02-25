//
//  ViewController.swift
//  WatefFallLayoutDemo
//
//  Created by Mohammad Noor on 30/10/24.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var pinterestCollectionView: UICollectionView!
    var photos: [Photo] = []
    var imageNames: [String] = (0...15).map { "\($0)" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCollectionView()
        fetchImages()
    }
    
    func setUpCollectionView() {
        getWaterfallLayout()
        pinterestCollectionView.dataSource = self
        // pinterestCollectionView.delegate = self
        pinterestCollectionView.register(CustomWaterfallCell.self, forCellWithReuseIdentifier: "waterFallCollectionViewCell")
    }
    
    func getWaterfallLayout()  {
        let customLayout =  CustomWaterFallLayout()
        customLayout.delegate = self
        customLayout.numOfColumns = 2
        pinterestCollectionView.collectionViewLayout = customLayout
    }
    
    func fetchImages() {
        if let savedUrls = loadThumbnailUrls() {
            photos = savedUrls.map { Photo(imageUrl: $0) }
            downloadImages()
            return
        }
        
        var request = URLRequest(url: URL(string: "https://api.unsplash.com/photos/?client_id=5rScVUgUeVzZhZ6cCRVhC9Zg3_KjPkUiFxKqxbUTKoM")!, timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
                
                json?.forEach { photoData in
                    if let urls = photoData["urls"] as? [String: Any],
                       let thumbUrl = urls["thumb"] as? String {
                        let photo = Photo(imageUrl: thumbUrl)
                        self?.photos.append(photo)
                    }
                    
                }
                let thumbUrls = self?.photos.map { $0.imageUrl }
                self?.saveThumbnailUrls(thumbUrls ?? [])
                self?.downloadImages()
                
            } catch {
                print("Failed to parse JSON: \(error)")
            }
        }.resume()
    }
    
    
    func downloadImages() {
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        for (index, photo) in photos.enumerated() {
            if let url = URL(string: photo.imageUrl) {
                
                URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                    if let data = data, let image = UIImage(data: data) {
                        self?.photos[index].image = image
                    }
                }.resume()
            }
        }
        
        dispatchGroup.leave()
        
        dispatchGroup.notify(queue: .main   ) { [weak self] in
            self?.pinterestCollectionView.reloadData()
            self?.pinterestCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    func saveThumbnailUrls(_ urls: [String]) {
        let filePath = getDocumentsDirectory().appendingPathComponent("thumbnailUrls.json")
        
        do {
            let jsonData = try JSONEncoder().encode(urls)
            try jsonData.write(to: filePath)
        } catch {
            print("Error saving thumbnail URLs: \(error)")
        }
    }

    func loadThumbnailUrls() -> [String]? {
        let filePath = getDocumentsDirectory().appendingPathComponent("thumbnailUrls.json")
        
        do {
            let jsonData = try Data(contentsOf: filePath)
            let urls = try JSONDecoder().decode([String].self, from: jsonData)
            return urls
        } catch {
            print("Error loading thumbnail URLs: \(error)")
            return nil
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let documentsDirectory = paths[0]
        print("Documents Directory: \(documentsDirectory.path)")
        return documentsDirectory
    }

    
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames.count // Should reflect the number of items in the array
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Guard against accessing an invalid index
        guard indexPath.row < imageNames.count else {
            return UICollectionViewCell() // Return an empty cell or handle accordingly
        }
        
        let cell = pinterestCollectionView.dequeueReusableCell(withReuseIdentifier: "waterFallCollectionViewCell", for: indexPath) as! CustomWaterfallCell
        cell.imageView.image = UIImage(named: imageNames[indexPath.row])
        return cell
    }
}

//2. The ViewController adopts this protocol and provides the actual size of each image when requested
//----- Implementing the function from where we will send the data
extension ViewController: CustomWaterFallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, sizeOfPhotoAtIndexPath indexPath: IndexPath) -> CGSize {
        // Check if indexPath is within bounds
        guard indexPath.row < imageNames.count else {
            return CGSize(width: 100, height: 100) // Default size if index is out of bounds
        }
        
        // Return the image size or a default size if the image is nil
        return UIImage(named: imageNames[indexPath.row])?.size ?? CGSize(width: 100, height: 100)
    }
}


