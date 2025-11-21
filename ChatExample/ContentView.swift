import SwiftUI
import AssembledChat

struct ContentView: View {
    @StateObject private var viewModel = ChatDemoViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    Text("Assembled Chat Demo")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Company ID Input
                    if !viewModel.isInitialized {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Enter Company ID")
                                .font(.headline)
                            
                            HStack {
                                TextField("Company ID", text: $viewModel.companyId)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                
                                Button(action: {
                                    if let clipboardString = UIPasteboard.general.string {
                                        viewModel.companyId = clipboardString
                                        viewModel.addLog("📋 Pasted from clipboard: \(clipboardString)")
                                    }
                                }) {
                                    Image(systemName: "doc.on.clipboard")
                                        .padding(8)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(6)
                                }
                            }
                            
                            HStack {
                                TextField("Profile ID (optional)", text: $viewModel.profileId)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                
                                Button(action: {
                                    if let clipboardString = UIPasteboard.general.string {
                                        viewModel.profileId = clipboardString
                                        viewModel.addLog("📋 Pasted profile ID from clipboard")
                                    }
                                }) {
                                    Image(systemName: "doc.on.clipboard")
                                        .padding(8)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(6)
                                }
                            }
                            
                            Toggle("Debug Mode", isOn: $viewModel.debugMode)
                                .tint(.blue)
                            
                            // Quick Test Button (for development)
                            Button(action: {
                                viewModel.companyId = "test-demo-id"
                                viewModel.addLog("🧪 Using test company ID")
                            }) {
                                HStack {
                                    Image(systemName: "flask")
                                    Text("Use Test ID (for demo)")
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Status
                    HStack {
                        Circle()
                            .fill(viewModel.statusColor)
                            .frame(width: 12, height: 12)
                        Text(viewModel.statusText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        if !viewModel.isInitialized {
                            Button(action: {
                                viewModel.initializeChat()
                            }) {
                                HStack {
                                    if viewModel.isInitializing {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "power")
                                    }
                                    Text(viewModel.isInitializing ? "Initializing..." : "Initialize Chat")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(viewModel.companyId.isEmpty || viewModel.isInitializing)
                        } else {
                            // Chat Controls
                            HStack(spacing: 12) {
                                Button(action: {
                                    viewModel.openChat()
                                }) {
                                    VStack {
                                        Image(systemName: "bubble.left.fill")
                                            .font(.title2)
                                        Text("Open Chat")
                                            .font(.caption)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                
                                Button(action: {
                                    viewModel.closeChat()
                                }) {
                                    VStack {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title2)
                                        Text("Close Chat")
                                            .font(.caption)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                Button(action: {
                                    viewModel.showLauncher()
                                }) {
                                    VStack {
                                        Image(systemName: "eye.fill")
                                            .font(.title2)
                                        Text("Show Launcher")
                                            .font(.caption)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.purple)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                
                                Button(action: {
                                    viewModel.hideLauncher()
                                }) {
                                    VStack {
                                        Image(systemName: "eye.slash.fill")
                                            .font(.title2)
                                        Text("Hide Launcher")
                                            .font(.caption)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                            }
                            
                            Button(action: {
                                viewModel.reset()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Reset")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                    }
                    
                    // Event Log
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Event Log")
                                .font(.headline)
                            Spacer()
                            Button("Clear") {
                                viewModel.clearLog()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(Array(viewModel.eventLog.enumerated()), id: \.offset) { _, event in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text(event.icon)
                                            .font(.caption)
                                        Text(event.message)
                                            .font(.system(.caption, design: .monospaced))
                                            .foregroundColor(event.color)
                                        Spacer()
                                        Text(event.timestamp)
                                            .font(.system(.caption2, design: .monospaced))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                        }
                        .frame(maxHeight: 200)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

// MARK: - View Model

class ChatDemoViewModel: ObservableObject, AssembledChatDelegate {
    @Published var companyId: String = ""
    @Published var profileId: String = ""
    @Published var debugMode: Bool = true
    
    @Published var isInitialized: Bool = false
    @Published var isInitializing: Bool = false
    @Published var statusText: String = "Not initialized"
    @Published var eventLog: [EventLogEntry] = []
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    private var chat: AssembledChat?
    
    var statusColor: Color {
        if isInitialized {
            return .green
        } else if isInitializing {
            return .orange
        } else {
            return .red
        }
    }
    
    func initializeChat() {
        guard !companyId.isEmpty else { return }
        
        isInitializing = true
        statusText = "Initializing..."
        addLog("🚀 Starting initialization...", color: .blue)
        addLog("   Company ID: \(companyId)")
        if !profileId.isEmpty {
            addLog("   Profile ID: \(profileId)")
        }
        addLog("   Debug Mode: \(debugMode)")
        
        // Create configuration
        var config = AssembledChatConfiguration(
            companyId: companyId,
            profileId: profileId.isEmpty ? nil : profileId,
            debug: debugMode
        )
        
        // Create chat instance
        chat = AssembledChat(configuration: config)
        chat?.delegate = self
        
        addLog("✅ Chat instance created")
        
        // Initialize
        Task {
            do {
                try await chat?.initialize()
                await MainActor.run {
                    isInitialized = true
                    isInitializing = false
                    statusText = "Ready"
                    addLog("✅ Chat initialized successfully!", color: .green)
                    addLog("💡 You can now open the chat")
                }
            } catch {
                await MainActor.run {
                    isInitializing = false
                    statusText = "Initialization failed"
                    addLog("❌ Initialization failed: \(error.localizedDescription)", color: .red)
                    showErrorAlert(error.localizedDescription)
                }
            }
        }
    }
    
    func openChat() {
        addLog("📱 Opening chat...")
        chat?.open()
    }
    
    func closeChat() {
        addLog("🔒 Closing chat...")
        chat?.close()
    }
    
    func showLauncher() {
        addLog("👁️ Showing launcher...")
        chat?.showLauncher()
    }
    
    func hideLauncher() {
        addLog("🙈 Hiding launcher...")
        chat?.hideLauncher()
    }
    
    func reset() {
        addLog("🔄 Resetting demo...", color: .orange)
        chat?.teardown()
        chat = nil
        isInitialized = false
        isInitializing = false
        statusText = "Not initialized"
        eventLog.removeAll()
    }
    
    func clearLog() {
        eventLog.removeAll()
    }
    
    func addLog(_ message: String, color: Color = .primary, icon: String = "•") {
        let entry = EventLogEntry(
            message: message,
            color: color,
            icon: icon,
            timestamp: timeString()
        )
        eventLog.insert(entry, at: 0)
        
        // Keep only last 50 entries
        if eventLog.count > 50 {
            eventLog = Array(eventLog.prefix(50))
        }
    }
    
    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    private func timeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    // MARK: - AssembledChatDelegate
    
    func assembledChatDidLoad() {
        addLog("✅ Delegate: Chat loaded", color: .green, icon: "📥")
    }
    
    func assembledChatDidOpen() {
        addLog("✅ Delegate: Chat opened", color: .green, icon: "📱")
    }
    
    func assembledChatDidClose() {
        addLog("✅ Delegate: Chat closed", color: .orange, icon: "🔒")
    }
    
    func assembledChat(didReceiveError error: Error) {
        addLog("❌ Delegate: Error - \(error.localizedDescription)", color: .red, icon: "⚠️")
    }
    
    func assembledChat(didReceiveNotification notification: ChatNotification) {
        addLog("🔔 Delegate: Notification received - \(notification.id)", color: .purple, icon: "🔔")
    }
}

// MARK: - Event Log Entry

struct EventLogEntry: Identifiable {
    let id = UUID()
    let message: String
    let color: Color
    let icon: String
    let timestamp: String
}

// MARK: - Preview

#Preview {
    ContentView()
}
