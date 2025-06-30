//
//  MultiplicationGame.swift
//  Edutainment App
//
//  Created by Arthur Rocha
//

import SwiftUI

struct MultiplicationGame: View {
    @State private var isGameActive = false
    @State private var gameFinished = false
    @State private var selectedTable = 2
    @State private var numberOfQuestions = 5
    @State private var currentQuestion = 0
    @State private var score = 0
    @State private var questions: [Question] = []
    @State private var userAnswer = ""
    @State private var showingResult = false
    @State private var isCorrect = false
    
    var body: some View {
        NavigationView {
            if !isGameActive && !gameFinished {
                SettingsView(
                    selectedTable: $selectedTable,
                    numberOfQuestions: $numberOfQuestions,
                    startGame: startGame
                )
            } else if gameFinished {
                ResultView(
                    score: score,
                    totalQuestions: numberOfQuestions,
                    playAgain: resetGame
                )
            } else if !questions.isEmpty && currentQuestion < questions.count {
                GameView(
                    currentQuestion: currentQuestion,
                    totalQuestions: numberOfQuestions,
                    question: questions[currentQuestion],
                    userAnswer: $userAnswer,
                    score: score,
                    submitAnswer: submitAnswer
                )
            } else {
                VStack {
                    Text("Carregando...")
                        .font(.title)
                    ProgressView()
                }
            }
        }
        .alert(isCorrect ? "Correto! 🎉" : "Incorreto! 😔", isPresented: $showingResult) {
            Button("Próxima") {
                nextQuestion()
            }
        } message: {
            if isCorrect {
                Text("Parabéns! Você acertou!")
            } else if currentQuestion < questions.count {
                Text("A resposta correta era \(questions[currentQuestion].correctAnswer)")
            }
        }
    }
    
    func startGame() {
        generateQuestions()
        currentQuestion = 0
        score = 0
        userAnswer = ""
        isGameActive = true
        gameFinished = false
    }
    
    func generateQuestions() {
        questions = []
        for _ in 0..<numberOfQuestions {
            let multiplier = Int.random(in: 1...12)
            let answer = selectedTable * multiplier
            questions.append(Question(
                firstNumber: selectedTable,
                secondNumber: multiplier,
                correctAnswer: answer
            ))
        }
    }
    
    func submitAnswer() {
        guard let answer = Int(userAnswer) else { return }
        guard currentQuestion < questions.count else { return }
        
        isCorrect = answer == questions[currentQuestion].correctAnswer
        if isCorrect {
            score += 1
        }
        
        showingResult = true
    }
    
    func nextQuestion() {
        userAnswer = ""
        currentQuestion += 1
        
        if currentQuestion >= numberOfQuestions || currentQuestion >= questions.count {
            endGame()
        }
    }
    
    func endGame() {
        isGameActive = false
        gameFinished = true
    }
    
    func resetGame() {
        gameFinished = false
        isGameActive = false
    }
}

struct Question {
    let firstNumber: Int
    let secondNumber: Int
    let correctAnswer: Int
    
    var questionText: String {
        "\(firstNumber) × \(secondNumber) = ?"
    }
}

struct SettingsView: View {
    @Binding var selectedTable: Int
    @Binding var numberOfQuestions: Int
    let startGame: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("🎯 Tabuada Game")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Escolha a tabuada:")
                    .font(.headline)
                
                Stepper("Tabuada do \(selectedTable)", value: $selectedTable, in: 2...12)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Número de perguntas:")
                    .font(.headline)
                
                Picker("Número de perguntas", selection: $numberOfQuestions) {
                    Text("5 perguntas").tag(5)
                    Text("10 perguntas").tag(10)
                    Text("20 perguntas").tag(20)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Button(action: startGame) {
                Text("Começar Jogo!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(15)
            }
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct GameView: View {
    let currentQuestion: Int
    let totalQuestions: Int
    let question: Question
    @Binding var userAnswer: String
    let score: Int
    let submitAnswer: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Text("Pergunta \(currentQuestion + 1) de \(totalQuestions)")
                    .font(.headline)
                Spacer()
                Text("Pontuação: \(score)")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            .padding()
            
            Spacer()
            
            VStack(spacing: 20) {
                Text(question.questionText)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
                
                TextField("Sua resposta", text: $userAnswer)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 200)
            }
            
            Spacer()
            
            Button(action: submitAnswer) {
                Text("Responder")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            .disabled(userAnswer.isEmpty)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.green.opacity(0.3), Color.blue.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct ResultView: View {
    let score: Int
    let totalQuestions: Int
    let playAgain: () -> Void
    
    var percentage: Int {
        Int((Double(score) / Double(totalQuestions)) * 100)
    }
    
    var message: String {
        switch percentage {
        case 90...100:
            return "Excelente! Você é um gênio da matemática! 🧠✨"
        case 70...89:
            return "Muito bem! Você está indo muito bem! 🌟"
        case 50...69:
            return "Bom trabalho! Continue praticando! 💪"
        default:
            return "Não desista! A prática leva à perfeição! 📚"
        }
    }
    
    var emoji: String {
        switch percentage {
        case 90...100:
            return "🏆"
        case 70...89:
            return "🥇"
        case 50...69:
            return "🥈"
        default:
            return "🎯"
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text(emoji)
                .font(.system(size: 80))
            
            Text("Jogo Finalizado!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            VStack(spacing: 15) {
                Text("Sua pontuação:")
                    .font(.headline)
                
                Text("\(score) de \(totalQuestions)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.green)
                
                Text("(\(percentage)%)")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Text(message)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(15)
            
            Spacer()
            
            Button(action: playAgain) {
                Text("Jogar Novamente")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(15)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

#Preview {
    MultiplicationGame()
}
