//
//  AppClient.swift
//  GameTrkr
//
//  Created by Sean Foreman on 4/14/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import Foundation

class AppClient {
    
    //MARK: API keys and contact URLs
    
    static let apiKey = "AIzaSyBjm4J7pjXgBlJ5pU_3A09wFAwU-gt5Gs0"
    
    enum Endpoints {
        static let youtubeBase = "https://www.googleapis.com/youtube/v3/"
        
        case getData(String, String)
        
        var stringValue: String {
            switch self {
            case .getData(let platformName, let gameTitle): return Endpoints.youtubeBase + "search?part=snippet&maxResults=25&order=rating&q=\(platformName)" + " " + "\(gameTitle)&type=video&videoEmbeddable=true&key=\(apiKey)"
            }
        }
        
        var originalURL: String {
            return stringValue
        }
    }
    
    //MARK: Global Function
    //getPlaylistVideo grabs 25 video objects for use with GameDetailsController's Load Video button and Watch Another Video button.
    
    class func getPlaylistVideo(platformName: String, gameTitle: String, completion: @escaping([Items]?, Error?) -> Void) {
        let url = Endpoints.getData(platformName, gameTitle).originalURL
        let noSpaceURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        var request = URLRequest(url: URL(string: noSpaceURL)!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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
                    print(String(data: data, encoding: .utf8)!)
                }
            } catch {
                do {
                    //Grabs the API error message for error alerts
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
