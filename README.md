![build and test state](https://github.com/mgopsill/marvelappsearch/actions/workflows/xcode-build-test.yml/badge.svg)

# MarvelAppSearch

App to Search and Favourite Marvel Characters featuring: 
- Search for characters (searches debounced every 400ms to reduce API use)
- Simple in-memory cache for images
- Favourite characters cached and retrieved using `UserDefaults` and encoded JSON
- Link outs to favourite marvel characters
- Swipe to delete from Favourites list

<img src="example.gif" width="250" height="580" />

Architecture: 
- MVVM-C
- `RxSwift` used. It should be easy to bridge to `Combine` but I find testing `Rx` easier, at least until `Combine` has better testing and virtual time support.
- `UIKit`. Should be fairly easy to jump to `SwiftUI` and `Combine`.
- `SnapshotTesting` for views
- Tests colocated in project folder to make them first-class citizens and highlight missing test cases
- `CocoaPods` used over `Carthage` or `SPM` due to ease-of-use and a bug in `SPM` making `RxTest` difficult to use.
- Pods included in repo to make it easier to clone and build for timebeing



Todo:
- [x] loading state and network activity indicator
- [ ] error state / handling for failed network calls 
