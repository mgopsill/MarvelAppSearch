//
//  ImageProviderTests.swift
//  MarvelAppRxTests
//
//  Created by Mike Gopsill on 05/04/2021.
//

import RxBlocking
import SnapshotTesting
import XCTest

@testable import MarvelAppRx

final class ImageProviderTests: XCTestCase {
    let endpointURL = URL(string: "https://image.marvel.com/image.jpeg")!
    var cache: NSCache<NSString, UIImage>!
    
    override func setUp() {
        super.setUp()
        cache = NSCache<NSString, UIImage>()
        URLProtocol.registerClass(TestURLProtocol.self)
    }
    
    override func tearDown() {
        URLProtocol.unregisterClass(TestURLProtocol.self)
        cache = nil
        super.tearDown()
    }
    
    func testGetImageWithInvalidURL() {
        let subject = ImageProvider(cache: cache)
        XCTAssertNil(try subject.image(for: nil).toBlocking().single())
    }
    
    func testGetCachedImage() {
        let cachedImage = UIImage(systemName: "house")!
        let url = URL(string: "www.marvel.com")!
        cache.setObject(cachedImage, forKey: url.absoluteString as NSString)
        let subject = ImageProvider(cache: cache)
        XCTAssertEqual(cachedImage, try subject.image(for: url).toBlocking().single())
    }
            
    func testFetchImageIfNotCachedAndCache() {
        let image = UIImage(systemName: "house")!
        TestURLProtocol.mockResponses[endpointURL] = { _ in (.success(image.jpegData(compressionQuality: 0)!), 200) }
        let subject = ImageProvider(cache: cache)
        
        let imageView = UIImageView(image: try? subject.image(for: endpointURL).toBlocking().single())
        assertSnapshot(matching: imageView, as: .image)
        XCTAssertNotNil(cache.object(forKey: endpointURL.absoluteString as NSString))
    }
    
    func testFetchImageFails() {
        struct MockError: Error {}
        TestURLProtocol.mockResponses[endpointURL] = { _ in (.failure(MockError()), 440) }
        let subject = ImageProvider(cache: cache)
        
        XCTAssertNil(try subject.image(for: nil).toBlocking().single())
        XCTAssertNil(cache.object(forKey: endpointURL.absoluteString as NSString))
    }
    
    func testFetchImageFetchesErroneousData() {
        struct MockError: Error {}
        TestURLProtocol.mockResponses[endpointURL] = { _ in (.success(Data()), 200) }
        let subject = ImageProvider(cache: cache)
        
        XCTAssertNil(try subject.image(for: nil).toBlocking().single())
        XCTAssertNil(cache.object(forKey: endpointURL.absoluteString as NSString))
    }
}
