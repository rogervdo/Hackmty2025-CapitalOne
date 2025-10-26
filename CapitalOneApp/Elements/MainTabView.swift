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
                   Image(systemName: "receipt.fill")
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
            
            MetaView()
                .tabItem {
                    Image(systemName: "creditcard.fill")
                    Text("Goals")
                }
                .tag(3)
                .navigationBarBackButtonHidden(true)
            
            PerfilView()
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Perfil")
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

