//
//  Menubar.swift
//  CapitalOneApp
//
//  Created by Rogelio Villarreal on 10/25/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
//            DashboardView()
//                .tabItem {
//                    Image(systemName: "house.fill")
//                    Text("Dashboard")
//                }
//            
//            MovimientosView()
//                .tabItem {
//                    Image(systemName: "list.bullet")
//                    Text("Movimientos")
//                }
            
            CoachView()
                .tabItem {
                    Image(systemName: "person.fill.checkmark")
                    Text("Coach")
                }
            
            PagosView()
                .tabItem {
                    Image(systemName: "creditcard.fill")
                    Text("Pagos")
                }
            
            SwipeView()
                .tabItem {
                    Image(systemName: "info.circle.fill")
                    Text("Details")
                }
        }
    }
}

#Preview {
    MainTabView()
}

