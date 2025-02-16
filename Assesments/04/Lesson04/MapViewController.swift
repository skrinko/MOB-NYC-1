//
//  MapViewController.swift
//  Lesson04
//
/*

TODO three: Add TWO text views and a table view to this view controller, either using code or storybaord. Accept keyboard input from the two text views. When the 'return' button is pressed on the SECOND text view, add the text view data to a dictionary. The KEY in the dictionary should be the string in the first text view, the VALUE should be the second.
*/

/*
TODO four: Make this class a UITableViewDelegate and UITableViewDataSource that supply this table view with cells that correspond to the values in the dictionary. Each cell should print out a unique pair of key/value that the map contains. When a new key/value is inserted, the table view should display it.
*/

/*
TODO five: Make the background of the text boxes in this controller BLUE when the keyboard comes up, and RED when it goes down. Start with UIKeyboardWillShowNotification and NSNotificationCenter.
*/
//

import UIKit

class MapViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    private var tableView = UITableView()
    private var keyTextField = UITextField()
    private let keyTextFieldPlaceHolder = " KEY"
    private var valueTextField = UITextField()
    private let valueTextFieldPlaceHoler = " VALUE"
    private var keyValueDictionaryArray = OrderedDictionary<String,String>()
    private var enterButton = UIButton()
    private var tapGesture = UITapGestureRecognizer()
    private var swipeGesture = UISwipeGestureRecognizer()
    
    let frame = CGRect()
    var minX = CGFloat()
    var minY = CGFloat()
    var width = CGFloat()
    var height = CGFloat()
    
    private let rowHeight: CGFloat = 40
    private let backgroundColor = UIColor(red:0.16, green:0.17, blue:0.21, alpha:1)
    private let backgroundColorKeyboardShow = UIColor(red:0.46, green:0.86, blue:1, alpha:1)
    private let backgroundColorKeyboardHide = UIColor(red:1, green:0.41, blue:0.33, alpha:1)
        
    // MARK: Init
    
    override init() {
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = "Map"
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupUserInputFields()
        setupInputFieldsConstraints()
        setupSwipeToArray()
        setupNotificationObservers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect(x: minX, y: minY, width: width, height: height))
        tableView.tableHeaderView = UIView(frame: CGRect(x: minX, y: minY, width: width, height: rowHeight))
        tableView.autoresizingMask = (UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight)
        tableView.backgroundColor = backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsetsZero
        // Travis suggestion to make TV.separator invisible and add cell.layer.border to make cell wall continuous. Can't get it to look how i want, so went with EdgeInsets instead. see willDisplayCell:
        //tableView.separatorColor = UIColor.clearColor()
        //tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        // Dismiss keyboard if active and unused cell is tapped
        tapGesture.addTarget(self, action: Selector("dismissKeyboardIfActive"))
        tableView.addGestureRecognizer(tapGesture)
        tableView.userInteractionEnabled = true
        self.view.addSubview(tableView)
    }
    
    private func setupUserInputFields() {
        let textFieldWidth = (width / 2) - rowHeight
        let valueX = minX + (textFieldWidth / 2)
        let buttonX = minX + textFieldWidth
        
        keyTextField = UITextField(frame: CGRect(x: minX, y: minY, width: textFieldWidth, height: rowHeight))
        keyTextField.delegate = self
        keyTextField.borderStyle = UITextBorderStyle.Line
        keyTextField.backgroundColor = UIColor.lightGrayColor()
        keyTextField.placeholder = keyTextFieldPlaceHolder
        keyTextField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
        keyTextField.layer.cornerRadius = 10
        keyTextField.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        valueTextField = UITextField(frame: CGRect(x: valueX, y: minY, width: textFieldWidth, height: rowHeight))
        valueTextField.delegate = self
        valueTextField.borderStyle = UITextBorderStyle.Line
        valueTextField.backgroundColor = UIColor.lightGrayColor()
        valueTextField.placeholder = valueTextFieldPlaceHoler
        valueTextField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
        valueTextField.layer.cornerRadius = 10
        valueTextField.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        enterButton = UIButton(frame: CGRect(x: buttonX, y: minY, width: rowHeight, height: rowHeight))
        enterButton.layer.borderWidth = 1
        enterButton.setAttributedTitle(NSAttributedString(string: "+"), forState: .Normal)
        enterButton.backgroundColor = UIColor.lightGrayColor()
        enterButton.layer.cornerRadius = 10
        enterButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        enterButton.addTarget(self, action: Selector("enterButtonPressed"), forControlEvents: .TouchUpInside)
        
        tableView.tableHeaderView?.addSubview(keyTextField)
        tableView.tableHeaderView?.addSubview(valueTextField)
        tableView.tableHeaderView?.addSubview(enterButton)
    }
    
    private func setupInputFieldsConstraints() {
        // Horizontal Layout
        let keyTextLeft = NSLayoutConstraint(
            item: keyTextField,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: tableView.tableHeaderView,
            attribute: .Left,
            multiplier: 1.0,
            constant: 0.0)
        let valueTextLeft = NSLayoutConstraint(
            item: valueTextField,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: keyTextField,
            attribute: .Right,
            multiplier: 1.0,
            constant: 0.0)
        let valueTextRight = NSLayoutConstraint(
            item: valueTextField,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: enterButton,
            attribute: .Left,
            multiplier: 1.0,
            constant: 0.0)
        let buttonRight = NSLayoutConstraint(
            item: enterButton,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: tableView.tableHeaderView,
            attribute: .Right,
            multiplier: 1.0,
            constant: 0.0)
        let keyValueEqualWidths = NSLayoutConstraint(
            item: keyTextField,
            attribute: NSLayoutAttribute.Width,
            relatedBy: .Equal,
            toItem: valueTextField,
            attribute: NSLayoutAttribute.Width,
            multiplier: 1.0,
            constant: 0.0)

        tableView.tableHeaderView?.addConstraints([keyTextLeft, valueTextLeft, valueTextRight, buttonRight, keyValueEqualWidths])
        
        // Vertical Layout
        let keyTextTop = NSLayoutConstraint(
            item: keyTextField,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: tableView.tableHeaderView,
            attribute: .Top,
            multiplier: 1.0,
            constant: 0.0)
        let keyTextBottom = NSLayoutConstraint(
            item: keyTextField, 
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: tableView.tableHeaderView,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0.0)
        let valueTextTop = NSLayoutConstraint(
            item: valueTextField, 
            attribute: .Top,
            relatedBy: .Equal,
            toItem: tableView.tableHeaderView,
            attribute: .Top,
            multiplier: 1.0,
            constant: 0.0)
        let valueTextBottom = NSLayoutConstraint(
            item: valueTextField,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: tableView.tableHeaderView,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0.0)
        let enterButtonTop = NSLayoutConstraint(
            item: enterButton,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: tableView.tableHeaderView,
            attribute: .Top,
            multiplier: 1.0,
            constant: 0.0)
        let enterButtonBottom = NSLayoutConstraint(
            item: enterButton,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: tableView.tableHeaderView,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0.0)
        
        tableView.tableHeaderView?.addConstraints([keyTextTop, keyTextBottom, valueTextTop, valueTextBottom, enterButtonTop, enterButtonBottom])
        
    }
    
    private func setupSwipeToArray() {
        swipeGesture.addTarget(self, action: Selector("swipeToArray"))
        swipeGesture.direction = .Right
        tableView.addGestureRecognizer(swipeGesture)
        tableView.userInteractionEnabled = true
    }
    
    internal func swipeToArray() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    private func setupNotificationObservers() {
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardDidShowNotification, object: nil, queue: nil) { (notification: NSNotification!) -> Void in
            self.keyTextField.backgroundColor = self.backgroundColorKeyboardShow
            self.valueTextField.backgroundColor = self.backgroundColorKeyboardShow
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardDidHideNotification, object: nil, queue: nil) { (notification: NSNotification!) -> Void in
            self.keyTextField.backgroundColor = self.backgroundColorKeyboardHide
            self.valueTextField.backgroundColor = self.backgroundColorKeyboardHide
        }
    }
    
    internal func enterButtonPressed() {
        if (keyTextField.text.isEmpty | valueTextField.text.isEmpty) {
            UIAlertView(
                title: "Hey!",
                message: "Must add input to KEY and VALUE fields",
                delegate: self,
                cancelButtonTitle: "OK")
                .show()
        } else {
            keyValueDictionaryArray[keyTextField.text] = valueTextField.text
            keyTextField.text = ""
            keyTextField.resignFirstResponder()
            valueTextField.text = ""
            valueTextField.resignFirstResponder()
            tableView.reloadData()
        }
    }
    
    internal func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField.placeholder == keyTextFieldPlaceHolder && valueTextField.text.isEmpty) {
            valueTextField.becomeFirstResponder()
            return true
        } else if (textField.placeholder == valueTextFieldPlaceHoler && keyTextField.text.isEmpty){
            keyTextField.becomeFirstResponder()
            return true
        } else {
            textField.resignFirstResponder()
            return true
        }
    }
    
    // MARK: Table View
    
    internal func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keyValueDictionaryArray.count
    }
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Map") as? UITableViewCell ?? UITableViewCell(style: .Value1, reuseIdentifier: "Map")
        let row = indexPath.row
        cell.textLabel?.text = keyValueDictionaryArray.keys[row]
        if let value = keyValueDictionaryArray[keyValueDictionaryArray.keys[row]] {
            cell.detailTextLabel?.text = value
        }
        cell.backgroundColor = backgroundColor
        cell.textLabel?.textColor = UIColor.whiteColor()

        return cell
        
    }
    
    internal func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Needed to customize cell edge insets to expand across the screen
        cell.separatorInset = UIEdgeInsetsZero
        cell.superview?.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
       // cell.layer.borderWidth = 1
    }
    
//    internal func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if (editingStyle == UITableViewCellEditingStyle.Delete) {
//            // TODO: Delete from Ordered Dict.  Maybe create a temp then copy to original, or add removeAtIndex method to OrdDict?
//            //tableArray.removeAtIndex(indexPath.row)
//            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        }
//    }
    
    internal func dismissKeyboardIfActive() {
        if keyTextField.isFirstResponder() {
            keyTextField.resignFirstResponder()
        } else if valueTextField.isFirstResponder() {
            valueTextField.resignFirstResponder()
        }
    }
    
    // MARK: Public Methods
    func setFrame(frame: CGRect) {
        minX = frame.minX
        minY = frame.minY
        width = frame.width
        height = frame.height
    }
}


