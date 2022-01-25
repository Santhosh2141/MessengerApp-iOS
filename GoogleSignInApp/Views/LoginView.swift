//
//  LoginPage.swift
//  GoogleSignInApp
//
//  Created by Santhosh Srinivas on 23/12/21.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct LoginView: View {
    let loginComplete: () -> ()

    @AppStorage("login_Status") var log_status = false
    var body: some View {
//        VStack{
//            Image("Onboard")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(height: getRect().height / 3)
//                .background(
//                        Circle()
//                            .fill(Color(red: 81/255, green: 172/255, blue: 177/255))
//                            .scaleEffect(2, anchor: .center)
//
//                )
//
//            padding()
//
//
//
//
//        }
//        .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .top)
//        Spacer()
        VStack{
            Image("Onboard")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: getRect().height / 3)
                .background(Circle() .fill(Color("OnboardColor")).scaleEffect(2, anchor: .center))
                            //(Color(red: 214/255, green: 99/255, blue: 76/255)).scaleEffect(2, anchor: .center))
            VStack(spacing: 20){
                    Image("Wicon1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 1400, height: 120)
                Spacer()
                Text("""
                     Welcome to
                     Peopleist Messenger
                     """)
                    .font(.largeTitle)
                    .fontWeight(.light)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .offset(y: -25)
                
                Spacer()
                
                Button{
                    handleLogin()
                } label: {
                    HStack{
                            Image("google")
                                .resizable()
                                .scaledToFit()
                                .padding(.leading)
                                .frame(width: 124, height: 40)
                                .offset(x: -18)
//                            Spacer()
                            Text("Sign In")
                            .font(.system(size: 28))
                                .fontWeight(.light)
                                .offset(x: -38)
                            .foregroundColor(Color(.black))
                                .padding(.vertical)
//                                .font(.largeTitle)//, .system(size: 20, weight: .heavy))
//                                .fontWeight(.light)
                                .multilineTextAlignment(.center)
//                            Spacer()
                        } // .background(Color("NavBarColor"))
//                            .clipShape(RoundedRectangle(cornerRadius: 15))
//                            .padding()
                    }
                .offset(y:-47)
//                .frame(maxWidth: 200, maxHeight: 10, alignment: .center)//width: 300, height: 30, alignment: .center)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 11))
                .tint(Color("OnboardColor"))//Color(red: 188/255, green: 222/255, blue: 246/255))
            }
            .padding()
//            .padding(.top)
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .top)
    }
    @State private var statusLogin = ""
    func handleLogin(){
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: getRootViewController()){[self] user, err in
            if let error = err {
                print(error.localizedDescription)
                return
              }

              guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
              else {
                return
              }

              let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { result, err in
                if let error = err {
                    print(error.localizedDescription)
                    return
                  }
//            var profileImageUrl = "\(user?.profile?.imageURL(withDimension: 320)?.path)"
                guard let user = result?.user else{
                    return
                }
                print(user.displayName ?? "Success!")
//            print(profileImageUrl)
            
            
            guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
            let userData = ["uid": uid,"uName": user.displayName]//, "profileImageUrl": profileImageUrl]
            FirebaseManager.shared.firestore.collection("users")
                .document(uid).setData(userData) { err in
                    if let err = err {
                        print(err)
                        self.statusLogin = "\(err)"
                        return
                    }

                    print("Success")
                    self.loginComplete()
                }
            withAnimation {
                log_status = true
            }
            }
        }
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView (loginComplete: {
            
        })
    }
}

extension View{
    func getRect() -> CGRect{
        return UIScreen.main.bounds
    }
    func getRootViewController() -> UIViewController{
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        guard let root = screen.windows.first?.rootViewController else{
            return .init()
        }
        return root
    }
}


