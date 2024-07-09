//
//  ChallengeView.swift
//  PokeDex
//
//  Created by 翁廷豪 on 2024/6/13.
//

import SwiftUI

struct ChallengeView: View {
    @EnvironmentObject var viewModel: PokemonViewModel
    @State private var questionType: QuestionType = .height
    @State private var options: [Pokemon] = []
    @State private var correctAnswer: Pokemon?
    @State private var showResult: Bool = false
    @State private var isCorrect: Bool = false
    @State private var challengeScore: Int = 0
    @State private var currentQuestion: Int = 0
    @State private var gameStarted: Bool = false
    @State private var showGameOver: Bool = false
    
    enum QuestionType {
        case height, weight
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if !gameStarted {
                    VStack {
                        Text("寶可夢猜謎遊戲")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                        Button(action: {
                            startGame()
                        }) {
                            Text("開始遊戲")
                                .font(.title)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                } else if showGameOver {
                    VStack {
                        Text("遊戲結束")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                        Text("你答對了 \(challengeScore) 題")
                            .font(.title)
                            .padding()
                        Button(action: {
                            restartGame()
                        }) {
                            Text("再玩一次")
                                .font(.title)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                } else {
                    Text(questionType == .height ? "哪隻寶可夢身高比較高？" : "哪隻寶可夢體重比較重？")
                        .font(.title)
                        .padding()
                    
                    Text("第 \(currentQuestion)/6 題")
                        .font(.title2)
                        .padding(.top, 10)
                    
                    HStack(spacing: 40) {
                        ForEach(options, id: \.id) { pokemon in
                            VStack {
                                if let url = URL(string: pokemon.sprites.frontDefault) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 150, height: 150)
                                                .background(Color.white)
                                                .cornerRadius(20)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(Color.blue, lineWidth: 2)
                                                )
                                                .shadow(radius: 10)
                                        case .failure:
                                            Image(systemName: "xmark.circle")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 150, height: 150)
                                                .background(Color.white)
                                                .cornerRadius(20)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(Color.red, lineWidth: 2)
                                                )
                                                .shadow(radius: 10)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                                
                                Text(pokemon.name.capitalized)
                                    .font(.title2)
                                    .foregroundColor(.black)
                            }
                            .onTapGesture {
                                withAnimation {
                                    checkAnswer(selected: pokemon)
                                }
                            }
                        }
                    }
                    
                    Text("當前分數: \(challengeScore)")
                        .font(.title2)
                        .padding(.top, 20)
                }
            }
            .navigationTitle("寶可夢挑戰")
            .alert(isPresented: $showResult) {
                Alert(
                    title: Text(isCorrect ? "答對了！" : "答錯了！"),
                    message: Text(isCorrect ? "恭喜你答對了！" : "很可惜，請再接再厲！"),
                    dismissButton: .default(Text("下一題"), action: {
                        if currentQuestion < 6 {
                            generateQuestion()
                        } else {
                            gameOver()
                        }
                    })
                )
            }
        }
    }
    
    func startGame() {
        gameStarted = true
        challengeScore = 0
        currentQuestion = 0
        generateQuestion()
    }
    
    func restartGame() {
        gameStarted = false
        showGameOver = false
    }
    
    func generateQuestion() {
        guard viewModel.pokemons.count >= 2 else { return }
        
        questionType = Bool.random() ? .height : .weight
        options = Array(viewModel.pokemons.shuffled().prefix(2))
        
        if questionType == .height {
            correctAnswer = options.max(by: { $0.height < $1.height })
        } else {
            correctAnswer = options.max(by: { $0.weight < $1.weight })
        }
        currentQuestion += 1
    }
    
    func checkAnswer(selected: Pokemon) {
        if selected.id == correctAnswer?.id {
            isCorrect = true
            challengeScore += 1
        } else {
            isCorrect = false
        }
        showResult = true
    }
    
    func gameOver() {
        showGameOver = true
        if challengeScore > viewModel.challengeScore {
            viewModel.challengeScore = challengeScore
        }
    }
}
