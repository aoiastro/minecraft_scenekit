
import SwiftUI
import SceneKit

struct ContentView: View {
    @EnvironmentObject var playerInput: PlayerInput
    @StateObject private var gameScene = GameScene()

    @State private var joystickPosition: CGPoint = .zero
    @State private var joystickHandlePosition: CGPoint = .zero

    var body: some View {
        ZStack {
            SceneView(
                scene: gameScene,
                options: [.allowsCameraControl]
            )
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                gameScene.playerInput = playerInput
            }

            // Joystick
            VStack {
                Spacer()
                HStack {
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Circle()
                                .fill(Color.white.opacity(0.7))
                                .frame(width: 60, height: 60)
                                .offset(x: joystickHandlePosition.x, y: joystickHandlePosition.y)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let vector = CGVector(dx: value.translation.width, dy: value.translation.height)
                                            let distance = sqrt(vector.dx * vector.dx + vector.dy * vector.dy)

                                            let maxDistance: CGFloat = 20
                                            if distance > maxDistance {
                                                joystickHandlePosition = CGPoint(x: vector.dx / distance * maxDistance, y: vector.dy / distance * maxDistance)
                                            } else {
                                                joystickHandlePosition = value.translation
                                            }
                                            playerInput.moveDirection = joystickHandlePosition
                                        }
                                        .onEnded { _ in
                                            joystickHandlePosition = .zero
                                            playerInput.moveDirection = .zero
                                        }
                                )
                        )
                        .padding(.leading, 20)

                    Spacer()

                    // Jump Button
                    Button(action: {
                        playerInput.jumpPressed.toggle()
                        // Reset after a short delay to simulate a press
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            playerInput.jumpPressed = false
                        }
                    }) {
                        Circle()
                            .fill(Color.blue.opacity(0.7))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text("Jump")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            )
                    }
                    .padding(.trailing, 20)
                }
                .padding(.bottom, 20)
            }
        }
    }
}
