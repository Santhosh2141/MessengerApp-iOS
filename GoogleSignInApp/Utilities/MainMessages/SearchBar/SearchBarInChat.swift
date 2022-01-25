//
//  SearchBar.swift
//  WeText
//
//  Created by Santhosh Srinivas on 17/12/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct SearchBarInChat: View {
    
    @ObservedObject var vm: ChatLogViewModel
//    @ObservedObject var message: ChatMessage
    @Binding var text: String
    @State var isEditing = false
    @State var show = false
//    @State var timestamp: Date
    var body: some View {
        VStack{
            HStack{
                if !self.show{
                    VStack{
                        HStack{
//                            Spacer()
                            Image(systemName: "person.circle.fill")
                            .frame(width: 20, height: 20)
                                .font(.system(size: 25))
//                                .offset(x:-20)//,y:10)
                                .padding()
                                .foregroundColor(Color("Color3"))
        //                        .font(.system(size: 14))
        //                        .padding()
        //                        .foregroundColor(Color("Color3"))
        //                        .overlay(RoundedRectangle(cornerRadius: 90)
        //                                    .stroke(Color("Color3"), lineWidth: 1))
        //                    WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
        //                        .resizable()
        //                        .scaledToFill().frame(width: 30, height: 30)
        //                        .clipped()
        //                        .cornerRadius(30)
        //                        .overlay(RoundedRectangle(cornerRadius: 30) .stroke(.black, lineWidth: 2))
        ////                        .shadow(color: .black, radius: 2.5)
        //                        .offset(x: -50)
        //                        .shadow(color: .black, radius: 2.5)
//                            Spacer()
                            Text("\(vm.chatUser?.uName ?? "")")
        //                        .fontWeight(.bold)
                                .font(.headline)
//                                .offset(x:-10)//,y:10)
                            
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
//                            Spacer()
                        }
//                        Text("Last Seen: x mins ago")
//                            .font(.caption2)
//                            .offset(x:15, y:-15)
                    }
    //                HStack(spacing: 8){
                        
    //                }
    //                .padding(.vertical)
                }
//                Spacer()
                
                
//                Spacer()
//                Spacer(minLength: 0)
                if self.show {
                    Spacer()
                    TextField("Search...", text: $text)
    //                    .padding(5)
                        .padding(.horizontal,40)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                        .offset(x: -50)
                        .overlay(
                            HStack{
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color("NavBarColor1"))
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal,4)
                                .offset(x: -50)
                                if isEditing{
                                    Button{
                                        self.text = ""
                                        self.isEditing = false
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        withAnimation {
                                            
                                            self.show.toggle()
                                        }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(Color("NavBarColor1"))
                //                            .padding(.trailing, 8)
                                            .frame(width: 20, height: 20, alignment: .center)
                //                            .offset(x: -50)
    //                                        .padding(.horizontal,16)
                                    }
    //                                .buttonStyle(.bordered)
    //                                .tint(Color("NavBarColor1"))
                                }
                            }
                            .padding(.vertical, 8)
    //                            .background(Color("Color1"))
                        ).onTapGesture {
                            self.isEditing = true
                        }
    //                if isEditing{
    //                    Button{
    //                        self.text = ""
    //                        self.isEditing = false
    //                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    //                        withAnimation {
    //
    //                            self.show.toggle()
    //                        }
    //                    } label: {
    //                        Image(systemName: "xmark.circle.fill")
    //                            .foregroundColor(.blue)
    ////                            .padding(.trailing, 8)
    //                            .frame(width: 20, height: 20, alignment: .trailing)
    ////                            .offset(x: -50)
    //                    }
    //                }
                } else {
                        Button{
                            
                            withAnimation {
                                
                                self.show.toggle()
                            }
                            
                        } label: {
//                            Spacer()
//                            Spacer()
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color("NavBarColor1"))
                                .padding(10)
                                .offset(x: 20)
                        }
    //                    .foregroundColor(.blue)
                        .padding(!self.show ? 10 : 0)
    //                    .background(Color.white)
                        .cornerRadius(20)
                }
                
            }
        .padding(.horizontal,5)
//        .padding(.vertical,8)
//            Text("HI")
//            Text("\(timestamp.descriptiveString())")
        }
//        .padding(.vertical,20)
//        Text("Last seen: x mins ago")
    }
}


