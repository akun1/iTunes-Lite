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


/// Object for internally formatted JSON result.
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
    
    // MARK: - Properties
    
    static var shared = iTunesService()
    private var baseEnpoint = "https://itunes.apple.com/search?term="
    
    // MARK: - Private APIs for iTunes Calls
    
    /// Searches itunes via given api.
    private func searchItunes(with query: String, completion: @escaping ([iTunesResult]) -> Void) {
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
            
            completion(results)
        }

        task.resume()
    }
    
    /// Creates json from results from itunes search in desired format.
    private func constructJSON(results: [iTunesResult]) -> String? {
        let kinds = Set(results.compactMap({ $0.kind }))
        
        var jsonArray = [String: [iTunesServiceAPIResult]]()
        for kind in kinds {
            jsonArray[kind] = results
                .filter({ $0.kind == kind })
                .compactMap({ iTunesServiceAPIResult(from: $0) })
        }
        
        guard let jsonData = try? JSONEncoder().encode(jsonArray) else {
            return nil
        }
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        
        return jsonString
    }
    
    // MARK: - Private APIs for Internal Calls
    
    /// Take the JSON that we formatted according to the assignment requirements and convert into objects for use within the app.
    private func parseInternalJSON(json: String) -> [String: [iTunesServiceAPIResult]] {
        guard let data = json.data(using: .utf8) else {
            return [:]
        }
        
        guard let internalResponse = try? JSONDecoder().decode([String: [iTunesServiceAPIResult]].self, from: data) else {
            return [:]
        }
        
        return internalResponse
    }
    
    // MARK: - Public APIs

    public func search(with query: String, completion: @escaping ([String: [iTunesServiceAPIResult]]) -> Void) {
        /// Make call to iTunes API.
        searchItunes(with: query) { [weak self] results in
            
            /// Format JSON as desired to fulfill assignment requirements.
            guard let json = self?.constructJSON(results: results) else {
                completion([:])
                return
            }
            
            /// Convert JSON to objects that can be used to populate TableView to fulfill assignment requirements.
            guard let internalResult = self?.parseInternalJSON(json: json) else {
                completion([:])
                return
            }
            
            /// Note: I would not normally do the extra conversion, but I did so in order to show that the API is returning the JSON in the format we want.
            completion(internalResult)
        }
    }

}
