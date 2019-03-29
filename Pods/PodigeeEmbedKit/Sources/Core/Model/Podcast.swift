//
//  Podcast.swift
//  PodigeeEmbedKit
//
//  Created by Stefan Trauth on 21.03.19.
//  Copyright © 2019 podigee. All rights reserved.
//

import Foundation

public struct Podcast: Codable {
    /// The URL to the podcast rss feed
    public let feed: URL
    /// The podcast title
    public let title: String
    /// The podcast subtitle
    public let subtitle: String?
    /// The URL to the podcast website
    public let url: URL
    /// URLs for services this podcast is available on, e.g. iTunes or Spotify
    public let connections: Connections
    /// The podcast language in language code format, e.g. `en`
    public let language: String
    
    public struct Connections: Codable {
        public let itunes: URL?
        public let spotify: URL?
        public let deezer: URL?
        public let alexa: URL?
    }
}
