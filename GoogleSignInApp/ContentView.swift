//
//  ContentView.swift
//  GoogleSignInApp
//
//  Created by Santhosh Srinivas on 23/12/21.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct ContentView: View {
    @AppStorage("login_Status") var log_status = false

    var body: some View {
        
        VStack{
            if log_status {
                MainMsgView()
//                NavigationView{
//                    VStack{
//                        Text("Logged In")
//                        Button {
//                            GIDSignIn.sharedInstance.signOut()
//                            try? Auth.auth().signOut()
//                            withAnimation {
//                                log_status = false
//                            }
//                        } label: {
//                            Text("Logged Out")
//                        }
//                    }
//                }
            } else {
                LoginView(loginComplete: {
                    
                })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



