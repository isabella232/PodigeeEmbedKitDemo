//
//  Model.swift
//  PodigeeEmbedKit-iOS
//
//  Created by Stefan Trauth on 10.11.18.
//  Copyright © 2018 podigee. All rights reserved.
//

import Foundation

/// A list of episodes
public struct Playlist: Codable {
    let episodes: Episodes
}

public struct PodcastEmbed: Codable {
    /// Episode metadata for the requested episode.
    public let episode: Episode?
    /// Podcast related information
    public let podcast: Podcast
    /// Embed extensions. Contains information if they are enabled or disabled
    public let extensions: Extensions
}

extension PodcastEmbed {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        // decode episode as nil if it can not be decoded because of empty dictionary
        episode = try? values.decode(Episode.self, forKey: .episode)
        podcast = try values.decode(Podcast.self, forKey: .podcast)
        extensions = try values.decode(Extensions.self, forKey: .extensions)
    }
}

public typealias Episodes = [Episode]
public struct Episode: Codable {
    /// All media related to this episode. Contains URLs to different audio formats
    public let media: Media
    /// URL for the coverart image, contains podcast coverart as fallback. Use coverartUrlFor(width:) to request a scaled image.
    public let coverUrl: URL?
    /// The episode title
    public let title: String
    /// The episode subtitle
    public let subtitle: String?
    /// The episode description
    public let description: String?
    /// All chaptermarks for this episode
    public let chaptermarks: [Chaptermark]
    /// The URL to the episode on the web
    public let url: URL
    /// The URL to a JSON representation of the transcript
    public let transcript: URL?
    /// The episode number
    public let number: Int
    /// The duration of the episode in seconds
    public let duration: Int
    
    public struct Chaptermark: Codable {
        /// The chapter mark title
        public let title: String
        /// The chapter mark start time related to playback time.
        ///
        /// Format: `hh:mm:ss.sss`
        ///
        /// Example: `00:21:21.521`
        public let start: String
    }
    
    public struct Media: Codable {
        public let mp3: URL
    }
}

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


public struct Extensions: Codable {
    public let chapterMarks: ChapterMarks
    public let download: Download
    public let episodeInfo: EpisodeInfo
    public let playlist: Playlist
    public let share: Share
    public let transcript: Transcript
    public let subscribeBar: SubscribeBar
    
    private enum CodingKeys: String, CodingKey {
        case chapterMarks = "ChapterMarks"
        case download = "Download"
        case episodeInfo = "EpisodeInfo"
        case playlist = "Playlist"
        case share = "Share"
        case transcript = "Transcript"
        case subscribeBar = "SubscribeBar"
    }
    
    public struct SubscribeBar: Codable {
        public let disabled: Bool
    }
    public struct Transcript: Codable {
        public let disabled: Bool
    }
    public struct Share: Codable {
        public let disabled: Bool
    }
    public struct Playlist: Codable {
        public let disabled: Bool
    }
    public struct EpisodeInfo: Codable {
        public let disabled: Bool
    }
    public struct Download: Codable {
        public let disabled: Bool
    }
    public struct ChapterMarks: Codable {
        public let disabled: Bool
    }
}

extension Episode {
    /**
    The Podigee image service allows you to request a coverart with a specific size. All coverarts are squares therefore you can only define a the width for the image you need.
     - Parameter width: Define the width of the square coverart you want to request. The height of the image is going to match the width.
     - returns: The URL to the coverart image with the requested width.
    */
    public func coverartUrlFor(width: Int) -> URL? {
        // example coverurl: https://images.podigee.com/0x,sGHGvqlQXCu1Wh8KqqyYwTxdsquGs99gBhSEDtetYXNk=/https://cdn.podigee.com/uploads/u3894/359299f2-b464-4ab4-9c6d-dd4b99ef8881.jpeg
        guard let url = coverUrl else { return nil }
        let split = url.path.split(separator: ",")
        guard split.count == 2 else { return nil }
        // get the path without the scaling factor
        guard let cleanPath = split.last else { return nil }
        // create a new path including the requested width
        let scaledPath = "/\(width)x,\(cleanPath)"
        // use the old complete coverart url
        var scaledComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        // and replace its path with the new scaled path
        scaledComponents?.path = scaledPath
        return scaledComponents?.url
    }
}
