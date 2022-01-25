//
//  SearchBar.swift
//  WeText
//
//  Created by Santhosh Srinivas on 17/12/21.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @State var isEditing = false
    var body: some View {
        HStack{
            TextField("Enter a Name to search", text: $text)
                .padding(15)
                .padding(.horizontal,40)
                .background(Color(.systemGray6))
                .foregroundColor(.primary)
                .cornerRadius(8)
                .overlay(
                    HStack{
                    Image(systemName: "magnifyingglass")
                            .font(.system(size: 20))
                        .foregroundColor(Color("NavBarColor1"))
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(15)
                    if isEditing{
                        Button{
                            self.text = ""
                            self.isEditing = false
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color("NavBarColor1"))
                                .padding(.trailing, 40)
                                .frame(width: 20, height: 20, alignment: .center)
                        }
                    }
                }
                ).onTapGesture {
                    self.isEditing = true
                }
//            if isEditing{
//                Button{
//                    self.isEditing = false
//                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                } label: {
//                    Text("Cancel")
//                        .foregroundColor(Color("NavBarColor1"))
//                }
//                .buttonStyle(.bordered)
//                .tint(Color("NavBarColor1"))
//            }
        }
        .padding(.horizontal,8)
    }
}


