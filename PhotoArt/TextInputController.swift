//
//  TextInputController.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 26.10.2022.
//

import UIKit

class TextInputController: UIViewController {

    var onInputDone: (Text) -> () = { _ in }
    var onInputCancel: () -> () = { }

    lazy private var exitButton: UIButton = {
        let btn = UIButton(type: .system)

        btn.setTitle("Cancel", for: .normal)

        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(onExit), for: .touchUpInside)

        return btn
    }()

    lazy private var doneButton: UIButton = {
        let btn = UIButton(type: .system)

        btn.setTitle("Done", for: .normal)

        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(onDone), for: .touchUpInside)

        return btn
    }()

    lazy private var textView: UITextView = {
        let view = UITextView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false

        view.font = UIFont(name: "Arial", size: 32)
        view.textAlignment = .center
        view.text = ""

        view.inputAccessoryView = bar
        view.keyboardType = .default
        view.autocorrectionType = .no
        view.backgroundColor = .clear
        view.isScrollEnabled = false

        view.textContainerInset = .zero


        return view
    }()

    lazy private var textPreview: TextView = {
        let preview = TextView(text: "")
        preview.translatesAutoresizingMaskIntoConstraints = false

        preview.texts = [
            Text(text: "", font: UIFont(name: "Arial", size: 32)!, center: .zero)
        ]

        preview.selectedText = nil

        return preview
    }()

    lazy private var buttons: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let colorBtn = ColorButton(onColorCanged: { [unowned self] color in
            textPreview.texts[0].color = color
            textPreview.drawTexts(size: self.view.bounds.size)
        })

        colorBtn.translatesAutoresizingMaskIntoConstraints = false
        colorBtn.widthAnchor.constraint(equalToConstant: 32).isActive = true
        colorBtn.heightAnchor.constraint(equalToConstant: 32).isActive = true

        let textStyleBtn = TextStyleButton()
        textStyleBtn.onStyleChange = { [unowned self] style in
            textPreview.texts[0].style =  style
            textPreview.drawTexts(size: self.view.bounds.size)
        }

        textStyleBtn.translatesAutoresizingMaskIntoConstraints = false
        textStyleBtn.widthAnchor.constraint(equalToConstant: 32).isActive = true
        textStyleBtn.heightAnchor.constraint(equalToConstant: 32).isActive = true

        let textAlignmentBtn = TextAlignmentButton()
        textAlignmentBtn.onAlignmentChange = { [unowned self] alignment in
            textPreview.texts[0].alignment = alignment
            textView.textAlignment = alignment
            textPreview.drawTexts(size: self.view.bounds.size)
        }

        textAlignmentBtn.translatesAutoresizingMaskIntoConstraints = false
        textAlignmentBtn.widthAnchor.constraint(equalToConstant: 32).isActive = true
        textAlignmentBtn.heightAnchor.constraint(equalToConstant: 32).isActive = true

        view.addSubview(textAlignmentBtn)
        view.addSubview(textStyleBtn)
        view.addSubview(colorBtn)

        NSLayoutConstraint.activate([
            colorBtn.leftAnchor.constraint(equalTo: view.leftAnchor),
            colorBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            textStyleBtn.leftAnchor.constraint(equalTo: colorBtn.rightAnchor, constant: 12),
            textStyleBtn.centerYAnchor.constraint(equalTo: colorBtn.centerYAnchor),

            textAlignmentBtn.leftAnchor.constraint(equalTo: textStyleBtn.rightAnchor, constant: 12),
            textAlignmentBtn.centerYAnchor.constraint(equalTo: colorBtn.centerYAnchor),

            view.heightAnchor.constraint(equalToConstant: 32)
        ])
        return view
    }()

    lazy private var bar: UIToolbar = {
        let bar = UIToolbar()
        bar.heightAnchor.constraint(equalToConstant: 48).isActive = true

        bar.setItems([
            UIBarButtonItem(customView: buttons)
        ], animated: false)

        bar.sizeToFit()

        return bar
    }()

    private var lines: [String] {
        var result: [String] = []

        var currentPosition = 0
        let currentRange = textView.selectedRange

        textView.selectedRange = NSRange(location: 0, length: 0)

        while currentPosition != textView.text.count {
            print("here")
            if textView.text[textView.text.index(textView.text.startIndex, offsetBy: currentPosition)] == "\n" {
                currentPosition += 1
                textView.selectedRange = NSRange(location: currentPosition, length: 0)
                //continue
            }

            let currentPositionLabel = textView.selectedTextRange!.start
            let endOfLine =
            textView.tokenizer.position(from: currentPositionLabel, toBoundary: .line, inDirection: .storage(.forward))!

            let intEnd = textView.offset(from: textView.beginningOfDocument, to: endOfLine)

            result.append(String(textView.text[textView.text.index(textView.text.startIndex, offsetBy: currentPosition)..<textView.text.index(textView.text.startIndex, offsetBy: intEnd)]))

            currentPosition = intEnd
            textView.selectedRange = NSRange(location: currentPosition, length: 0)
        }


        textView.selectedRange = currentRange
        print(result.count)
        return result
    }

    @objc private func onExit() {
        onInputCancel()
        dismiss(animated: true)
    }

    @objc private func onDone() {
        onInputDone(textPreview.texts[0])
        dismiss(animated: true)
    }

    override func viewDidLayoutSubviews() {
        textPreview.subviews[0].frame = view.bounds
        textPreview.drawTexts(size: view.bounds.size)
    }

    private var centerTextViewConstraint: NSLayoutConstraint!
    private var bottomTextPreviewConstraint: NSLayoutConstraint!


    @objc private func onKeyboardUpdate(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            centerTextViewConstraint.constant = -(keyboardSize.height + (view.bounds.height - keyboardSize.height) / 2)
            bottomTextPreviewConstraint.constant = -keyboardSize.height
            view.layoutIfNeeded()

            print(textPreview.bounds.center)
            textPreview.texts[0].center = textPreview.bounds.center
            textPreview.texts[0].scale = 1
            textPreview.texts[0].rotation = 0

            textPreview.drawTexts(size: view.bounds.size)
        }
    }

    init(text: Text? = nil) {
        super.init(nibName: nil, bundle: nil)

        textPreview.texts[0] = text ?? Text(text: "", center: .zero)
        textPreview.texts[0].scale = 1
        textPreview.texts[0].rotation = 0
        textPreview.texts[0].center = .zero

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textPreview.texts[0].alignment

        textView.attributedText = NSAttributedString(string: textPreview.texts[0].text, attributes: [
            .paragraphStyle: paragraphStyle,
            .font: textPreview.texts[0].font,
            .foregroundColor: UIColor.clear,
        ])

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.addSubview(textPreview)
        view.addSubview(textView)
        view.addSubview(exitButton)
        view.addSubview(doneButton)

        textPreview.isUserInteractionEnabled = false

        centerTextViewConstraint = textView.centerYAnchor.constraint(equalTo: view.bottomAnchor)
        bottomTextPreviewConstraint = textPreview.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)

        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardUpdate), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardUpdate), name: UIResponder.keyboardDidShowNotification, object: nil)

        NSLayoutConstraint.activate([
            textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerTextViewConstraint,
            textView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 1, constant: -32),

            textPreview.leftAnchor.constraint(equalTo: view.leftAnchor),
            textPreview.rightAnchor.constraint(equalTo: view.rightAnchor),
            textPreview.topAnchor.constraint(equalTo: view.topAnchor),
            bottomTextPreviewConstraint,

            exitButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            exitButton.heightAnchor.constraint(equalToConstant: 42),
            exitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),

            doneButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12),
            doneButton.heightAnchor.constraint(equalToConstant: 42),
            doneButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12)
        ])

        textView.becomeFirstResponder()
    }
}

extension TextInputController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textPreview.texts[0].alignment

        textView.attributedText = NSAttributedString(string: textView.text, attributes: [
            .paragraphStyle: paragraphStyle,
            .font: textPreview.texts[0].font,
            .foregroundColor: UIColor.clear,
        ])

        textView.setNeedsLayout()
        textView.layoutIfNeeded()

        textPreview.texts[0].text = lines.map({ $0 == "" ? " " : $0 }).joined(separator: "\n")
        textPreview.drawTexts(size: view.bounds.size)
    }
}
