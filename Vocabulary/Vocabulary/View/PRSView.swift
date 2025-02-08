//
//  PRSView.swift
//  Vocabulary
//
//  Created by 曾品瑞 on 2024/2/17.
//

import SwiftUI

struct PRSView: View {
    //MARK: Variable
    let title: String
    let data: [(String, String)]
    
    @State private var current: Character?
    @State private var expand: [Bool]
    @State private var letter: [Character]=[]
    @State private var index: [Character:Int]=[:]
    
    //MARK: initial
    init(title: String, data: [(String, String)]) {
        self.title=title
        self.data=data
        self.expand=Array(repeating: true, count: data.count)
        
        var map: [Character:Int]=[:]
        for (index, (word, _)) in data.enumerated() {
            if let first = word.first?.uppercased().first {
                if(map[first]==nil) {
                    map[first]=index
                }
            }
        }
        
        let sort: [Character]=map.keys.sorted()
        self._letter=State(initialValue: sort)
        self._index=State(initialValue: map)
    }
    
    //MARK: body
    var body: some View {
        ScrollViewReader { scroll in
            ZStack(alignment: .trailing) {
                //MARK: List
                List {
                    ForEach(self.expand.indices, id: \.self) { index in
                        Section(isExpanded: self.$expand[index]) {
                            Text(self.data[index].1).font(.title3)
                        } header: {
                            Text(self.data[index].0)
                                .bold()
                                .font(self.data[index].0.count<=20 ? .title2:.title3)
                                .foregroundStyle(Color.primary)
                                .id(index)
                        }
                    }
                }
                .tint(Color.primary)
                .listStyle(.sidebar)
                .scrollIndicators(.hidden)
                .padding(.trailing, 30)
                .safeAreaInset(edge: .top) {
                    Color.clear.frame(height: 40)
                }
                
                //MARK: Letter
                VStack {
                    ForEach(self.letter, id: \.self) { letter in
                        Text("\(letter)")
                            .bold(self.current==letter)
                            .font(self.current==letter ? .title:.callout)
                            .foregroundStyle(.primary)
                            .onTapGesture {
                                self.current=letter
                                if let index=self.index[letter] {
                                    Task {
                                        await Task.yield()
                                        withAnimation(.easeInOut) {
                                            scroll.scrollTo(index, anchor: .top)
                                        }
                                    }
                                }
                            }
                    }
                }
                .frame(width: 30)
                .contentShape(.rect)
            }
        }
        .navigationTitle(self.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
