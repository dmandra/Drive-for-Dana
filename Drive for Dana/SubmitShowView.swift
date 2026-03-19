//
//  SubmitShowView.swift
//  Drive for Dana
//
//  Created by Donald Mandra on 3/19/26.
//

import SwiftUI
import MessageUI

struct SubmitShowView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Form fields
    @State private var date = ""
    @State private var club = ""
    @State private var name = ""
    @State private var time = ""
    @State private var description = ""
    @State private var location = ""
    @State private var address = ""
    @State private var carFee = ""
    @State private var spectatorFee = ""
    @State private var notes = ""
    @State private var contact = ""
    @State private var email = ""
    @State private var website = ""
    @State private var rainDate = ""
    @State private var vendors = ""
    @State private var vendorFee = ""
    
    // UI State
    @State private var showingMailView = false
    @State private var showingSuccess = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Event Information").foregroundColor(.black)) {
                    DatePicker("Date (Required)", selection: Binding(
                        get: {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "M/d/yyyy"
                            return formatter.date(from: date) ?? Date()
                        },
                        set: { newDate in
                            let formatter = DateFormatter()
                            formatter.dateFormat = "M/d/yyyy"
                            date = formatter.string(from: newDate)
                        }
                    ), displayedComponents: .date)
                    
                    TextField("Club or Organization", text: $club)
                    TextField("Show Name (Required)", text: $name)
                    TextField("Time - Start/End", text: $time)
                        .textInputAutocapitalization(.never)
                }
                
                Section(header: Text("Details").foregroundColor(.black)) {
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    TextField("Location Name", text: $location)
                    TextField("Address", text: $address)
                        .textInputAutocapitalization(.words)
                }
                
                Section(header: Text("Fees").foregroundColor(.black)) {
                    TextField("Car Fee", text: $carFee)
                        .textInputAutocapitalization(.never)
                    TextField("Spectator Fee", text: $spectatorFee)
                        .textInputAutocapitalization(.never)
                    TextField("Vendor Fee", text: $vendorFee)
                        .textInputAutocapitalization(.never)
                }
                
                Section(header: Text("Additional Information").foregroundColor(.black)) {
                    TextField("Vendors - yes/no", text: $vendors)
                    TextField("Rain Date", text: $rainDate)
                        .textInputAutocapitalization(.never)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section(header: Text("Contact Information").foregroundColor(.black)) {
                    TextField("Phone", text: $contact)
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    TextField("Website", text: $website)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                }
                
                Section {
                    Button(action: submitShow) {
                        HStack {
                            Spacer()
                            Text("Submit Car Show")
                                //.bold()
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.15))
                        .cornerRadius(8)
                    }
                    .disabled(name.isEmpty || date.isEmpty)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Submit Your Show")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingMailView) {
                MailView(
                    subject: "Car Show Submission from app",
                    recipients: ["dmandradfd@hotmail.com", "drivefordana@hotmail.com"],
                    //recipients: ["drivefordana@hotmail.com"],
                    body: generateEmailBody(),
                    onDismiss: { result in
                        handleMailResult(result)
                    }
                )
            }
            .alert("Success!", isPresented: $showingSuccess) {
                Button("OK") {
                    clearFields()
                    dismiss()
                }
            } message: {
                Text("Your car show submission has been sent successfully!")
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func submitShow() {
        // Check if mail is available
        if MFMailComposeViewController.canSendMail() {
            showingMailView = true
        } else {
            errorMessage = "Mail services are not available. Please configure an email account in your device settings."
            showingError = true
        }
    }
    
    private func generateEmailBody() -> String {
        var body = "Car Show Submission\n"
        body += "==================\n\n"
        body += "DATE: \(date)\n"
        body += "CLUB: \(club)\n"
        body += "NAME: \(name)\n"
        body += "TIME: \(time)\n"
        body += "DESCRIPTION: \(description)\n"
        body += "LOCATION: \(location)\n"
        body += "ADDRESS: \(address)\n"
        body += "CAR FEE: \(carFee)\n"
        body += "SPECTATOR FEE: \(spectatorFee)\n"
        body += "NOTES: \(notes)\n"
        body += "PHONE: \(contact)\n"
        body += "EMAIL: \(email)\n"
        body += "WEBSITE: \(website)\n"
        body += "RAIN DATE: \(rainDate)\n"
        body += "VENDORS: \(vendors)\n"
        body += "VENDOR FEE: \(vendorFee)\n"
        
        return body
    }
    
    private func handleMailResult(_ result: Result<MFMailComposeResult, Error>) {
        switch result {
        case .success(let mailResult):
            switch mailResult {
            case .sent:
                showingSuccess = true
            case .cancelled:
                // User cancelled, do nothing
                break
            case .saved:
                showingSuccess = true
            case .failed:
                errorMessage = "Failed to send email. Please try again."
                showingError = true
            @unknown default:
                break
            }
        case .failure(let error):
            errorMessage = "Error: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    private func clearFields() {
        date = ""
        club = ""
        name = ""
        time = ""
        description = ""
        location = ""
        address = ""
        carFee = ""
        spectatorFee = ""
        notes = ""
        contact = ""
        email = ""
        website = ""
        rainDate = ""
        vendors = ""
        vendorFee = ""
    }
}

// MARK: - Mail View Wrapper
struct MailView: UIViewControllerRepresentable {
    let subject: String
    let recipients: [String]
    let body: String
    let onDismiss: (Result<MFMailComposeResult, Error>) -> Void
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = context.coordinator
        mailComposer.setSubject(subject)
        mailComposer.setToRecipients(recipients)
        mailComposer.setMessageBody(body, isHTML: false)
        return mailComposer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onDismiss: (Result<MFMailComposeResult, Error>) -> Void
        
        init(onDismiss: @escaping (Result<MFMailComposeResult, Error>) -> Void) {
            self.onDismiss = onDismiss
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
            
            if let error = error {
                onDismiss(.failure(error))
            } else {
                onDismiss(.success(result))
            }
        }
    }
}

#Preview {
    SubmitShowView()
}
