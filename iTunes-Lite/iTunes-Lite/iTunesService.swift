//
//  iTunesService.swift
//  iTunes-Lite
//
//  Created by Akash Kundu on 4/9/20.
//  Copyright © 2020 Akash Kundu. All rights reserved.
//

import Foundation

/// Object for internally formatted JSON result.
struct iTunesServiceAPIResult: Codable {
    var id: Int
    var name: String
    var artwork: String
    var genre: String
    var url: String
    
    init(from result: iTunesResult) {
        self.id = result.trackID ?? 0
        self.name = result.trackName ?? ""
        self.artwork = result.artworkUrl100 ?? ""
        self.genre = result.primaryGenreName ?? ""
        self.url = result.trackViewURL ?? ""
    }
}

final class iTunesService {
    
    // MARK: - Properties
    
    static var shared = iTunesService()
    private var baseEnpoint = "https://itunes.apple.com/search?term="
    
    // MARK: - Private APIs for iTunes Calls
    
    /// Search iTunes via given api.
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
