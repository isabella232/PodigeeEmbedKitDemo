//
//  PodcastEmbed.swift
//  PodigeeEmbedKit-iOS
//
//  Created by Stefan Trauth on 21.03.19.
//  Copyright © 2019 podigee. All rights reserved.
//

import Foundation

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
