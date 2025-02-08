//
//  ContentView.swift
//  Vocabulary
//
//  Created by 曾品瑞 on 2024/2/17.
//

import SwiftUI

struct ContentView: View {
    //MARK:  Variable
    @State private var text: String=""
    @State private var random: (String, String)=(PRS.prefix+PRS.root+PRS.suffix).randomElement() ?? ("", "")
    
    private let title: [String]=["Prefix", "Root", "Suffix"]
    
    //MARK: check()
    private func check(answer: String) -> Bool {
        return (self.random.0=="pro" && self.text=="往前 用於") || (self.random.0=="ant" && self.text=="Adjective Noun") || (self.random.0=="ate" && self.text=="Adjective Noun Verb") || (self.random.0=="rupt" && self.text=="斷 破壞") || self.text==answer
    }
    //MARK: setData()
    private func setData(title: String) -> [(String, String)] {
        switch(title) {
        case "Prefix": return PRS.prefix
        case "Root": return PRS.root
        case "Suffix": return PRS.suffix
        default: return []
        }
    }
    
    //MARK: body
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    //MARK: PRSView
                    Section {
                        ForEach(self.title, id: \.self) { title in
                            NavigationLink(destination: PRSView(title: title, data: self.setData(title: title))) {
                                Text(title)
                            }
                        }
                    } header: {
                        Text("Warming up...")
                    }
                    .headerProminence(.increased)
                    
                    //MARK: QuizView
                    Section {
                        NavigationLink(destination: QuizView()) {
                            Text("Let's take a quick quiz!")
                        }
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(.gray)
                                .frame(height: 1)
                                .padding(.trailing, -20)
                                .offset(y: 10)
                        }
                        
                        VStack {
                            Text("Random Test").font(.title3)
                            
                            Text(self.random.0)
                                .font(.title2)
                                .foregroundStyle(self.random.0.hasPrefix("Press") ? Color(red: 50/255, green: 150/255, blue: 50/255):(self.random.0.hasPrefix(" ") ? .red:.primary))
                                .contentTransition(.numericText())
                        }
                        .bold()
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(.gray)
                                .frame(height: 1)
                                .padding(.trailing, -20)
                                .offset(y: 10)
                        }
                        
                        TextField("Answer", text: self.$text)
                            .font(.title3)
                            .submitLabel(.done)
                        
                        Button("CONFIRM") {
                            withAnimation(.snappy) {
                                let answer: String=self.random.1.replacingOccurrences(of: "、", with: " ").replacingOccurrences(of: ", ", with: " ")
                                
                                if(self.random.0.hasPrefix("Press") || self.random.0.hasPrefix(" ")) {
                                    self.random=(PRS.prefix+PRS.root+PRS.suffix).randomElement() ?? ("", "")
                                } else {
                                    if(self.check(answer: answer)) {
                                        self.random.0="Press CONFIRM to keep going!"
                                    } else {
                                        self.random.0=" \(self.random.1) "
                                    }
                                    
                                    self.text=""
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    } header: {
                        Text("Ready!")
                    }
                    .headerProminence(.increased)
                }
            }
            .navigationTitle("English")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
