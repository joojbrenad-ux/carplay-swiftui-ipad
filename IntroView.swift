import SwiftUI
import WebKit

// MARK: - ENUM
enum AppScreen {
    case maps, music, youtube, chrome, phone
}

// MARK: - VIEW MODEL
class AppViewModel: ObservableObject {
    @Published var selectedScreen: AppScreen = .maps
}

// MARK: - MAIN VIEW
struct IntroView: View {
    @StateObject private var vm = AppViewModel()
    @State private var isDriving = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            TopBar()
            
            HStack(spacing: 0) {
                
                // MENU LATERAL
                VStack(spacing: 22) {
                    
                    MenuButton(icon: "map.fill", active: vm.selectedScreen == .maps) {
                        switchScreen(.maps)
                    }
                    
                    MenuButton(icon: "music.note", active: vm.selectedScreen == .music) {
                        switchScreen(.music)
                    }
                    
                    MenuButton(icon: "play.rectangle.fill", active: vm.selectedScreen == .youtube) {
                        switchScreen(.youtube)
                    }
                    
                    MenuButton(icon: "globe", active: vm.selectedScreen == .chrome) {
                        switchScreen(.chrome)
                    }
                    
                    MenuButton(icon: "phone.fill", active: vm.selectedScreen == .phone) {
                        switchScreen(.phone)
                    }
                    
                    Spacer()
                }
                .frame(width: 115)
                .background(.ultraThinMaterial)
                
                // CONTEÚDO
                ZStack {
                    
                    if vm.selectedScreen == .maps {
                        MapsContainer(isDriving: $isDriving)
                    }
                    
                    if vm.selectedScreen == .music {
                        MusicView()
                    }
                    
                    if vm.selectedScreen == .youtube {
                        YouTubeView()
                    }
                    
                    if vm.selectedScreen == .chrome {
                        ChromeView()
                    }
                    
                    if vm.selectedScreen == .phone {
                        PhoneView()
                    }
                }
                .animation(.easeInOut(duration: 0.35), value: vm.selectedScreen)
            }
        }
        .background(Color.black)
        .ignoresSafeArea()
    }
    
    func switchScreen(_ screen: AppScreen) {
        withAnimation {
            vm.selectedScreen = screen
        }
    }
}

// MARK: - TOP BAR
struct TopBar: View {
    @State private var now = Date()
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            Text(formatted())
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .medium))
            
            Spacer()
            
            Image(systemName: "battery.100")
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .frame(height: 50)
        .background(.ultraThinMaterial)
        .onReceive(timer) { _ in now = Date() }
    }
    
    func formatted() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "HH:mm  •  EEEE"
        return f.string(from: now)
    }
}

// MARK: - MENU BUTTON
struct MenuButton: View {
    let icon: String
    let active: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundColor(active ? .black : .white)
                .frame(width: 70, height: 70)
                .background(active ? Color.white : Color.white.opacity(0.15))
                .cornerRadius(20)
                .shadow(color: active ? .white.opacity(0.6) : .clear, radius: 15)
        }
    }
}

// MARK: - MAPS CONTAINER
struct MapsContainer: View {
    @Binding var isDriving: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            GoogleMapsView()
            
            VStack(spacing: 12) {
                
                if !isDriving {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Destino")
                            .font(.headline)
                        Text("Av. Paulista")
                            .font(.title2).bold()
                        Text("8 min • 2,3 km")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                }
                
                Button {
                    withAnimation {
                        isDriving.toggle()
                    }
                } label: {
                    Text(isDriving ? "Encerrar navegação" : "Navegar")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isDriving ? Color.red : Color.blue)
                        .cornerRadius(25)
                }
            }
            .padding()
        }
    }
}

// MARK: - GOOGLE MAPS REAL
struct GoogleMapsView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        
        let url = URL(string:
                        "https://www.google.com/maps/dir/?api=1&destination=-23.5505,-46.6333&travelmode=driving"
        )!
        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - MUSIC
struct MusicView: View {
    @State private var bars = Array(repeating: CGFloat.random(in: 0.2...1), count: 20)
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.purple, .black], startPoint: .top, endPoint: .bottom)
            
            VStack(spacing: 25) {
                Text("Midnight Drive")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Text("Synthwave FM")
                    .foregroundColor(.white.opacity(0.6))
                
                HStack(spacing: 4) {
                    ForEach(bars.indices, id: \.self) { i in
                        Capsule()
                            .fill(Color.white)
                            .frame(width: 6, height: bars[i] * 80)
                    }
                }
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
                        withAnimation {
                            bars = bars.map { _ in CGFloat.random(in: 0.2...1) }
                        }
                    }
                }
                
                HStack(spacing: 40) {
                    Image(systemName: "backward.fill")
                    Image(systemName: "play.fill").font(.system(size: 30))
                    Image(systemName: "forward.fill")
                }
                .foregroundColor(.white)
            }
        }
    }
}

// MARK: - YOUTUBE REAL
struct YouTubeView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        
        let url = URL(string: "https://www.youtube.com")!
        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - GOOGLE CHROME (BROWSER REAL)
struct ChromeView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        
        // Chrome fake = browser Google real
        let url = URL(string: "https://www.google.com")!
        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - PHONE
struct PhoneView: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.green, .black], startPoint: .top, endPoint: .bottom)
            
            VStack(spacing: 25) {
                Text("Chamada ativa")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Text("Jooj Brenad")
                    .foregroundColor(.white.opacity(0.7))
                
                Button("Encerrar") {}
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(Color.red)
                    .cornerRadius(25)
            }
        }
    }
}

