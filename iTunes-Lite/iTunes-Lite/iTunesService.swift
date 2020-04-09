//
//  iTunesService.swift
//  iTunes-Lite
//
//  Created by Akash Kundu on 4/9/20.
//  Copyright © 2020 Akash Kundu. All rights reserved.
//

import Foundation

final class iTunesService {
    static var shared = iTunesService()
    private var baseEnpoint = "https://itunes.apple.com/search?term="//jack+johnson
    
    public func makeReq(completion: @escaping (iTunesResponse?) -> Void) {
        guard let url = URL(string: baseEnpoint + "jack+johnson") else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion(nil)
                return
            }
            
            guard let response = try? JSONDecoder().decode(iTunesResponse.self, from: data) else {
                completion(nil)
                return
            }
            
            completion(response)
        }

        task.resume()
    }

}
