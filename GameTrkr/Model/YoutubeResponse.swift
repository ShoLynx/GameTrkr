//
//  YoutubeResponse.swift
//  GameTrkr
//
//  Created by Sean Foreman on 4/14/19.
//  Copyright © 2019 Sean Foreman. All rights reserved.
//

import Foundation

struct YoutubeResponse: Codable {
    let kind: String?
    let etag: String?
    let nextPageToken: String?
    let prevPageToken: String?
    let regionCode: String?
    let pageInfo: PageInfo
    let items: [Items]
}

struct PageInfo: Codable {
    let totalResults: Int?
    let resultsPerPage: Int?
}

struct Items: Codable {
    let kind: String?
    let etag: String?
    let id: Id
    let snippet: Snippet
    let channelTitle: String?
    let liveBroadcastContent: String?
}

struct Id: Codable {
    let kind: String?
    let videoId: String?
}

struct Snippet: Codable {
    let publishedAt: String?
    let channelId: String?
    let title: String?
    let description: String?
    let thumbnails: Thumbnails
}

struct Thumbnails: Codable {
    let defaultSet: DefaultSet
    let medium: Medium
    let high: High
    
    enum CodingKeys: String, CodingKey {
        case defaultSet = "default"
        case medium
        case high
    }
}

struct DefaultSet: Codable {
    let url: String?
    let width: Int?
    let height: Int?
}

struct Medium: Codable {
    let url: String?
    let width: Int?
    let height: Int?
}

struct High: Codable {
    let url: String?
    let width: Int?
    let height: Int?
}
