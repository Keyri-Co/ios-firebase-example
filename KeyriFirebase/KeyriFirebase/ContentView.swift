//
//  ContentView.swift
//  KeyriFirebaseDemo
//
//  Created by Aditya Malladi on 6/22/22.
//

import SwiftUI
import keyri_pod
import FirebaseAuth

struct ContentView: View {
    
    @State var showView = false
    @State var url: URL? = nil
    @State private var username: String = "aditya@keyri.co"
    @State private var password: String = "LED123LED"

    
    var body: some View {
        
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                Button {
                    let scanner = Scanner()
                    scanner.completion = { str in
                        if let urlUnwrapped = URL(string: str) {
                            url = urlUnwrapped
                        }
                    }
                    scanner.show()
                } label: {
                    Text("Scan QR")
                        .font(.title2)
                        .padding()
                        .padding(.horizontal)
                }
                .buttonStyle(.bordered)
                
                TextField(
                    "User name (email address)",
                    text: $username
                )
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                
                TextField(
                    "Password",
                    text: $password
                )
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                
                Button {
                    print(username)
                    print(password)
                    
                    username = ""
                    password = ""
                    
                    if let url = url {
                        HandleQR.process(url: url, username: username, password: password)
                    }
                } label: {
                    Text("sign in")
                        .font(.title2)
                        .padding()
                        .padding(.horizontal)
                }
                .buttonStyle(.bordered)
                .disabled(url == nil)
                
                Button {
                    print(username)
                    print(password)
                    
//                    username = ""
//                    password = ""
                    
                    if let url = url {
                        HandleQR.register(username: username, password: password)
                    }
                } label: {
                    Text("Register")
                        .font(.title2)
                        .padding()
                        .padding(.horizontal)
                }
                .buttonStyle(.bordered)
                .disabled(url == nil)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class HandleQR {
    static func process(url: URL, username: String, password: String) {
        let sessionId = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems?.first(where: { $0.name == "sessionId" })?.value ?? ""
        print(username)
        print(password)
        Auth.auth().signIn(withEmail: "aditya@keyri.co", password: "LED123LED") {  authResult, error in

            let appKey = "SQzJ5JLT4sEE1zWk1EJE1ZGNfwpvnaMP" // Get this value from the Keyri Developer Portal
            print("\n In callback \n")
            print(authResult)
            print(error)
            guard let payload = authResult?.user.refreshToken else { return }

            let keyri = Keyri() // Be sure to import the SDK at the top of the file
            keyri.initializeQrSession(username: username, sessionId: sessionId, appKey: appKey) { res in
                switch res {
                case .success(var session):
                    // You can optionally create a custom screen and pass the session ID there. We recommend this approach for large enterprises
                    session.payload = payload

                    // In a real world example you’d wait for user confirmation first
                    do {
                        try session.confirm() // or session.deny()
                    } catch {
                        print(error)
                    }
                case .failure(let error):
                    print(error)
                }
                
            }

        }
        
    }
    
    static func register(username: String, password: String) {
        Auth.auth().createUser(withEmail: username, password: password) { result, error in
            print(result)
            print(result?.user)
            print(error)
        }
        
    }

}
