//
//  ViewController.swift
//  FiveYears
//
//  Created by Jan B on 21.04.17.
//  Copyright © 2017 Jan Busse. All rights reserved.
//

import UIKit
import ImageSlideshow
import FirebaseAuth
import FirebaseDatabase


class MemoryViewController: UIViewController {
    
    /// The images that will be loaded into the imageSlideShow as an ImageSource.
    var images: [ImageSource]? {
        didSet {
            if let imgs = images {
                imageSlideShow.setImageInputs(imgs)
                
                // loveRain(pieces: 20)
            }
        }
    }
    
    
    /// The text that is displayed in the textView.
    var text: String? {
        didSet {
            if let memoryText = text {
                textView.text = memoryText
            }
        }
    }
    
    /// Key to the database (as time stamp from 1970 on).
    /// In case it is nil the latest memory is loaded by default.
    var currentMemory: String? = nil {
        didSet {
            reloadContent(forTimestamp: currentMemory)
        }
    }
    
    /// Will cause to reload the content. See reloadContent(forTimestamp: ...) for more info.
    ///
    /// - Parameter sender: Button calling the function.
    @IBAction func reloadContent(_ sender: UIButton) {
        reloadContent(forTimestamp: currentMemory)
    }
    
    /// imageSlideShow shows the images assigned in the images variable.
    var imageSlideShow = ImageSlideshow()
    
    /// textView shows the text assigned in the text variable.
    var textView: UITextView = {
        let txtvw = UITextView()
        txtvw.backgroundColor = BACKGROUND_COLOR
        txtvw.textColor = TEXT_COLOR
        txtvw.font = TEXT_FONT
        txtvw.textAlignment = .justified
        txtvw.textContainerInset = TEXTVIEW_CONTAINER_INSETS
        return txtvw
    }()
    
    
    /// The parent view of the textView and the imageSlideShow.
    @IBOutlet weak var contentView: UIView!
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        // Show Images selected
        case 0:
            // Remove all subviews first
            contentView.subviews.forEach({ $0.removeFromSuperview() })
            // Set frame for imageSlideShow to size of contentView
            imageSlideShow.frame = contentView.bounds
            // Add a GestureRecognizer to support tapping on the image and showing it fullscreen
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MemoryViewController.imgFullscreen))
            imageSlideShow.addGestureRecognizer(gestureRecognizer)
            // Add the slideshow to the contentView
            contentView.addSubview(imageSlideShow)
            
        // Show Text selected
        case 1:
            // Remove all subviews first then add textView to contentView with right size
            contentView.subviews.forEach({ $0.removeFromSuperview() })
            textView.frame = contentView.bounds
            contentView.addSubview(textView)
        default:
            break
        }
    }
    
    @IBAction func goBack(segue: UIStoryboardSegue) {
        // Nothing happening here. See MemoryTableViewController's prepareforsegue.
    }
    
    /// The segment control enables to switch between Images and Text indexes: images - 0; text - 1
    @IBOutlet weak var segmentCtrl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = BACKGROUND_COLOR
        contentView.backgroundColor = BACKGROUND_COLOR
        
        
        // TODO: REMOVE LATER
        insertTestContent()
        
        authenticateFirebase()
        
        segmentChanged(segmentCtrl)
    }
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardIdentifier.allmemoriessegue {
            
        }
    }
 */
    
    /// Causes the imageSlideShow take over the entire screen.
    func imgFullscreen() {
        imageSlideShow.presentFullScreenController(from: self)
    }
    
    // TODO: REMOVE LATER
    func insertTestContent() {
        let image = #imageLiteral(resourceName: "Eva_Test")
        
        images = [ImageSource(image: image), ImageSource(image: image), ImageSource(image: image)]
        
        text = longTestText
    }
    
    
    /*
    private func startHeartBeat() {
        UIView.animate(withDuration: 1.2, delay: 0.1, options: [.repeat, .autoreverse, .allowUserInteraction, .curveEaseOut], animations: {
            let newSize = CGSize(width: self.heart.bounds.width * HEART_BEAT_RESIZE, height: self.heart.bounds.height * HEART_BEAT_RESIZE)
            self.heart.bounds = CGRect(origin: self.heart.bounds.origin, size: newSize)
        }, completion: nil)
    }
    
    private func stopHeartBeat() {
        heart.layer.removeAllAnimations()
    }*/
    
    
    private func loveRain(pieces: Int) {
        for _ in 0..<pieces {
            let image = UIImageView(image: randomRosePlate())
            
            let path = randomPath(rect: view.bounds)
            image.frame = CGRect(origin: path.currentPoint, size: CGSize(width: 30.0, height: 30.0))
            
            let animation = CAKeyframeAnimation(keyPath: "position")
            
            animation.path = path.cgPath
            animation.duration = 0.5 + drand48()
            animation.fillMode = kCAFillModeForwards
            animation.isRemovedOnCompletion = true
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            
            image.layer.add(animation, forKey: nil)
            
            view.addSubview(image)
        }
    }
    
    /// Creates a straight path from the top to the buttom of the given rectangle at a random x location.
    ///
    /// - Parameter rect: The rectangle the path will be created in.
    /// - Returns: Path straight down (90 degree) for a random x value.
    private func randomPath(rect: CGRect) -> UIBezierPath {
        let x = rect.width * CGFloat(drand48())
        let spawn = CGPoint(x: x, y: 0)
        let endpoint = CGPoint(x: x, y: rect.height)
        
        let path = UIBezierPath()
        path.move(to: spawn)
        path.addLine(to: endpoint)
        
        return path
    }
    
    private func randomRosePlate() -> UIImage {
        switch arc4random()%5 {
        case 0: return #imageLiteral(resourceName: "pink1")
        case 1: return #imageLiteral(resourceName: "pink2")
        case 3: return #imageLiteral(resourceName: "red1")
        case 4: return #imageLiteral(resourceName: "red2")
        case 5: return #imageLiteral(resourceName: "red3")
        default: return #imageLiteral(resourceName: "red1")
        }
    }
    
    private func reloadContent(forTimestamp timestamp: String? = nil) {
        // Reload content
        if let key = timestamp {
            // Get the database entry for the given timestamp.
            DataService.ds.REF_MEMORIES.child(key).observe(.value, with: { (snapshot) in
                // Extract data from the database snapshot.
                self.extractData(from: snapshot)
            })
        } else {
            // Get the latest database entry.
            DataService.ds.REF_MEMORIES.queryLimited(toLast: 1).observe(.value, with: { (snapshot) in
                // The first child is the latest database entry.
                let childSnap = snapshot.children.allObjects[0] as! FIRDataSnapshot
                self.extractData(from: childSnap)
            })
        }
    }
    
    /// Extracts the data from a given Firebase Snapshot and assigns it to the text and images property.
    /// This will also load the images from the web. Make sure to call this function only if it's necessary.
    ///
    /// - Parameter snapshot: The snapshot the data is to be extracted from.
    private func extractData(from snapshot: FIRDataSnapshot) {
        let text = snapshot.childSnapshot(forPath: DataBaseKeys.text).value as? String ?? "No text available."
        self.text = text
        let images = snapshot.childSnapshot(forPath: DataBaseKeys.images).children
        
        var imgSources = [ImageSource]()
        
        for image in images {
            if let imgURL = (image as? FIRDataSnapshot)?.value as? String {
                let imgREF = storage.reference(forURL: imgURL)
                imgREF.data(withMaxSize: 10 * 1024 * 1024, completion: { data, error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        if let img = UIImage(data: data!) {
                            imgSources.append(ImageSource(image: img))
                        }
                    }
                    self.images = imgSources
                })
            }
        }
    }
    
    /// Signes the account given in the credentials into Firebase if possible.
    /// Shows an alert with the error message if the login fails.
    private func authenticateFirebase() {
        FIRAuth.auth()?.signIn(withEmail: credentials.email, password: credentials.password) { (user, error) in
            if error != nil {
                print(error.debugDescription)
                let message = error?.localizedDescription
                let alert = UIAlertController(title: "Login Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { (alert: UIAlertAction) in
                    self.authenticateFirebase()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}

