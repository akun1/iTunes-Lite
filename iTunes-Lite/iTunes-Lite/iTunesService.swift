//
//  iTunesService.swift
//  iTunes-Lite
//
//  Created by Akash Kundu on 4/9/20.
//  Copyright © 2020 Akash Kundu. All rights reserved.
//

import Foundation

// From iTunes API Docs:
enum MediaKind: Int, CaseIterable {
    case book = 0
    case album
    case coachedAudio
    case featureMovie
    case interactiveBooklet
    case musicVideo
    case pdf
    case podcast
    case podcastEpisode
    case softwarePackage
    case song
    case tvEpisode
    case artistFor
    
    var string: String {
        switch self {
        case .book:
            return "book"
        case .album:
            return "album"
        case .coachedAudio:
            return "coached-audio"
        case .featureMovie:
            return "feature-movie"
        case .interactiveBooklet:
            return "interactive-booklet"
        case .musicVideo:
            return "music-video"
        case .pdf:
            return "pdf"
        case .podcast:
            return "podcast"
        case .podcastEpisode:
            return "podcast-episode"
        case .softwarePackage:
            return "software-package"
        case .song:
            return "song"
        case .tvEpisode:
            return "tv-episode"
        case .artistFor:
            return "artist-for"
        }
    }
}

struct iTunesServiceAPIResult: Codable {
    var id: Int // trackId (ID of entity)
    var name: String // name of entity
    var artwork: String // URL of the artwork
    var genre: String // Genre of entity
    var url: String // trackViewUrl
    
    init(from result: iTunesResult) {
        self.id = result.trackID ?? 0
        self.name = result.trackName ?? ""
        self.artwork = result.artworkUrl30 ?? ""
        self.genre = result.primaryGenreName ?? ""
        self.url = result.trackViewURL ?? ""
    }
}

final class iTunesService {
    static var shared = iTunesService()
    private var baseEnpoint = "https://itunes.apple.com/search?term="//jack+johnson
    
    public func searchItunes(with query: String, completion: @escaping ([iTunesResult]) -> Void) {
        guard let url = URL(string: baseEnpoint + query) else {
            completion([])
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion([])
                return
            }
            
            guard let response = try? JSONDecoder().decode(iTunesResponse.self, from: data) else {
                completion([])
                return
            }
            
            guard let results = response.results else {
                completion([])
                return
            }

            let kinds = Set(results.compactMap({ $0.kind }))
            
            var jsonArray = [String: [iTunesServiceAPIResult]]()
            for kind in kinds {
                jsonArray[kind] = results
                    .filter({ $0.kind == kind })
                    .compactMap({ iTunesServiceAPIResult(from: $0) })

                do {
                    let jsonData = try JSONEncoder().encode(jsonArray)
                    let jsonString = String(data: jsonData, encoding: .utf8)!
                    print(jsonString)
                } catch {
                    print(error)
                }
            }
            
            completion(results)
        }

        task.resume()
    }

}
