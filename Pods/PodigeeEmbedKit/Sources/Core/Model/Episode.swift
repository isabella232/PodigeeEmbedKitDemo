//
//  Episode.swift
//  PodigeeEmbedKit
//
//  Created by Stefan Trauth on 21.03.19.
//  Copyright © 2019 podigee. All rights reserved.
//

import Foundation

/// A list of episodes
public struct Playlist: Codable {
    let episodes: Episodes
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
