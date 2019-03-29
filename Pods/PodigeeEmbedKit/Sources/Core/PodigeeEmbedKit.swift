//
//  PodigeeEmbedKit.swift
//  PodigeeEmbedKit
//
//  Created by Podigee on 02/10/17.
//  Copyright © 2017 podigee. All rights reserved.
//

import Foundation

/// Contains API calls to request podcast and episode embed information from Podigee.
public class PodigeeEmbedKit {
    
    public enum PodigeeError: Error {
        case invalidPodcastDomain
        case invalidPageSize
        case invalidOffset
        case unknown
    }
    
    public enum PlaylistSorting: String {
        /// Sort episodes in playlist by publish date. Most recent first.
        case publishDate = "default"
        /// Sort episodes in playlist by episode number in ascending order.
        case episodeNumber = "numeric"
    }
    
    private static var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    /**
     Request embed data information for a podcast. This contains information about the podcast and data for the most recent published episode.
     - Parameter domain: The domain of the podcast, e.g. `bananaland.podigee.io`.
     - Parameter episodePath: The url path component for the episode, e.g. `63-bbc-sound-sammlung`. If set to `nil` the most recent episode of the podcast will be included in the response.
     - Parameter complete: The closure called when the network request is finished.
     - returns: Void
    */
    public static func embedDataForPodcastWith(domain: String, episodePath: String? = nil, complete: @escaping (_ result: Result<PodcastEmbed, Error>) -> Void) {
        var components = URLComponents()
        components.host = domain
        components.queryItems = [URLQueryItem(name: "context", value: "external")]
        components.scheme = "https"
        
        guard var url = components.url else {
            complete(.failure(PodigeeError.invalidPodcastDomain))
            return
        }
        if let path = episodePath {
            url.appendPathComponent(path)
        }
        url.appendPathComponent("embed")
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    complete(.failure(error))
                } else {
                    complete(.failure(PodigeeError.unknown))
                }
                return
            }
            do {
                let embed = try jsonDecoder.decode(PodcastEmbed.self, from: data)
                complete(.success(embed))
            } catch {
                complete(.failure(error))
            }
        }.resume()
    }
    
    /**
     Request the episode playlist for a podcast. This returns an array of episodes.
     - Parameter domain: The domain of the podcast, e.g. `bananaland.podigee.io`.
     - Parameter pageSize: Maximum number of episodes this request should return. Defaults to 10.
     - Parameter offset: Offset for paging requests. Defaults to 0.
     - Parameter sortBy: Set the sorting of the returned episode playlist. Defaults to sorting by publish date.
     - Parameter complete: The closure called when the network request is finished. If successfull you receive an array of episodes.
     - returns: Void
     */
    public static func playlistForPodcastWith(domain: String, pageSize: Int = 10, offset: Int = 0, sortBy: PlaylistSorting = .publishDate, complete: @escaping (_ result: Result<Playlist, Error>) -> Void) {
        guard pageSize > 0 else {
            complete(.failure(PodigeeError.invalidPageSize))
            return
        }
        guard offset >= 0 else {
            complete(.failure(PodigeeError.invalidOffset))
            return
        }
        var components = URLComponents()
        components.host = domain
        components.path = "/embed/playlist"
        components.queryItems = [
            URLQueryItem(name: "context", value: "external"),
            URLQueryItem(name: "page_size", value: "\(pageSize)"),
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "playlist_order", value: sortBy.rawValue)
        ]
        components.scheme = "https"
        
        guard let url = components.url else {
            complete(.failure(PodigeeError.invalidPodcastDomain))
            return
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    complete(.failure(error))
                } else {
                    complete(.failure(PodigeeError.unknown))
                }
                return
            }
            do {
                let playlist = try jsonDecoder.decode(Playlist.self, from: data)
                complete(.success(playlist))
            } catch {
                complete(.failure(error))
            }
        }.resume()
    }
    
    
}
