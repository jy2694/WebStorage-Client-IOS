//
//  ContentView.swift
//  WebStorage
//
//  Created by 김제연 on 10/23/23.
//

import SwiftUI

struct ContentView: View {
    
    @State var ip: String = ""
    @State var port: String = ""
    @State var session: UUID? = nil
    @State var fileStructure: [[String:String]] = []
    @State var nowPath : String = "/"
    @State var history : [String] = []
    @State var logout: Bool = false
    var active : Bool {
        return session != nil
    }
    
    var body: some View {
        NavigationStack{
            LoginView(ip: $ip, port: $port, session: $session, fileStructure: $fileStructure, logout: $logout)
            NavigationLink(
                destination: FileView(fileStructure: $fileStructure, nowPath: $nowPath, history: $history, ip: $ip, port: $port, session: $session, logout: $logout),
                isActive: .constant(active),
                label: {
                    EmptyView()
                })
        }
        .onAppear{
            print(port)
        }
    }
}

#Preview {
    ContentView()
}
