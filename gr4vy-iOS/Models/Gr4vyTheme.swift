//
//  Gr4vyTheme.swift
//  gr4vy-ios
//

import UIKit

public struct Gr4vyTheme: Codable {
    
    let fonts: Gr4vyFonts?
    let colors: Gr4vyColours?
    let borderWidths: Gr4vyBorderWidths?
    let radii: Gr4vyRadii?
    let shadows: Gr4vyShadows?
    var navigationBackgroundColor: UIColor? {
        guard let headerBackground = colors?.headerBackground else {
            return nil
        }
        return hexStringToUIColor(hex: headerBackground)
    }
    var navigationTextColor: UIColor? {
        guard let headerText = colors?.headerText else {
            return nil
        }
        return hexStringToUIColor(hex: headerText)
    }
    
    public init(fonts: Gr4vyFonts? = nil, colors: Gr4vyColours? = nil, borderWidths: Gr4vyBorderWidths? = nil, radii: Gr4vyRadii? = nil, shadows: Gr4vyShadows? = nil) {
        self.fonts = fonts
        self.colors = colors
        self.borderWidths = borderWidths
        self.radii = radii
        self.shadows = shadows
    }
    
    private func hexStringToUIColor (hex:String) -> UIColor? {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return nil
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

public struct Gr4vyFonts: Codable {
    let body: String?
    
    public init(body: String? = nil) {
        self.body = body
    }
}

public struct Gr4vyColours: Codable {
    let text: String?
    let subtleText: String?
    let labelText: String?
    let primary: String?
    let pageBackground: String?
    let containerBackgroundUnchecked: String?
    let containerBackground: String?
    let containerBorder: String?
    let inputBorder: String?
    let inputBackground: String?
    let inputText: String?
    let inputRadioBorder: String?
    let inputRadioBorderChecked: String?
    let danger: String?
    let dangerBackground: String?
    let dangerText: String?
    let info: String?
    let infoBackground: String?
    let infoText: String?
    let focus: String?
    let headerText: String?
    let headerBackground: String?
    
    public init(text: String? = nil, subtleText: String? = nil, labelText: String? = nil, primary: String? = nil, pageBackground: String? = nil, containerBackgroundUnchecked: String? = nil, containerBackground: String? = nil, containerBorder: String? = nil, inputBorder: String? = nil, inputBackground: String? = nil, inputText: String? = nil, inputRadioBorder: String? = nil, inputRadioBorderChecked: String? = nil, danger: String? = nil, dangerBackground: String? = nil, dangerText: String? = nil, info: String? = nil, infoBackground: String? = nil, infoText: String? = nil, focus: String? = nil, headerText: String? = nil, headerBackground: String? = nil) {
        self.text = text
        self.subtleText = subtleText
        self.labelText = labelText
        self.primary = primary
        self.pageBackground = pageBackground
        self.containerBackgroundUnchecked = containerBackgroundUnchecked
        self.containerBackground = containerBackground
        self.containerBorder = containerBorder
        self.inputBorder = inputBorder
        self.inputBackground = inputBackground
        self.inputText = inputText
        self.inputRadioBorder = inputRadioBorder
        self.inputRadioBorderChecked = inputRadioBorderChecked
        self.danger = danger
        self.dangerBackground = dangerBackground
        self.dangerText = dangerText
        self.info = info
        self.infoBackground = infoBackground
        self.infoText = infoText
        self.focus = focus
        self.headerText = headerText
        self.headerBackground = headerBackground
    }
}

public struct Gr4vyBorderWidths: Codable {
    let container: String?
    let input: String?
    
    public init(container: String? = nil, input: String? = nil) {
        self.container = container
        self.input = input
    }
}

public struct Gr4vyRadii: Codable {
    let container: String?
    let input: String?
    
    public init(container: String? = nil, input: String? = nil) {
        self.container = container
        self.input = input
    }
}

public struct Gr4vyShadows: Codable {
    let focusRing: String?
    
    public init(focusRing: String? = nil) {
        self.focusRing = focusRing
    }
}
