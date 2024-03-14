//
//  TopView.swift
//  C-ops info
//
//  Created by andr on 09.03.2024.
//

import Foundation
import SwiftUI

struct Player: Identifiable, Decodable, Equatable {
    let rank: Int
    let name: String
    let tag: String?
    let rating: Int

    var id: Int { rank }
}



struct TopView: View {
    @State private var isServerSelectionVisible = false
    @AppStorage("elo") private var urElo: String = "0"
    @State private var urPlaceInTop: String = "0"
    @AppStorage("nickname") private var urNickName: String = "Your nickname"
    @Environment(\.colorScheme) var colorScheme
    @State private var isPopoverPresented = false
    @State private var theme: Color = Color.white
    @State private var searchText: String = ""
    
    struct PlayerInfo {
        var userID: Int = 0
        var level: Int
        var currentXP: Int
        var nextLevelXP: Int
        var highestRank: Int
        var rating: Double
        var rank: Int
        var clanTag: String
        var clanName: String
    }
    
    @State private var players: [Player] = [
        
    ]
    
    @State private var playersrealtop: [Player] = [
        
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {

                ZStack {
                    
                    if Int(urPlaceInTop)! <= 99 {
                        Circle()
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .frame(width: 30, height: 30)
                    }
                    
                    if Int(urPlaceInTop)! <= 99 {
                        Text(urPlaceInTop)
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .fontWeight(.medium)
                    } else {
                        Text(urPlaceInTop)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .fontWeight(.medium)
                    }
                    
                }
                .padding(.trailing, 5)

                
                
                Text(urNickName)
                    .fontWeight(.medium)
                    .padding(.trailing, 5)


                Text("")
                    .fontWeight(.medium)
                    .padding(.trailing, 5)
                
                HStack {
                    Spacer()





                    Image(systemName: "bolt.fill")


                    Text(urElo)



                }

            }
            .padding(.horizontal, 18)
            .padding(.vertical, 0)
            
            TextField("Search by nickname", text: $searchText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding([.leading, .trailing, .bottom], 16)
        
            
            ScrollView {
                
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(filteredPlayers.indices, id: \.self) { index in
                        let player = filteredPlayers[index]
                        HStack {
                            Text("\(player.rank)")
                                .fontWeight(.bold)
                                .frame(width: 40)


                            Text(player.name)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text("\(player.rating)")
                                .fontWeight(.medium)
                                .frame(width: 50, alignment: .trailing)
                            Image(systemName: "bolt.fill")
                        }
                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .background(Color.clear)
                    }
                    .padding(.trailing, 18)
                }
            }



            
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
            fetchLeaderboard()
            
            
        }
        
    }
    
    
    
    private var filteredPlayers: [Player] {
        if searchText.isEmpty {
            return players
        } else {
            let lowercasedSearchText = searchText.lowercased()
            let filtered = players.filter { $0.name.lowercased().contains(lowercasedSearchText) }
            if filtered.isEmpty {
                let newPlayer = Player(rank: 0, name: searchText, tag: nil, rating: 0)
                return [newPlayer]
            } else {
                return filtered.sorted { $0.rank < $1.rank }
            }
        }
    }



    private func urtop() {
        if let currentPlayer = players.first(where: { $0.name == urNickName }) {
            urElo = String(currentPlayer.rating)
            urPlaceInTop = "\(players.firstIndex(of: currentPlayer)! + 1)"
        } else {
            urElo = "0"
            urPlaceInTop = "0"
        }
    }

    
    
    

    private func fetchLeaderboard() {
        guard let url = URL(string: "https://default.prod.copsapi.criticalforce.fi/api/leaderboard/elite") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "Unknown error")
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                if let jsonArray = try? decoder.decode([Player].self, from: data) {
                    DispatchQueue.main.async {
                        players = jsonArray
                        urtop()
                    }
                } else if let phpArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    let jsonData = try JSONSerialization.data(withJSONObject: phpArray, options: [])
                    let playersArray = try decoder.decode([Player].self, from: jsonData)
                    
                    DispatchQueue.main.async {
                        players = playersArray
                        playersrealtop = playersArray
                        urtop()
                    }
                } else {
                    print("Unsupported server response format")
                    fetchLeaderboard()
                }
            } catch let decodingError as DecodingError {
                print("DecodingError: \(decodingError)")
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
            }
        }.resume()
    }


    

}


struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}
