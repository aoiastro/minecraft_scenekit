import SwiftUI
import SceneKit

struct ContentView: View {
    @State private var direction: CGPoint = .zero
    @State private var scene = SCNScene()
    private var playerNode = SCNNode()

    init() {
        setupScene()
    }
    
    var body: some View {
        ZStack {
            // 3Dシーン
            SceneView(
                scene: scene,
                pointOfView: nil,
                options: [.autoenablesDefaultLighting]
            )
            .edgesIgnoringSafeArea(.all)
            
            // 左下ジョイスティック
            VStack {
                Spacer()
                HStack {
                    JoystickView(direction: $direction)
                        .frame(width: 120, height: 120)
                        .padding()
                    Spacer()
                }
            }
            
            // 右下ジャンプボタン
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        playerNode.physicsBody?.applyForce(SCNVector3(0, 6, 0), asImpulse: true)
                    }) {
                        Text("Jump")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 70, height: 70)
                            .background(Color.orange)
                            .clipShape(Circle())
                    }
                    .padding()
                }
            }
        }
        .onChange(of: direction) { newValue in
            movePlayer(direction: newValue)
        }
    }
    
    // MARK: - Scene Setup
    private func setupScene() {
        // カメラ
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 10, 20)
        scene.rootNode.addChildNode(cameraNode)
        
        // ライト
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(0, 20, 20)
        scene.rootNode.addChildNode(lightNode)
        
        // 地形生成
        generateTerrain(width: 15, depth: 15, maxHeight: 3, scene: scene)
        
        // プレイヤー
        let box = SCNBox(width: 1, height: 2, length: 1, chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = UIColor.blue
        playerNode.geometry = box
        playerNode.position = SCNVector3(5, 10, 5)
        playerNode.physicsBody = SCNPhysicsBody.dynamic()
        playerNode.physicsBody?.mass = 1.0
        scene.rootNode.addChildNode(playerNode)
    }
    
    // MARK: - 地形生成
    private func generateTerrain(width: Int, depth: Int, maxHeight: Int, scene: SCNScene) {
        for x in 0..<width {
            for z in 0..<depth {
                let height = Int.random(in: 1...maxHeight)
                for y in 0..<height {
                    let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
                    box.firstMaterial?.diffuse.contents = UIColor.brown
                    let node = SCNNode(geometry: box)
                    node.position = SCNVector3(Float(x), Float(y), Float(z))
                    node.physicsBody = SCNPhysicsBody.static()
                    scene.rootNode.addChildNode(node)
                }
            }
        }
    }
    
    // MARK: - プレイヤー移動
    private func movePlayer(direction: CGPoint) {
        let speed: Float = 0.05
        let dx = Float(direction.x) * speed
        let dz = Float(direction.y) * speed
        playerNode.position.x += dx
        playerNode.position.z += dz
    }
}

// MARK: - ジョイスティック
struct JoystickView: View {
    @Binding var direction: CGPoint
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                Circle()
                    .fill(Color.blue)
                    .frame(width: 50, height: 50)
                    .offset(x: direction.x, y: direction.y)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let radius = geo.size.width / 2
                                let dx = value.translation.width
                                let dy = value.translation.height
                                let dist = sqrt(dx*dx + dy*dy)
                                if dist < radius {
                                    direction = CGPoint(x: dx, y: dy)
                                }
                            }
                            .onEnded { _ in
                                direction = .zero
                            }
                    )
            }
        }
    }
}
