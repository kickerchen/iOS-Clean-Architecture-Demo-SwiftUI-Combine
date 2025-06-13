//
//  CurrencyCalculatorView.swift
//  CurrencyCalculator
//
//  Created by Kicker Chen on 2025/4/18.
//

import SwiftUI

///
/// A SwiftUI view to represent the content of currency calculator
///
struct CurrencyCalculatorView: View {
    @StateObject private var viewModel = CurrencyCalculatorViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Amount Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amount")
                            .font(.headline)

                        TextField("Please enter a number", text: $viewModel.amount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    // Currency Selection
                    HStack {
                        if let selectedCurrency = viewModel.selectedCurrency {
                            Text(selectedCurrency.fullName)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                        Picker("Select a currency", selection: $viewModel.selectedCurrency) {
                            ForEach(viewModel.currencies) {
                                Text("\($0.id)").tag($0 as Currency?)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    // Quotes Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ], spacing: 10) {
                        ForEach(viewModel.displayQuotes) {
                            quoteView(quote: $0)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Currency Converter")
            .overlay {
                if !viewModel.isReady {
                    loadingView()
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
            .dismissKeyboardOnTap()
            .task {
                await viewModel.fetchData()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    @ViewBuilder
    private func quoteView(quote: Quote) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(quote.id)
                .font(.title3)
                .foregroundColor(.secondary)
            Text("\(quote.rate)" as String)
                .font(.headline)
                .minimumScaleFactor(0.6)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 100, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    @ViewBuilder
    private func loadingView() -> some View {
        ZStack {
            Color.black.opacity(0.3)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))

                Text("Loading data...")
                    .font(.headline)
                    .foregroundColor(.white)

                Text("Please wait while we are fetching the latest data")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(30)
            .background(Color.black.opacity(0.7))
            .cornerRadius(15)
        }
    }
}

struct KeyboardDismissingView: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
            }
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(KeyboardDismissingView())
    }
}

#Preview {
    CurrencyCalculatorView()
}
