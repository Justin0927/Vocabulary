//
//  QuizView.swift
//  Vocabulary
//
//  Created by 曾品瑞 on 2024/2/17.
//

import SwiftUI

struct QuizView: View {
    //MARK: Variable
    @State private var hint: Bool=false
    @State private var show: Bool=false
    @State private var count: Int=0
    @State private var correct: Int=0
    @State private var incorrect: Int=0
    @State private var answer: String=""
    @State private var question: (String, String)?
    @State private var prs: [(String, String)]=[]
    @State private var review: [(String, String)]=[]
    
    private let length: Int=PRS.prefix.count+PRS.root.count+PRS.suffix.count
    
    //MARK: check()
    private func check() -> Bool {
        if let question=self.question {
            var answer: String=""
            
            if let regex=try? NSRegularExpression(pattern: "\\s*\\(.*?\\)", options: []) {
                let range: NSRange=NSRange(location: 0, length: question.1.utf16.count)
                answer = regex.stringByReplacingMatches(
                    in: question.1,
                    options: [],
                    range: range,
                    withTemplate: ""
                )
            }
            answer=answer.replacingOccurrences(of: "、", with: " ").replacingOccurrences(of: ", ", with: " ")
            
            return self.answer==answer
        } else {
            return false
        }
    }
    
    //MARK: body
    var body: some View {
        ZStack(alignment: .top) {
            Color(.systemGray5).ignoresSafeArea()
            
            //MARK: Score
            VStack {
                Text("\(self.count)／\(self.length)")
                    .bold()
                    .font(.largeTitle)
                    .contentTransition(.numericText())
                    .padding(.bottom)
                
                HStack {
                    Text("\(self.correct)").foregroundStyle(self.count==0 ? .gray:Color(red: 50/255, green: 150/255, blue: 50/255))
                    
                    Spacer()
                    
                    if(self.hint) {
                        if let question=self.question {
                            Text(question.1)
                                .font(.headline)
                                .transition(.blurReplace)
                        }
                        
                        Spacer()
                    }
                    
                    Text("\(self.incorrect)").foregroundStyle(self.count==0 ? .gray:.red)
                }
                .bold()
                .font(.largeTitle)
                .contentTransition(.numericText())
                .padding([.horizontal, .horizontal])
                
                VStack(spacing: 50) {
                    if let question=self.question {
                        //MARK: Question
                        Text(question.0)
                            .bold()
                            .font(question.0.count<=20 ? .title:.title2)
                            .contentTransition(.numericText())
                            .transition(.blurReplace)
                    } else {
                        //MARK: Prefix + Root + Suffix
                        Text("Prefix + Root + Suffix")
                            .bold()
                            .font(.title)
                            .contentTransition(.numericText())
                            .transition(.blurReplace)
                    }
                    
                    VStack(spacing: 0) {
                        //MARK: Answer
                        TextField("Answer", text: self.$answer)
                            .disabled(self.count==0)
                            .padding(.horizontal)
                            .submitLabel(.done)
                        
                        Capsule()
                            .foregroundStyle(self.count==0 ? .gray:.primary)
                            .frame(height: 1)
                    }
                    .font(.title)
                    
                    //MARK: Button
                    Button {
                        withAnimation(.snappy) {
                            self.hint=false
                            
                            if(self.count==0) {
                                self.correct=0
                                self.incorrect=0
                                self.review=[]
                                self.prs=PRS.prefix+PRS.root+PRS.suffix
                            } else {
                                if(self.check()) {
                                    self.correct+=1
                                } else {
                                    self.incorrect+=1
                                    if let question=self.question {
                                        self.review.append(question)
                                    }
                                }
                                self.answer=""
                            }
                            
                            self.count=(self.count<self.length ? self.count+1:0)
                            self.question=self.prs.randomElement()
                            if let question=self.question,
                               let index=self.prs.firstIndex(where: { $0==question }) {
                                self.prs.remove(at: index)
                            }
                        }
                    } label: {
                        Text(self.count==0 ? "START":self.count==self.length ? "DONE":"NEXT")
                            .bold()
                            .font(.title3)
                            .foregroundStyle(.black)
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity)
                            .background(.white, in: .rect(cornerRadius: 10))
                            .opacity((self.count>0 && self.answer.isEmpty) ? 0.5:1)
                    }
                    .disabled(self.count>0 && self.answer.isEmpty)
                }
                .padding([.vertical, .vertical, .horizontal])
                .background(Color(.systemGray6), in: .rect(cornerRadius: 30))
            }
            .padding(.horizontal)
        }
        .ignoresSafeArea(.keyboard)
        //MARK: Sheet
        .sheet(isPresented: self.$show) {
            NavigationStack {
                List {
                    ForEach(self.review.indices, id: \.self) { index in
                        Section {
                            Text(self.review[index].1)
                        } header: {
                            Text(self.review[index].0)
                                .bold()
                                .font(self.review[index].0.count<=20 ? .title2:.title3)
                                .foregroundStyle(Color.primary)
                        }
                    }
                }
                .listStyle(.sidebar)
                .navigationTitle("Review")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        //MARK: Toolbar
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Hint") {
                    withAnimation(.snappy) {
                        self.hint.toggle()
                    }
                }
                .disabled(self.count==0)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Review") {
                    withAnimation(.snappy) {
                        self.show.toggle()
                    }
                }
                .disabled(self.review.isEmpty)
            }
        }
    }
}
