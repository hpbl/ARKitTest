//
//  ViewController.swift
//  shopARKitDemo
//
//  Created by Hilton Pintor Bezerra Leite on 06/04/2018.
//  Copyright © 2018 Voxar Labs. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get reference for Target images
        guard let referenceImages = ARReferenceImage.referenceImages(
            inGroupNamed: "AR Resources",
            bundle: nil
        ) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Add Targets to configuration
        configuration.detectionImages = referenceImages
        
        // Run the view's session
        self.sceneView.session.run(
            configuration,
            options: [.resetTracking, .removeExistingAnchors]
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Getting reference to recognized Image
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        
        // Creating a Video Node
        let videoNode = SKVideoNode(fileNamed: "dress.mp4")
        videoNode.yScale = -1
        videoNode.play()
        
        // Creating a 2D Scene
        let skScene = SKScene(size: CGSize(width: 640, height: 480))
        skScene.addChild(videoNode)
        
        // Positioning video node in scene
        videoNode.position = CGPoint(x: skScene.size.width/2, y: skScene.size.height/2)
        videoNode.size = skScene.size
        
        // Creating Plane on top of recognized image
        let plane = SCNPlane(width: referenceImage.physicalSize.width,
                             height: referenceImage.physicalSize.height)
        plane.firstMaterial?.diffuse.contents = skScene // placing video 2d scene
        plane.firstMaterial?.isDoubleSided = true
        
        // Creating node for Plane
        let planeNode = SCNNode(geometry: plane)
        planeNode.opacity = 1
        
        /*
         `SCNPlane` is vertically oriented in its local coordinate space, but
         `ARImageAnchor` assumes the image is horizontal in its local space, so
         rotate the plane to match.
         */
        planeNode.eulerAngles.x = -.pi / 2
        
        // Add the plane visualization to the scene.
        node.addChildNode(planeNode)
    }
}
