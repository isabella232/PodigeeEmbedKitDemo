
# PodigeeEmbedKit

[![Platforms](https://img.shields.io/badge/platform-ios%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-lightgrey.svg)](#)

[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/badge/Cocoapods-compatible-brightgreen.svg)](https://cocoapods.org)

The `PodigeeEmbedKit` framework allows you to display information about a podcast hosted on [podigee.com](https://podigee.com) in your iOS, macOS or tvOS app. You can get data for the most recent published episode, a specific episode and even a playlist of all published episodes.

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Full Documentation](#documentation)
- [iOS Demo Project](#demo)
- [License](#license)

## Requirements

- iOS 10.0+ / Mac OS X 10.10+ / tvOS 10.0+ / watchOS 3.0+
- Swift 5.0+ / Xcode 10.2+

## Installation

### Dependency Managers
<details>
  <summary><strong>CocoaPods</strong></summary>

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate PodigeeEmbedKit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
platform :ios, '10.0'
use_frameworks!

pod 'PodigeeEmbedKit', :git => 'https://github.com/podigee/PodigeeEmbedKit.git', :branch => 'master'
```

You have to link to the Github repository directly, because it is not publically available in the Cocoapods directory.

Then, run the following command:

```bash
$ pod install
```

</details>

<details>
  <summary><strong>Carthage</strong></summary>

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate PodigeeEmbedKit into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "podigee/PodigeeEmbedKit" ~> 1.1.0
```

</details>

<details>
  <summary><strong>Swift Package Manager</strong></summary>

To use PodigeeEmbedKit as a [Swift Package Manager](https://swift.org/package-manager/) package just add the following in your Package.swift file.

``` swift
// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "HelloPodigeeEmbedKit",
    dependencies: [
        .package(url: "https://github.com/podigee/PodigeeEmbedKit.git", .upToNextMajor(from: "1.1.0"))
    ],
    targets: [
        .target(name: "HelloPodigeeEmbedKit", dependencies: ["PodigeeEmbedKit"])
    ]
)
```
</details>

## Usage

When you request data you always have to provide the domain of the podcast hosted on Podigee. The domain format is `podcast-specific-subdomain.podigee.io`, e.g. `podcast-news.podigee.io`.

### Request embed data for the most recent episode

Requesting embed data returns

* Podcast Metadata
* Episode Metadata
* Extension settings

If you do not define a specific episode this will return metadata for the most recently published episode of this podcast.

```swift
let podcastDomain = "podcast-news.podigee.io"
PodigeeEmbedKit.embedDataForPodcastWith(domain: podcastDomain) { result in
    switch result {
    case .failure(let error): break
    case .success(let podcastEmbed):
        let podcastTitle = podcastEmbed.podcast.title
        let episode = podcastEmbed.episode
        let episodeTitle = episode.title
        let mp3Url = episode.media.mp3        
    }
}
```

The `podcastEmbed` struct which is returned is defined like this:

```swift
public struct PodcastEmbed: Codable {
    public let episode: Episode?
    public let podcast: Podcast
    public let extensions: Extensions
}
```

Extensions include several boolean toggles which can be defined in the Podigee webinterface for external player embeds. Using these settings you can define if the player should show a download button, or the chapter marks for example. It is up to you to use these toggles to actually have an effect on your UI.

Please [take a look at the full API documentation](#documentation) for more information.

**Handling coverart images**

When you want to display a coverart image you can request a specific image size from the API. All coverart images are squares so you only define a custom width.

```swift
let episode = podcastEmbed?.episode
let url = episode.coverartUrlFor(width: 720)
```

### Request embed data for specific episode

You can also request embed information for a specific episode of a podcast. In this case you have to provide the `episodePath` in addidation to the podcast domain. In this case the path to the episode is `7-podcatcher-in-the-rye`.

```swift
PodigeeEmbedKit.embedDataForPodcastWith(domain: "podcast-news.podigee.io", episodePath: "7-podcatcher-in-the-rye", complete: { result in
    switch result {
    case .failure(let error): break
    case .success(let podcastEmbed):
        let title = podcastEmbed?.episode?.title
        let subtitle = podcastEmbed?.episode?.subtitle
        let number = podcastEmbed?.episode?.number
    }
})
```

### Request a list of published episodes

You can also request a list of published episodes. By default this returns the last 10 episodes of the podcast sorted by publish date.

```swift
PodigeeEmbedKit.playlistForPodcastWith(domain: "podcast-news.podigee.io", complete: { result in
    switch result {
    case .failure(let error): break
    case .success(let playlist):
        let episodes = playlist.episodes
        for episode in episodes {
            print(episode.title)
        }         
    }
})
```

**Paging**

If you need more episodes you can use the paging parameters `pageSize` and `offset` to request episodes using multiple requests.

```swift
// fetch first 5 episodes
PodigeeEmbedKit.playlistForPodcastWith(domain: "podcast-news.podigee.io", pageSize: 5, offset: 0, complete: { result in
    let playlist = try? result.get()
    let episodes = playlist?.episodes
})

// fetch next 5 episodes
PodigeeEmbedKit.playlistForPodcastWith(domain: "podcast-news.podigee.io", pageSize: 5, offset: 5, complete: { result in
    let playlist = try? result.get()
    let episodes = playlist?.episodes
})
```

The returned episodes count only matches the requested `pagesSize` if the podcast does have enough published episodes.

**Sorting**

Episodes can either be sorted by publish date or by episode number. If you do not set the sorting algorithm yourself the episodes are sorted by publish date by default.

```swift
PodigeeEmbedKit.playlistForPodcastWith(domain: "podcast-news.podigee.io", sortBy: .episodeNumber, complete: { result in
    let playlist = try? result.get()
    let episodes = playlist?.episodes
})
```

## Documentation

You can find the full API documentation in the `docs` folder:

* Download and extract the repository contents
* Open `docs/index.html`

# Demo

There also is a simple iOS demo project to demonstrate how this framework can be used to display podcast and episode content in an iOS app. [You can find the repository of the demo project here](https://github.com/podigee/PodigeeEmbedKitDemo).

## Author

Podigee [@podigee](https://twitter.com/podigee)

## License

PodigeeEmbedKit is released under the MIT license. See [LICENSE](https://github.com/podigee/PodigeeEmbedKit/blob/master/LICENSE) for details.
