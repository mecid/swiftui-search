//
//  GithubService.swift
//  Search
//
//  Created by Majid Jabrayilov on 23.06.21.
//

import Foundation

struct Repo: Decodable, Identifiable {
    var id: Int
    //    let owner: Owner
    let name: String
    let description: String?

    struct Owner: Decodable {
        let avatar: URL

        enum CodingKeys: String, CodingKey {
            case avatar = "avatar_url"
        }
    }
}

struct SearchResponse: Decodable {
    let items: [Repo]
}

final class GithubService {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }

    func search(matching query: String) async throws -> [Repo] {
        guard var urlComponents = URLComponents(string: "https://api.github.com/search/repositories") else { preconditionFailure("Can't create url components...")
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query)
        ]

        guard let url = urlComponents.url else {
            preconditionFailure("Can't create url from url components...")
        }

        let (data, _) = try await session.data(from: url)
        let response = try decoder.decode(SearchResponse.self, from: data)
        return response.items
    }
}
