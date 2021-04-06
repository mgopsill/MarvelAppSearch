//
//  ImageProvider.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 03/04/2021.
//

import RxSwift

protocol ImageProviderProtocol {
    func image(for url: URL?) -> Observable<UIImage?>
}

final class ImageProvider: ImageProviderProtocol {
    
    private let cache: NSCache<NSString, UIImage>
    
    init(cache: NSCache<NSString, UIImage> = ImageCache.cache) {
        self.cache = cache
    }
    
    private func getNetworkImage(from url: URL?) -> Observable<UIImage?> {
        guard let url = url else { return Observable.just(nil) }
        let request = URLRequest(url: url)
        return URLSession.shared.rx.data(request: request).map { [weak self] data -> UIImage? in
            guard let self = self, let image = UIImage(data: data) else { return nil }
            self.cache.setObject(image, forKey: url.absoluteString as NSString)
            return image
        }.asObservable()
    }
    
    func image(for url: URL?) -> Observable<UIImage?> {
        guard let url = url else { return Observable.just(nil) }
        if let image = cache.object(forKey: url.absoluteString as NSString) {
            return Observable.just(image)
        } else {
            return getNetworkImage(from: url)
        }
    }
}

enum ImageCache {
    static let cache = NSCache<NSString, UIImage>()
}
