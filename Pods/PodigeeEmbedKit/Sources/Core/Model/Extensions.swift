//
//  Extensions.swift
//  PodigeeEmbedKit
//
//  Created by Stefan Trauth on 21.03.19.
//  Copyright © 2019 podigee. All rights reserved.
//

import Foundation

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
