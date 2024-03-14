import SwiftUI
import CoreData

struct ContentView: View {
    @State private var theme: Color = Color.white
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isAuthenticated") private var isAuthenticated: Bool = false
    @State private var profileInfo: ProfileView.PlayerInfo?
    @AppStorage("nickname") private var nickname: String = ""

    var body: some View {
        TabView {
            NavigationView {
                ProfileView(playerInfo: profileInfo ?? ProfileView.PlayerInfo(userID: 0, level: 0, currentXP: 0, nextLevelXP: 0, highestRank: 0, rating: 0, rank: 0, clanTag: "", clanName: ""))
            }
            .tabItem {
                NavigationLink(destination: ProfileView(playerInfo: profileInfo ?? ProfileView.PlayerInfo(userID: 0, level: 0, currentXP: 0, nextLevelXP: 0, highestRank: 0, rating: 0, rank: 0, clanTag: "", clanName: ""))) {
                    Image(systemName:  "gamecontroller")
                    Text("C-ops")
                }
            }
            
            NavigationView {
                TopView()
            }
            .tabItem {
                NavigationLink(destination: TopView()) {
                    Image(systemName: "star")
                    Text("Top")
                }
            }
        }
        .accentColor(theme)
        .onChange(of: colorScheme) { newColorScheme in
            if newColorScheme == .light {
                theme = Color.black
            } else {
                theme = Color.white
            }
        }
        .onAppear {
            if colorScheme == .light {
                theme = Color.black
            } else {
                theme = Color.white
            }
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    updateProfile()
                }
        }
    }
    
    
    func updateProfile() {
        let formattedUsername = nickname.replacingOccurrences(of: " ", with: "%20")
        fetchProfile(username: formattedUsername) { result in
            switch result {
            case .success(let profile):
                self.profileInfo = ProfileView.PlayerInfo(userID: profile.userID,
                                                           level: profile.level,
                                                           currentXP: profile.curxp,
                                                           nextLevelXP: profile.next_level_xp,
                                                           highestRank: profile.highestRank,
                                                           rating: profile.rating,
                                                           rank: profile.rank,
                                                           clanTag: profile.clanTag,
                                                           clanName: profile.clanName)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    
    func fetchProfile(username: String, completion: @escaping (Result<(userID: Int, level: Int, curxp: Int, next_level_xp: Int, highestRank: Int, rating: Double, rank: Int, clanTag: String, clanName: String), Error>) -> Void) {
        guard let url = URL(string: "https://api-cops.criticalforce.fi/api/public/profile?usernames=\(username)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let session = URLSession.shared

        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }

            if let resultString = String(data: data, encoding: .utf8) {
                let userIDRegex = try! NSRegularExpression(pattern: "'userID' => (\\d+),")
                let levelRegex = try! NSRegularExpression(pattern: "'level' => (\\d+),")
                let levelcurrent_xpRange = try! NSRegularExpression(pattern: "'current_xp' => (\\d+),")
                let next_level_xpRange = try! NSRegularExpression(pattern: "'next_level_xp' => (\\d+),")
                let highestRankRegex = try! NSRegularExpression(pattern: "'highest_rank' => (\\d+),")
                let ratingRegex = try! NSRegularExpression(pattern: "'rating' => (\\d+\\.\\d+),")
                let rankRegex = try! NSRegularExpression(pattern: "'rank' => (\\d+),")
                let clanNameRegex = try! NSRegularExpression(pattern: "'name' => '(.*?)',")
                let clanTagRegex = try! NSRegularExpression(pattern: "'tag' => '(.*?)',")

                if let userID = extractInt(from: userIDRegex, in: resultString),
                    let level = extractInt(from: levelRegex, in: resultString),
                    let curxp = extractInt(from: levelcurrent_xpRange, in: resultString),
                    let next_level_xp = extractInt(from: next_level_xpRange, in: resultString),
                    let highestRank = extractInt(from: highestRankRegex, in: resultString),
                    let rating = extractDouble(from: ratingRegex, in: resultString),
                    let clanTag = extractString(from: clanTagRegex, in: resultString, occurrence: 1),
                    let clanName = extractString(from: clanNameRegex, in: resultString, occurrence: 2),
                    let rank = extractInt(from: rankRegex, in: resultString) {

                    completion(.success((userID, level, curxp, next_level_xp, highestRank, rating, rank, clanTag, clanName)))
                } else {
                    completion(.failure(NSError(domain: "Failed to extract data", code: 0, userInfo: nil)))
                }
            } else {
                completion(.failure(NSError(domain: "Failed to convert data to string", code: 0, userInfo: nil)))
            }
        }

        task.resume()
    }

    func extractInt(from regex: NSRegularExpression, in string: String) -> Int? {
        guard let match = regex.firstMatch(in: string, range: NSRange(string.startIndex..., in: string)),
            let range = Range(match.range(at: 1), in: string) else {
            return nil
        }

        return Int(string[range])
    }

    func extractDouble(from regex: NSRegularExpression, in string: String) -> Double? {
        guard let match = regex.firstMatch(in: string, range: NSRange(string.startIndex..., in: string)),
            let range = Range(match.range(at: 1), in: string) else {
            return nil
        }

        return Double(string[range])
    }

    func extractString(from regex: NSRegularExpression, in string: String, occurrence: Int) -> String? {
        guard let match = regex.matches(in: string, range: NSRange(string.startIndex..., in: string)).dropFirst(occurrence - 1).first,
            let range = Range(match.range(at: 1), in: string) else {
            return nil
        }

        return String(string[range])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

