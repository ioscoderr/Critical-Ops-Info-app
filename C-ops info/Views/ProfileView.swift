import SwiftUI

struct ProfileView: View {
    
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
    
    @AppStorage("nickname") private var nickname: String = ""
    @State private var isEditingNickname = false
    
    let ranks: [Int: String] = [
        9: "Elite ops",
        8: "Spec ops",
        7: "Master",
        6: "Diamond",
        5: "Platina",
        4: "Gold",
        3: "Silver",
        2: "Bronze",
        1: "Iron",
        0: "Unknown"
    ]
    
    var playerInfo: PlayerInfo
    
    var body: some View {
        VStack {
            HStack {
                
                
                if !playerInfo.clanTag.isEmpty {
                    Text("[\(playerInfo.clanTag)]")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                        .padding(.trailing, 2)
                }
                
                if isEditingNickname {
                    TextField("Nickname", text: $nickname)
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 20)
                        .frame(width: 180)
                        .onChange(of: nickname, perform: { value in
                            if value.count > 14 {
                                nickname = String(value.prefix(10))
                            }
                        })
                } else {
                    Text(nickname.isEmpty ? "Get info by nick" : nickname)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.vertical, 20)
                        .frame(width: 180)
                        .onTapGesture {
                            isEditingNickname = true
                        }
                }
            }
            
            if playerInfo.userID != 0 {
                Text("Level \(playerInfo.level)")
                    .font(.title)
                
                ProgressBar(value: Double(playerInfo.currentXP), maxValue: Double(playerInfo.nextLevelXP))
                    .frame(height: 10)
                    .padding(.horizontal)
            }
            
            if playerInfo.userID != 0 {
                HStack {
                    VStack(alignment: .leading) {
                        ProfileInfoRow(title: "User ID:", value: "\(playerInfo.userID)")
                        ProfileInfoRow(title: "Highest Rank:", value: ranks[playerInfo.highestRank] ?? "")
                        ProfileInfoRow(title: "Clan:", value: "\(playerInfo.clanName)")
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        ProfileInfoRow(title: "Rating:", value: "\(Int(playerInfo.rating))")
                        ProfileInfoRow(title: "Rank:", value: ranks[playerInfo.rank] ?? "")
                        ProfileInfoRow(title: "Clan tag:", value: "\(playerInfo.clanTag)")
                    }
                }
                .padding()
                
                Spacer()
            }
                
        }
        .padding()
    }
}


struct ProfileInfoRow: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Text(value)
        }
        .padding(.vertical, 2)
    }
}

struct ProgressBar: View {
    var value: Double
    var maxValue: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)
                
                Rectangle()
                    .frame(width: min(CGFloat(self.value / self.maxValue) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color.blue)
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(playerInfo: ProfileView.PlayerInfo(userID: 123,
                                                        level: 20,
                                                        currentXP: 500,
                                                        nextLevelXP: 20000,
                                                        highestRank: 5,
                                                        rating: 4.5,
                                                        rank: 9,
                                                        clanTag: "ABC",
                                                        clanName: "SwiftClan"))
    }
}

