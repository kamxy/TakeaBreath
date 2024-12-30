import SwiftUI

struct MeditationView: View {
    @StateObject private var viewModel = MeditationViewModel()
    @State private var selectedCategory: MeditationCategory?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(MeditationCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding()
                }
                
                // Meditation List
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(filteredMeditations) { meditation in
                            NavigationLink(destination: MeditationDetailView(meditation: meditation)) {
                                MeditationGridItem(meditation: meditation)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Meditate")
        }
    }
    
    private var filteredMeditations: [Meditation] {
        guard let category = selectedCategory else {
            return viewModel.meditations
        }
        return viewModel.meditations.filter { $0.category == category }
    }
}

struct CategoryButton: View {
    let category: MeditationCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.systemImage)
                Text(category.rawValue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.purple : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct MeditationGridItem: View {
    let meditation: Meditation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(meditation.imageURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 140)
                .clipped()
                .cornerRadius(12)
            
            Text(meditation.title)
                .font(.headline)
                .lineLimit(1)
            
            HStack {
                Image(systemName: "clock")
                Text("\(Int(meditation.duration/60)) min")
                Spacer()
                if meditation.isPremium {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct MeditationDetailView: View {
    let meditation: Meditation
    @StateObject private var viewModel = MeditationViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Image
                Image(meditation.imageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                
                VStack(alignment: .leading, spacing: 16) {
                    // Title and Duration
                    VStack(alignment: .leading, spacing: 8) {
                        Text(meditation.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            Image(systemName: "clock")
                            Text("\(Int(meditation.duration/60)) minutes")
                            Spacer()
                            if meditation.isPremium {
                                Label("Premium", systemImage: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    // Description
                    Text(meditation.description)
                        .foregroundColor(.secondary)
                    
                    // Player Controls
                    VStack(spacing: 20) {
                        // Progress Bar
                        ProgressView(value: viewModel.progress)
                            .tint(.purple)
                        
                        // Time
                        HStack {
                            Text(formatTime(viewModel.currentTime))
                            Spacer()
                            Text(formatTime(meditation.duration))
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        // Controls
                        HStack(spacing: 40) {
                            Button(action: {
                                viewModel.stop()
                            }) {
                                Image(systemName: "backward.fill")
                                    .font(.title)
                            }
                            
                            Button(action: {
                                if viewModel.isPlaying {
                                    viewModel.pause()
                                } else {
                                    viewModel.play(meditation)
                                }
                            }) {
                                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 64))
                            }
                            
                            Button(action: {
                                // Forward 30 seconds
                            }) {
                                Image(systemName: "forward.fill")
                                    .font(.title)
                            }
                        }
                        .foregroundColor(.purple)
                    }
                    .padding(.vertical)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    MeditationView()
} 