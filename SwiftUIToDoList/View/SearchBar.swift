//
//  SearchBar.swift
//  SwiftUIToDoList
//
//  Created by Mark Chang on 2026/3/10.
//

import SwiftUI

//struct SearchBar: UIViewRepresentable {
//    @Binding var text: String
//    
//    func makeUIView(context: Context) -> some UIView {
//        let searchBar = UISearchBar()
//        searchBar.searchBarStyle = .minimal
//        searchBar.autocapitalizationType = .none
//        searchBar.placeholder = "Search..."
//        searchBar.delegate = context.coordinator
//        return searchBar
//    }
//    
//    func updateUIView(_ uiView: UIViewType, context: Context) {
//        if let searchBar = uiView as? UISearchBar {
//            searchBar.text = text
//        }
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator($text)
//    }
//
//}

// 客製化 SearchBar
struct SearchBar: View {
    @Binding var text: String

    @State private var isEditing = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        HStack {

            TextField("Search ...", text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .focused($isTextFieldFocused)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)

                        if isEditing {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundStyle(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
                .onChange(of: isTextFieldFocused) { _, newValue in
                    withAnimation {
                        isEditing = newValue
                    }
                }

            if isEditing {
                Button(action: {
                    isEditing = false
                    text = ""
                    isTextFieldFocused = false
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
            }
        }
    }
}

#Preview {
    SearchBar(text: .constant(""))
}


class Coordinator: NSObject, UISearchBarDelegate {
    @Binding var text: String

    init(_ text: Binding<String>) {
        self._text = text
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = true
        text = searchText

        print("textDidChange: \(searchText)")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        text = ""
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }

}
