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
    
    public func makeReq() {
        guard let url = URL(string: baseEnpoint + "jack+johnson") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else {
                return
            }
            
            guard let response = try? JSONDecoder().decode(iTunesResponse.self, from: data) else {
                return
            }
        }

        task.resume()
    }

}
