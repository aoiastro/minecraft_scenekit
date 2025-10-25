
import Foundation
import Combine
import CoreGraphics // For CGPoint

class PlayerInput: ObservableObject {
    @Published var moveDirection: CGPoint = .zero // x, y for joystick
    @Published var jumpPressed: Bool = false
}
