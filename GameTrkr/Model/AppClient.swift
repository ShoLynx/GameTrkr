//
//  AppClient.swift
//  GameTrkr
//
//  Created by Sean Foreman on 4/14/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import Foundation
import UIKit

class AppClient {
    
    //MARK: API keys and contact URLs
    
    static var apiKey = "AIzaSyBjm4J7pjXgBlJ5pU_3A09wFAwU-gt5Gs0"
    
    enum Endpoints {
        static let youtubeBase = "https://www.googleapis.com/youtube/v3/search?part=snippet&eventType=completed&order=rating"
        
        case getData(String, String)
        
        var stringValue: String {
            switch self {
                case .getData(let platformName, let gameTitle): return Endpoints.youtubeBase + "&q\(platformName)%2C%20\(gameTitle)=playlist&videoEmbeddable=true&key=\(apiKey)"
            }
        }
    }
    
    func getPlaylistVideo(platformName: String, gameTitle: String, completion: @escaping([Items]?, Error?) -> Void) {
        let originalString = "\(Endpoints.getData(platformName, gameTitle))"
        let urlString = originalString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let target = URL(string: urlString)!
        
        let task = URLSession.shared.dataTask(with: target) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            do {
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(YoutubeResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject.items, nil)
                    //figure out response and apply it here
                }
            } catch {
                do {
                    let decoder = JSONDecoder()
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                        print(String(data: data, encoding: .utf8)!)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                        print(error)
                    }
                }
            }
        }
        task.resume()
    }
}
