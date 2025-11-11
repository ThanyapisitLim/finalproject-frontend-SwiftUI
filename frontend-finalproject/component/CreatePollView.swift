//
//  CreatePollView.swift
//  frontend-finalproject
//
//  Created by Assistant on 30/10/2568 BE.
//

import SwiftUI

struct CreatePollView: View {
    //Var
    let userId: String
    var onCreated: (Poll.PollModel) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var question: String = ""
    @State private var options: [String] = ["", ""]
    @State private var expireDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                //Question Section
                Section(header: Text("Question")) {
                    TextField("Enter your question", text: $question)
                        .textInputAutocapitalization(.sentences)
                }
                
                //Dynamic Choices
                Section(header: Text("Choices")) {
                    ForEach(options.indices, id: \.self) { index in
                        HStack {
                            TextField("Choice \(index + 1)", text: Binding(
                                get: { options[index] },
                                set: { options[index] = $0 }
                            ))
                            .textInputAutocapitalization(.sentences)

                            //Minus Button
                            if options.count > 2 {
                                Button(role: .destructive) {
                                    options.remove(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    Button {
                        options.append("")
                    } label: {
                        Label("Add Choice", systemImage: "plus.circle.fill")
                    }
                }
                
                //Picker Date Section
                Section(header: Text("End date and time")) {
                    DatePicker("Expires", selection: $expireDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Create Poll")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { Task { await submit() } }
                        .disabled(!isValid || isSubmitting)
                }
            }
            .overlay {
                if isSubmitting {
                    ProgressView("Creating…")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
            }
        }
    }

    //Check Valid
    private var isValid: Bool {
        let trimmedQuestion = question.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedOptions = options.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let nonEmptyOptions = trimmedOptions.filter { !$0.isEmpty }
        let uniqueOptions = Set(nonEmptyOptions)
        let future = expireDate > Date()

        return !trimmedQuestion.isEmpty && nonEmptyOptions.count >= 2 && uniqueOptions.count == nonEmptyOptions.count && future
    }

    //Submit to Post Create Poll
    private func submit() async {
        guard isValid else { return }
        isSubmitting = true
        errorMessage = nil

        do {
            let created = try await Poll.shared.createPoll(
                userId: userId,
                question: question.trimmingCharacters(in: .whitespacesAndNewlines),
                options: options.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) },
                expireAt: expireDate
            )
            onCreated(created)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isSubmitting = false
    }
}
