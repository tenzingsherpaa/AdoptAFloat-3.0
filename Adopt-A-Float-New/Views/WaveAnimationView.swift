//
//  WaveAnimationView.swift
//  Adopt-A-Float-New
//
//  Created by Tenzing Sherpa on 10/14/24.
//

import SwiftUI

// MARK: - WaveAnimationView
/// A SwiftUI view that displays multiple animated sine waves to create a wave animation effect.
struct WaveAnimationView: View {
    // MARK: - State Variables
    /// Offset for the first wave's phase, controlling its animation.
    @State private var waveOffset1: CGFloat = 0
    /// Offset for the second wave's phase.
    @State private var waveOffset2: CGFloat = 0
    /// Offset for the third wave's phase.
    @State private var waveOffset3: CGFloat = 0
    /// Offset for the fourth wave's phase.
    @State private var waveOffset4: CGFloat = 0
    /// Offset for the fifth wave's phase.
    @State private var waveOffset5: CGFloat = 0
    /// Offset for the sixth wave's phase.
    @State private var waveOffset6: CGFloat = 0

    // MARK: - Body
    var body: some View {
        ZStack {
            // MARK: - First Wave
            // Creates the first wave with specific amplitude, frequency, and phase offset.
            WaveView(amplitude: 30, frequency: 2, phase: waveOffset1)
                .stroke(
                    // Applies a linear gradient stroke to the wave.
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 3 // Sets the stroke width.
                )
                .offset(y: -50) // Vertically offsets the wave.
                .animation(
                    // Animates the wave's phase offset continuously.
                    Animation.linear(duration: 4).repeatForever(autoreverses: false),
                    value: waveOffset1
                )

            // MARK: - Second Wave
            WaveView(amplitude: 25, frequency: 1.8, phase: waveOffset2)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.2)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 3
                )
                .offset(y: -30)
                .animation(
                    Animation.linear(duration: 4.5).repeatForever(autoreverses: false),
                    value: waveOffset2
                )

            // MARK: - Third Wave
            WaveView(amplitude: 20, frequency: 2.5, phase: waveOffset3)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue.opacity(0.3)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 3
                )
                .offset(y: -10)
                .animation(
                    Animation.linear(duration: 5).repeatForever(autoreverses: false),
                    value: waveOffset3
                )

            // MARK: - Fourth Wave
            WaveView(amplitude: 35, frequency: 1.5, phase: waveOffset4)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.4)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 4
                )
                .offset(y: 10)
                .animation(
                    Animation.linear(duration: 5.5).repeatForever(autoreverses: false),
                    value: waveOffset4
                )

            // MARK: - Fifth Wave
            WaveView(amplitude: 40, frequency: 1.6, phase: waveOffset5)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(1.0), Color.blue.opacity(0.5)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 4
                )
                .offset(y: 30)
                .animation(
                    Animation.linear(duration: 6).repeatForever(autoreverses: false),
                    value: waveOffset5
                )

            // MARK: - Sixth Wave
            WaveView(amplitude: 45, frequency: 1.4, phase: waveOffset6)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.cyan.opacity(1.0), Color.blue.opacity(0.6)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 5
                )
                .offset(y: 50)
                .animation(
                    Animation.linear(duration: 6.5).repeatForever(autoreverses: false),
                    value: waveOffset6
                )
        }
        .frame(height: 300) // Sets the height of the ZStack containing all waves.
        .onAppear {
            // Initiates the wave animations by setting phase offsets to complete a full cycle.
            waveOffset1 = .pi * 2
            waveOffset2 = .pi * 2
            waveOffset3 = .pi * 2
            waveOffset4 = .pi * 2
            waveOffset5 = .pi * 2
            waveOffset6 = .pi * 2
        }
    }
}

// MARK: - WaveView
/// A shape that represents a sine wave, customizable with amplitude, frequency, and phase.
struct WaveView: Shape {
    // MARK: - Properties
    /// The height of the wave's peaks and troughs.
    var amplitude: CGFloat = 20
    /// The number of complete wave cycles that fit within the view's width.
    var frequency: CGFloat = 2
    /// The phase shift of the wave, used to animate its movement.
    var phase: CGFloat

    // MARK: - Animatable Data
    /// Allows the phase property to be animated.
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    // MARK: - Path Definition
    /// Defines the path of the sine wave within the given rectangle.
    /// - Parameter rect: The frame in which to draw the wave.
    /// - Returns: A Path representing the sine wave.
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let waveHeight = amplitude
        let waveLength = rect.width / frequency // Calculates the wavelength based on frequency.

        // Start the path at the center left of the rect.
        path.move(to: CGPoint(x: 0, y: rect.height / 2))

        // Iterate over each x-coordinate to plot the sine wave.
        for x in stride(from: 0, to: rect.width, by: 1) {
            let relativeX = x / waveLength // Normalizes x based on wavelength.
            let y = waveHeight * sin(relativeX + phase) + rect.height / 2 // Calculates y using sine function.
            path.addLine(to: CGPoint(x: x, y: y)) // Adds a line to the calculated point.
        }

        return path
    }
}
