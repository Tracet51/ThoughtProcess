//
//  ViewAndEditViewController.swift
//  ThoughtProcess
//
//  Created by Trace Tschida on 3/8/18.
//  Copyright © 2018 cs329e. All rights reserved.
//

import UIKit

class ViewAndEditViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Connect the scroll view delegate and configure size
        self.viewAndEditScrollView.delegate = self
        self.viewAndEditScrollView.minimumZoomScale = 1.0
        self.viewAndEditScrollView.maximumZoomScale = 4.0
        self.viewAndEditScrollView.zoomScale = 2.0
        
        // Hook up tge keyboard dismissal
        viewAndEditScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        
        // Confine the subview to this view
        self.canvasView.clipsToBounds = true
        
        // Create a tap recognizer for the canvas to dismiss the keyboard
        let tapCanvas = UITapGestureRecognizer(target: self, action: #selector(tapCanvas(_:)))
        canvasView.addGestureRecognizer(tapCanvas)
    }
    
    // UI Properties
    @IBOutlet weak var viewAndEditScrollView: UIScrollView!
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var optionsToolBar: UIToolbar!
    var sections: [Int: ArrowView] = [:]
    var selectedSection: ArrowView?
    var alertController: UIAlertController? = nil
    var colorPicker: UIPickerView?
    var textPropertyPicker: UIPickerView?
    var blurView: UIVisualEffectView?
    
    // Controller Properties
    let colors: [String] = ["Black", "Red", "Blue", "Green", "Gray", "Light Gray", "Purple", "Orange", "Yellow"]
    let fontStyles: [String] = ["Body", "Callout", "Caption 1", "Caption 2", "Footnote", "Headline", "Subheadline", "Large Title", "Title 1", "Title 2", "Title 3"]
    
    // UI Methods
    @IBAction func changeTextButton(_ sender: UIBarButtonItem) {
        
        // Create a floating text property picker
        let textPropertyPicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.maxX, height: self.view.frame.maxY))
        textPropertyPicker.dataSource = self
        textPropertyPicker.delegate = self
        textPropertyPicker.tag = 1
        self.textPropertyPicker = textPropertyPicker
        
        // Create a select button
        let selectButton: UIButton = UIButton(frame: CGRect(x: 100, y: 100, width: 200, height: 100))
        selectButton.setTitle("Apply Changes", for: .normal)
        selectButton.setTitleColor(UIColor.white, for: .normal)
        selectButton.backgroundColor = UIColor.blue
        selectButton.layer.cornerRadius = 5
        // selectButton.center.x = colorPicker.center.x
        // selectButton.center.y = colorPicker.center.y
        
        // Create blur effect
        self.createBlurEffect()
        
        // Add text property picker to view
        self.view.addSubview(textPropertyPicker)
        self.view.addSubview(selectButton)
    }
    
    @IBAction func changeColorButton(_ sender: UIBarButtonItem) {
        
        // Create a floating color picker
        let colorPicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.maxX, height: self.view.frame.maxY))
        colorPicker.dataSource = self
        colorPicker.delegate = self
        colorPicker.tag = 0
        self.colorPicker = colorPicker
        
        // Create Blur Effect
        self.createBlurEffect()
        
        // Add the color picker color
        self.view.addSubview(colorPicker)
        
    }
    
    
    @IBAction func addSectionButton(_ sender: UIBarButtonItem) {
        
        // Create a new Arrow shape
        let viewCenter: CGPoint = CGPoint(x: self.viewAndEditScrollView.center.x - 100, y: self.viewAndEditScrollView.center.y - 100)
        let arrow = ArrowView(frame: CGRect(origin: viewCenter, size: CGSize(width: 150, height: 100)), controller: self)
        arrow.tag = sections.count + 1
        
        // Add a pan gesture recognizer to the arrow
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleArrowPan(_:)))
        pan.name = "pan"
        pan.delegate = self
        arrow.addGestureRecognizer(pan)
        
        // Add a zooming gesturing for each map part
        let zoom = UIPinchGestureRecognizer(target: self, action: #selector(handleArrowZoom(_:)))
        arrow.addGestureRecognizer(zoom)
        
        // Add a long press gesture recognizer
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleArrowLongPress(_:)))
        longPress.minimumPressDuration = CFTimeInterval(1)
        longPress.numberOfTapsRequired = 0
        longPress.numberOfTouchesRequired = 1
        arrow.addGestureRecognizer(longPress)
        
        let movementLongPress = UILongPressGestureRecognizer(target: self, action: #selector(handleSectionMovementLongPress(_:)))
        movementLongPress.minimumPressDuration = CFTimeInterval(0.0001)
        movementLongPress.numberOfTapsRequired = 1
        movementLongPress.numberOfTouchesRequired = 1
        movementLongPress.delegate = self
        movementLongPress.name = "movementLongPress"
        arrow.addGestureRecognizer(movementLongPress)
        
        // Add the arrows to an array
        self.sections[arrow.tag] = arrow
        
        // Add the arrow to the canvas
        self.canvasView.addSubview(arrow)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

}

extension ViewAndEditViewController: UIScrollViewDelegate {
    // Controller Methods
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvasView
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // updateMinZoomScaleForSize(view.bounds.size)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // view?.transform = CGAffineTransform(scaleX: scale, y: scale)
        view?.layoutSubviews()
        
    }
    
    func updateMinZoomScaleForSize (_ size: CGSize) {
        let widthScale = size.width / canvasView.bounds.width
        let heightScale = size.height / canvasView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        viewAndEditScrollView.minimumZoomScale = minScale
        viewAndEditScrollView.zoomScale = minScale
    }
}

extension ViewAndEditViewController {
    
    // Gesture Handlers
    @IBAction func tapCanvas(_ recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
        self.viewAndEditScrollView.isScrollEnabled = true
    }
    
    @IBAction func handleSectionMovementLongPress(_ recognizer: UILongPressGestureRecognizer) {
        
        if recognizer.state == .ended {
            
            // Unlock the panning and zooming for the scroll view
            self.viewAndEditScrollView.isScrollEnabled = true
        }
        else if recognizer.state == .began || recognizer.state == .changed {
            
            // Lock the scrolling view
            self.viewAndEditScrollView.isScrollEnabled = false
        }
    }
    
    @IBAction func handleArrowLongPress(_ recognizer: UILongPressGestureRecognizer) {
        
        // Create an alert controller for the section deletion
        self.alertController = UIAlertController(title: "Delete Section", message: "Would you like to delete this Section?", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (alertAction) in
            
            // Get the section to delete
            guard let section = recognizer.view else { return }
            
            // Remove the section from the view hiearchy
            section.removeFromSuperview()
            
            // Remove from the array
            
        })
        self.alertController?.addAction(cancelAction)
        self.alertController?.addAction(deleteAction)
        
        self.present(self.alertController!, animated: true, completion: nil)
        
    }
    @IBAction func handleArrowZoom(_ recognizer: UIPinchGestureRecognizer) {
        
        // Make sure the view exists
        guard recognizer.view != nil else { return }
        
        if recognizer.state == .began || recognizer.state == .changed {
            recognizer.view?.transform = (recognizer.view?.transform.scaledBy(x: recognizer.scale, y: recognizer.scale))!
            
            // Reset the recognizer
            recognizer.scale = 1.0
        }
    }
    @IBAction func handleArrowPan(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        guard let view = recognizer.view else { return }
        guard let canvas = view.superview else { return }
        
        // Set the translation
        // Check to make sure the item is not outside the bounds
        var newFrame = view.frame
        newFrame.origin.x += translation.x
        newFrame.origin.y += translation.y
        
        if canvas.bounds.contains(view.frame) {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        }
            
        // Check the edges
        else if newFrame.minX < canvas.bounds.minX {
            view.center.x = canvas.bounds.minX + view.frame.size.width / 2
        }
            
        else if newFrame.maxX > canvas.bounds.maxX {
            view.center.x = canvas.bounds.maxX - view.frame.size.width / 2
        }
            
        else if newFrame.minY < canvas.bounds.minY {
            view.center.y = canvas.bounds.minY + view.frame.size.height / 2
        }
            
        else if newFrame.maxY > canvas.bounds.maxY {
            view.center.y = canvas.bounds.maxY - view.frame.size.height / 2
        }
        
        // Reset the translation to 0
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
}

extension ViewAndEditViewController: UITextViewDelegate {
    
    // Keyboard setup
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.viewAndEditScrollView.isScrollEnabled = false
        self.selectedSection = textView.superview as? ArrowView
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.viewAndEditScrollView.isScrollEnabled = true
        textView.resignFirstResponder()
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        // Get the Section class
        guard let section = textView.superview as? ArrowView else { return }
        
        // Save the text to the section class
        section.textView = textView
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension ViewAndEditViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView.tag {
        case 0:
            return 1
        default:
            // 3 components:
            // Text Font, Text Color, and Background Color
            return 3
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView.tag {
            
        case 0:
            return self.colors.count
            
        default:
            
            // Check the component number
            if component == 0 {
                return 11 // The number of fonts
            }
            else {
                return self.colors.count // The number of colors
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        switch pickerView.tag {
            
        case 0:
            
            let colorString = NSAttributedString(string: self.colors[row], attributes: [NSAttributedStringKey.foregroundColor: self.getUIColor(row)])
            return colorString
            
        default:
            
            // Check if font, color, or backgroun
            if component == 0 {
                let fontString = NSAttributedString(string: self.fontStyles[row], attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: self.getUIFontStyle(row))])
                return fontString
            }
                
            else {
                
                let colorString = NSAttributedString(string: self.colors[row], attributes: [NSAttributedStringKey.foregroundColor: self.getUIColor(row)])
                return colorString
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView.tag {
        case 0:
            
            // Get the color
            let color: UIColor = self.getUIColor(row)
            
            // Change the color of every section
            for (_, section) in self.sections {
                section.color = color
            }
            
            // Remove the color picker and blur effect
            self.colorPicker?.removeFromSuperview()
            
        default:
            var _ = "trace"
        }
        
        // Remove the blur effect
        self.blurView?.removeFromSuperview()
    }
}

extension ViewAndEditViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.name == "movementLongPress" && otherGestureRecognizer.name == "pan"
    }
}

extension ViewAndEditViewController {
    
    func getUIColor(_ row: Int) -> UIColor {
        
        var color: UIColor
        
        switch row {
        case 1:
            color = UIColor.red
        case 2:
            color = UIColor.blue
        case 3:
            color = UIColor.green
        case 4:
            color = UIColor.gray
        case 5:
            color = UIColor.lightGray
        case 6:
            color = UIColor.purple
        case 7:
            color = UIColor.orange
        case 8:
            color = UIColor.yellow
        default:
            color = UIColor.black
        }
        
        return color
    }
    
    func getUIFontStyle(_ row: Int) -> UIFontTextStyle {
        
        var fontStyle: UIFontTextStyle
        
        switch row {
        case 1:
            fontStyle = UIFontTextStyle.callout
        case 2:
            fontStyle = UIFontTextStyle.caption1
        case 3:
            fontStyle = UIFontTextStyle.caption2
        case 4:
            fontStyle = UIFontTextStyle.footnote
        case 5:
            fontStyle = UIFontTextStyle.headline
        case 6:
            fontStyle = UIFontTextStyle.subheadline
        case 7:
            fontStyle = UIFontTextStyle.largeTitle
        case 8:
            fontStyle = UIFontTextStyle.title1
        case 9:
            fontStyle = UIFontTextStyle.title2
        case 10:
            fontStyle = UIFontTextStyle.title3
        default:
            fontStyle = UIFontTextStyle.body
        }
        
        return fontStyle
    }
    
    func createBlurEffect() {
        
        // Create a blur effect
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurView = blurEffectView
        view.addSubview(blurEffectView)
    }
}

extension ViewAndEditViewController {
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
