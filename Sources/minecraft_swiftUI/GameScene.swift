
import SceneKit
import UIKit
import Combine

class GameScene: SCNScene, SCNSceneDelegate {
    var playerNode: SCNNode!
    var playerInput: PlayerInput? // Will be set from ContentView
    private var cancellables = Set<AnyCancellable>()

    let playerSpeed: Float = 0.1
    let jumpForce: Float = 5.0

    override init() {
        super.init()
        self.delegate = self
        
        // Player Node
        let playerGeometry = SCNCapsule(capRadius: 0.4, height: 1.8)
        let playerMaterial = SCNMaterial()
        playerMaterial.diffuse.contents = UIColor.blue
        playerGeometry.materials = [playerMaterial]
        playerNode = SCNNode(geometry: playerGeometry)
        playerNode.position = SCNVector3(0, 2, 0) // Start above the ground

        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: playerGeometry, options: nil))
        physicsBody.mass = 50
        physicsBody.isAffectedByGravity = true
        physicsBody.allowsResting = true
        playerNode.physicsBody = physicsBody
        rootNode.addChildNode(playerNode)

        // Camera Node
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 1.5, 5)
        playerNode.addChildNode(cameraNode) // Make camera a child of playerNode

        // Cube Grid
        let cubeGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let sideMaterial = SCNMaterial()
        sideMaterial.diffuse.contents = UIColor.brown
        let topMaterial = SCNMaterial()
        topMaterial.diffuse.contents = UIColor.green
        let bottomMaterial = SCNMaterial()
        bottomMaterial.diffuse.contents = UIColor.darkGray
        cubeGeometry.materials = [sideMaterial, sideMaterial, sideMaterial, sideMaterial, topMaterial, bottomMaterial]

        for i in 0..<20 {
            for j in 0..<20 {
                let height = Float.random(in: 0..<3)
                for k in 0..<Int(height) {
                    let cubeNode = SCNNode(geometry: cubeGeometry)
                    cubeNode.position = SCNVector3(Float(i) - 10, Float(k) + 0.5, Float(j) - 10)
                    rootNode.addChildNode(cubeNode)
                }
            }
        }

        // Floor
        let floor = SCNFloor()
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(0, -0.5, 0)
        rootNode.addChildNode(floorNode)

        // Ambient Light
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor.white
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        rootNode.addChildNode(ambientLightNode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let playerInput = playerInput else { return }

        // Player Movement
        let xMovement = Float(playerInput.moveDirection.x) * playerSpeed
        let zMovement = Float(playerInput.moveDirection.y) * playerSpeed

        let cameraDirection = playerNode.presentation.worldTransform.columns.2
        let forwardDirection = SCNVector3(-cameraDirection.x, 0, -cameraDirection.z).normalized()
        let rightDirection = SCNVector3(cameraDirection.z, 0, -cameraDirection.x).normalized()

        let movementVector = (forwardDirection * zMovement) + (rightDirection * xMovement)
        playerNode.position = SCNVector3(playerNode.position.x + movementVector.x, playerNode.position.y, playerNode.position.z + movementVector.z)

        // Player Jump
        if playerInput.jumpPressed {
            // Check if player is on the ground before jumping
            // This is a simplified check, a more robust solution would involve raycasting or collision detection
            if playerNode.physicsBody?.velocity.y ?? 0 < 0.1 && playerNode.position.y <= 0.55 {
                playerNode.physicsBody?.applyForce(SCNVector3(0, jumpForce, 0), asImpulse: true)
            }
        }
    }
}

extension SCNVector3 {
    func normalized() -> SCNVector3 {
        let length = sqrt(x*x + y*y + z*z)
        return SCNVector3(x / length, y / length, z / length)
    }

    static func * (left: SCNVector3, right: Float) -> SCNVector3 {
        return SCNVector3(left.x * right, left.y * right, left.z * right)
    }

    static func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
    }
}
