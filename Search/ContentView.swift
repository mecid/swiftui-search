//
//  ContentView.swift
//  Search
//
//  Created by Majid Jabrayilov on 22.06.21.
//
import SwiftUI

@MainActor final class SearchViewModel: ObservableObject {
    @Published var repos: [Repo] = []

    private let service: GithubService
    init(service: GithubService = .init()) {
        self.service = service
    }

    func search(matching query: String) async {
        do {
            repos = try await service.search(matching: query)
        } catch let error {
            repos = []
            print(error)
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var query = ""

    let suggestions: [String] = [
        "Swift", "SwiftUI", "Obj-C"
    ]

    var body: some View {
        NavigationView {
            List(viewModel.repos) { repo in
                VStack(alignment: .leading) {
                    Text(repo.name)
                        .font(.headline)
                    Text(repo.description ?? "")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Search")
            .searchable(text: $query) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Text(suggestion)
                        .searchCompletion(suggestion)
                }
            }
            .onChange(of: query) { newQuery in
                async { await viewModel.search(matching: query) }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
