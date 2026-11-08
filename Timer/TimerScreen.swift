import SwiftUI

private struct TimerPalette {
    let dark: Bool
    var primary: Color { Color(hex: dark ? 0xB0C6FF : 0x475D92) }
    var onPrimary: Color { Color(hex: dark ? 0x142F60 : 0xFFFFFF) }
    var background: Color { Color(hex: dark ? 0x111318 : 0xFAF8FF) }
    var text: Color { Color(hex: dark ? 0xE2E2E9 : 0x1A1B20) }
    var track: Color { Color(hex: dark ? 0x44464F : 0xE1E2EC) }
    var secondary: Color { Color(hex: dark ? 0x414659 : 0xDCE2F9) }
    var onSecondary: Color { Color(hex: dark ? 0xDCE2F9 : 0x414659) }
    var outline: Color { Color(hex: dark ? 0x8F9099 : 0x757780) }
}

struct TimerScreen: View {
    @ObservedObject var model: TimerModel
    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric(relativeTo: .largeTitle) private var timerFontSize = 80
    private var palette: TimerPalette { TimerPalette(dark: colorScheme == .dark) }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 48) {
                    modeSelector
                    timerFace
                    controls
                }
                .padding(24)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(palette.background.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            if model.showsCompletion {
                HStack {
                    Text("Time's up!")
                    Spacer()
                    Button("Dismiss") { model.showsCompletion = false }
                        .fontWeight(.semibold)
                }
                .padding(20)
                .foregroundStyle(palette.background)
                .background(palette.text, in: RoundedRectangle(cornerRadius: 12))
                .padding(16)
                .accessibilityIdentifier("CompletionBanner")
            }
        }
    }

    private var modeSelector: some View {
        HStack(spacing: 0) {
            ForEach(TimerMode.allCases) { mode in
                let selected = model.engine.mode == mode
                Button { model.select(mode) } label: {
                    HStack(spacing: 4) {
                        if selected { Image(systemName: "checkmark").font(.caption.weight(.semibold)) }
                        Text(mode.title).font(.system(size: 14, weight: .medium))
                            .minimumScaleFactor(0.75).lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .foregroundStyle(selected ? palette.onSecondary : palette.text)
                    .background(selected ? palette.secondary : Color.clear)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("ModeButton_\(mode.rawValue)")
                .accessibilityAddTraits(selected ? [.isSelected] : [])
                if mode != .longBreak {
                    Rectangle().fill(palette.outline).frame(width: 1)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(palette.outline, lineWidth: 1))
    }

    private var timerFace: some View {
        ZStack {
            Circle().stroke(palette.track, lineWidth: 12)
            Circle()
                .trim(from: 0, to: CGFloat(model.engine.remaining(at: model.now)) / CGFloat(model.engine.mode.duration))
                .stroke(palette.primary, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(model.engine.formatted(at: model.now))
                .font(.system(size: timerFontSize, weight: .bold, design: .default))
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(20)
                .foregroundStyle(palette.text)
                .accessibilityIdentifier("TimerText")
                .accessibilityLabel("Time remaining")
                .accessibilityValue("\(model.engine.remaining(at: model.now) / 60) minutes, \(model.engine.remaining(at: model.now) % 60) seconds")
        }
        .padding(6)
        .frame(maxWidth: 312)
        .aspectRatio(1, contentMode: .fit)
    }

    private var controls: some View {
        HStack(spacing: 24) {
            Button { model.reset() } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 28, weight: .medium))
                    .frame(width: 64, height: 64)
                    .foregroundStyle(palette.onSecondary)
                    .background(palette.secondary, in: RoundedRectangle(cornerRadius: 12))
            }
            .accessibilityLabel("Reset")
            .accessibilityIdentifier("ResetButton")
            Button { model.toggle() } label: {
                Image(systemName: model.engine.isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 40))
                    .frame(width: 100, height: 100)
                    .foregroundStyle(palette.onPrimary)
                    .background(palette.primary, in: RoundedRectangle(cornerRadius: 28))
            }
            .accessibilityLabel(model.engine.isRunning ? "Pause" : "Start")
            .accessibilityIdentifier("StartPauseButton")
            .disabled(!model.engine.isRunning && model.engine.remaining(at: model.now) == 0)
        }
        .buttonStyle(.plain)
    }
}

private extension Color {
    init(hex: UInt32) {
        self.init(.sRGB, red: Double((hex >> 16) & 255) / 255,
                  green: Double((hex >> 8) & 255) / 255,
                  blue: Double(hex & 255) / 255, opacity: 1)
    }
}

#Preview { TimerScreen(model: TimerModel()) }
