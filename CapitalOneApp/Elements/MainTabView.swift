import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            DashboardView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(0)
                .navigationBarBackButtonHidden(true)
            
            MovimientosView()
                .tabItem {
                   Image(systemName: "list.bullet")
                   Text("Movs")
                }
                .tag(1)
                .navigationBarBackButtonHidden(true)
            
            CoachView()
                .tabItem {
                    Image(systemName: "person.fill.checkmark")
                    Text("Coach")
                }
                .tag(2)
                .navigationBarBackButtonHidden(true)
            
            PagosView()
                .tabItem {
                    Image(systemName: "creditcard.fill")
                    Text("Transfer")
                }
                .tag(3)
                .navigationBarBackButtonHidden(true)
            
            SwipeView()
                .tabItem {
                    Image(systemName: "info.circle.fill")
                    Text("Details")
                }
                .tag(4)
                .navigationBarBackButtonHidden(true)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    MainTabView()
}

