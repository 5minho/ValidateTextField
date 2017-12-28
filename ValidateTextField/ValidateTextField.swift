//
//  ValidateTextField.swift
//  ValidateTextField
//
//  Created by 오민호 on 2017. 12. 16..
//  Copyright © 2017년 오민호. All rights reserved.
//

import UIKit

extension String {
    
    public var fullRange : NSRange {
        return NSMakeRange(0, self.count)
    }
    
    public func replace(of targetString: String?, with withString: String) -> String {
        guard let target = targetString else {return self}
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
}

extension UIView {
    
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: self.center.x - 10, y: self.center.y)
        animation.toValue = CGPoint(x: self.center.x + 10, y: self.center.y)
        self.layer.add(animation, forKey: "position")
    }
    
    var userInterfaceLayoutDirection: UIUserInterfaceLayoutDirection {
        if #available(iOS 9.0, *) {
            return UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute)
        } else {
            return UIApplication.shared.userInterfaceLayoutDirection
        }
    }
    
}

enum ValidateType {
    
    var defaultEmailValidPattern : String {
        return "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
    }
    
    var defaultPhoneNumberValidPattern : String {
        return "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
    }
    
    case none
    case email (customPattern : String?)
    case phone (customPattern : String?)
    
    var regex : NSRegularExpression? {
        switch self {
        case .phone(let pattern):
            if let customPattern = pattern {
                return try? NSRegularExpression(pattern: customPattern, options: [])
            } else {
                let defaultPattern = "^(01[016789])-?(\\d{3,4}?)-?(\\d{3,4})$"
                return try? NSRegularExpression(pattern: defaultPattern, options: [])
            }
            
        case .email(let pattern):
            if let customPattern = pattern {
                return try? NSRegularExpression(pattern: customPattern, options: [])
            } else {
                return try? NSRegularExpression(pattern: defaultEmailValidPattern, options: [])
            }
            
        case .none:
            return nil
        }
    }
    
    var maxLength : Int? {
        switch self {
        case .phone(_):
            return 11 + 2
        case .email(_):
            return nil
        case .none:
            return nil
        }
    }
    
    var keyBoardType : UIKeyboardType {
        switch self {
        case .phone(_):
            return .phonePad
        case .email(_):
            return .emailAddress
        case .none:
            return .default
        }
    }
    
    func isvalid(text : String) -> Bool {
        switch self {
        case .phone(_):
            guard let _ = self.validate(phoneNumber: text).hyphen,
                let _ = self.validate(phoneNumber: text).nohyphen else {
                    return false
            }
            return true
            
        case.email(let pattern):
            var emailTest = NSPredicate()
            
            if let customPattern = pattern {
                emailTest = NSPredicate(format:"SELF MATCHES[c] %@", customPattern)
                
            } else {
                let defaultPattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
                emailTest = NSPredicate(format:"SELF MATCHES[c] %@", defaultPattern)
            }
            
            return emailTest.evaluate(with: text)
            
        case .none:
            return true
            
        }
    }
    
    func validate(phoneNumber : String) -> (nohyphen : String?, hyphen : String?) {
        
        switch self {
            
        case .phone(_):
            guard let regex = self.regex else {
                debugPrint("invalid Regex")
                return (nil, nil)
            }
            
            guard let match = regex.firstMatch(in: phoneNumber, options: [], range: phoneNumber.fullRange) else {
                debugPrint("invalid match")
                return (nil, nil)
            }
            
            var matchStrings = [String]()
            
            for i in 1..<match.numberOfRanges {
                if let range = Range(match.range(at: i), in : phoneNumber) {
                    matchStrings.append(String(phoneNumber[range]))
                }
            }
            
            return (matchStrings.joined(separator: ""), matchStrings.joined(separator: "-"))
            
        default:
            return (nil, nil)
        }
        
    }
    
}

extension ValidateType : Equatable {
    static func ==(lhs: ValidateType, rhs: ValidateType) -> Bool {
        switch (lhs, rhs) {
        case (let .email(pattern1), let .email(pattern2)):
            return pattern1 == pattern2
            
        case (let .phone(pattern1), let .phone(pattern2)):
            return pattern1 == pattern2
            
        case (.none, .none):
            return true
            
        default:
            return false
        }
    }
}

class ValidateTextField: UITextField {
    
    private var _domains : [String]?
    
    var domains : [String]? {
        get {
            return _domains
        }
        set {
            _domains = newValue
        }
    }
    
    private var _domainTextColor : UIColor?
    
    var domainTextColor : UIColor? {
        get {
            return _domainTextColor
        }
        set {
            _domainTextColor = newValue
            domainLabel.textColor = newValue
            emailEditingEnded(self)
        }
    }

    let defaultDomain = ["aol.com", "att.net", "comcast.net", "facebook.com", "gmail.com", "gmx.com", "googlemail.com", "google.com", "hotmail.com", "hotmail.co.uk", "mac.com", "me.com", "mail.com", "msn.com", "live.com", "sbcglobal.net", "verizon.net", "yahoo.com", "yahoo.co.uk", "email.com", "games.com", "gmx.net", "hush.com", "hushmail.com", "icloud.com", "inbox.com", "lavabit.com", "love.com", "outlook.com", "pobox.com", "rocketmail.com", "safe-mail.net", "wow.com", "ygm.com", "ymail.com", "zoho.com", "fastmail.fm", "yandex.com", "bellsouth.net", "charter.net", "comcast.net", "cox.net", "earthlink.net", "juno.com", "btinternet.com", "virginmedia.com", "blueyonder.co.uk", "freeserve.co.uk", "live.co.uk", "ntlworld.com", "o2.co.uk", "orange.net", "sky.com", "talktalk.co.uk", "tiscali.co.uk", "virgin.net", "wanadoo.co.uk", "bt.com", "sina.com", "qq.com", "naver.com", "hanmail.net", "daum.net", "nate.com", "yahoo.co.jp", "yahoo.co.kr", "yahoo.co.id", "yahoo.co.in", "yahoo.com.sg", "yahoo.com.ph", "hotmail.fr", "live.fr", "laposte.net", "yahoo.fr", "wanadoo.fr", "orange.fr", "gmx.fr", "sfr.fr", "neuf.fr", "free.fr", "gmx.de", "hotmail.de", "live.de", "online.de", "t-online.de", "web.de", "yahoo.de", "mail.ru", "rambler.ru", "yandex.ru", "ya.ru", "list.ru", "hotmail.be", "live.be", "skynet.be", "voo.be", "tvcablenet.be", "telenet.be", "hotmail.com.ar", "live.com.ar", "yahoo.com.ar", "fibertel.com.ar", "speedy.com.ar", "arnet.com.ar", "hotmail.com", "gmail.com", "yahoo.com.mx", "live.com.mx", "yahoo.com", "hotmail.es", "live.com", "hotmail.com.mx", "prodigy.net.mx", "msn.com", "yahoo.com.br", "hotmail.com.br", "outlook.com.br", "uol.com.br", "bol.com.br", "terra.com.br", "ig.com.br", "itelefonica.com.br", "r7.com", "zipmail.com.br", "globo.com", "globomail.com", "oi.com.br"]
    
    let domainLabel = UILabel()
    
    open var textEdgeInsets : UIEdgeInsets = .zero
    
    override var font: UIFont? {
        didSet {
            super.font = font
            domainLabel.font = font
            emailEditingChanged(self)
        }
    }
    
    var pendingValidateWorkItem : DispatchWorkItem?
    
    var validateType : ValidateType = .none {
        didSet {
            self.keyboardType = validateType.keyBoardType
            self.maxLength = validateType.maxLength
            
            if validateType == .email(customPattern: nil) {
        
            }
        }
    }
    
    var isValidLength : Bool {
        guard let maxLength = self.maxLength else {
            return true
        }
        
        let textLength = self.text?.count ?? 0
        return maxLength > textLength
    }
    
    var maxLength : Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(validate(_ :)), for: .valueChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(validate(_ :)), for: .editingChanged)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addTarget(self, action: #selector(validate(_ :)), for: .editingChanged)
    }
    
    @objc func validate(_ textField : UITextField) {
        pendingValidateWorkItem?.cancel()
        
        let validWorkItem = DispatchWorkItem {
            switch self.validateType {
            case .phone(_):
                guard let validTextWithHypen = self.validateType.validate(phoneNumber: textField.text!).hyphen else {
                    self.shake()
                    print("invalid ")
                    return
                }
                print("valid ")
                print(validTextWithHypen)
                textField.text = validTextWithHypen
                
                return
                
            case .email(_):
                guard self.validateType.isvalid(text: textField.text!) else {
                    self.shake()
                    print("invalid ")
                    return
                }
                print("valid")
                return
                
            case .none:
                return
            }
        }
        
        pendingValidateWorkItem = validWorkItem
        
        if let pendingValidateWorkItem = self.pendingValidateWorkItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500),execute: pendingValidateWorkItem)
        }
        
    }
    
    @objc func emailEditingChanged(_ textField : UITextField) {
        guard let text = self.text,
            let domains = self.domains,
            text.isEmpty == false,
            text.contains("@") else {
                domainLabel.text = ""
                return
        }
        
        let recommmendDomain = self.recommendDomain(with : text, in : domains)
        let writtenDomain = text.components(separatedBy: "@").last
        
        let domain = recommmendDomain?.replace(of: writtenDomain, with : "")
        domainLabel.text = domain
        
        self.textRect(forBounds: .zero)
        
        let textWidth = text.size(withAttributes: [NSAttributedStringKey.font : font!]).width
        domainLabel.frame = CGRect(x: textWidth + textEdgeInsets.left,
                                   y: 0.0,
                                   width: frame.width - textWidth,
                                   height: frame.height)
        
    }
    
    @objc func emailEditingEnded(_ sender : UITextField) {
        domainLabel.text = "@"
        
        guard let text = self.text,
            let domains = self.domains,
            text.isEmpty == false ,
            text.contains("@") == false else {
                
                domainLabel.text = ""
                return
        }
        
        let recommmendDomain = self.recommendDomain(with : text, in : domains)
        let writtenDomain = text.components(separatedBy: "@").last
        
        let remainDomain = recommmendDomain?.replace(of: writtenDomain, with : "")
        
        if let remainDomain = remainDomain,
            remainDomain.isEmpty == false {
            self.text = text.appending(remainDomain)
        }
        
    }

    
    func recommendDomain(with text : String, in domains : [String]) -> String? {
        guard let writtenDomain = text.components(separatedBy: "@").last else {
            return nil
        }
        
        let filteredDomain =  domains.filter {
            $0.starts(with: writtenDomain)
        }
        
        return filteredDomain.first
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: UIEdgeInsetsInsetRect(bounds, textEdgeInsets))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: UIEdgeInsetsInsetRect(bounds, textEdgeInsets))
    }
    


    
}



