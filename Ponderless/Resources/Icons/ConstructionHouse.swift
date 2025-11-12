//
//  ConstructionHouse.swift
//  Ponderless
//
//  Created by Pious Alpha on 12/11/2025.
//

import SwiftUI

struct ConstructionHouse: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.66667*width, y: 0.10417*height))
        path.addCurve(to: CGPoint(x: 0.52083*width, y: 0.25*height), control1: CGPoint(x: 0.66667*width, y: 0.18471*height), control2: CGPoint(x: 0.60137*width, y: 0.25*height))
        path.addLine(to: CGPoint(x: 0.52083*width, y: 0.33333*height))
        path.addCurve(to: CGPoint(x: 0.66667*width, y: 0.47917*height), control1: CGPoint(x: 0.60137*width, y: 0.33333*height), control2: CGPoint(x: 0.66667*width, y: 0.39862*height))
        path.addLine(to: CGPoint(x: 0.75*width, y: 0.47916*height))
        path.addCurve(to: CGPoint(x: 0.89583*width, y: 0.33333*height), control1: CGPoint(x: 0.75*width, y: 0.39862*height), control2: CGPoint(x: 0.81529*width, y: 0.33333*height))
        path.addLine(to: CGPoint(x: 0.89583*width, y: 0.25*height))
        path.addCurve(to: CGPoint(x: 0.75*width, y: 0.10417*height), control1: CGPoint(x: 0.81529*width, y: 0.25*height), control2: CGPoint(x: 0.75*width, y: 0.18471*height))
        path.addLine(to: CGPoint(x: 0.66667*width, y: 0.10417*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.12651*width, y: 0.11926*height))
        path.addLine(to: CGPoint(x: 0.12651*width, y: 0.4526*height))
        path.addLine(to: CGPoint(x: 0.45984*width, y: 0.4526*height))
        path.addLine(to: CGPoint(x: 0.45984*width, y: 0.11926*height))
        path.addLine(to: CGPoint(x: 0.12651*width, y: 0.11926*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.12651*width, y: 0.53593*height))
        path.addLine(to: CGPoint(x: 0.12651*width, y: 0.86926*height))
        path.addLine(to: CGPoint(x: 0.45984*width, y: 0.86926*height))
        path.addLine(to: CGPoint(x: 0.45984*width, y: 0.53593*height))
        path.addLine(to: CGPoint(x: 0.12651*width, y: 0.53593*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.54317*width, y: 0.53593*height))
        path.addLine(to: CGPoint(x: 0.54317*width, y: 0.86926*height))
        path.addLine(to: CGPoint(x: 0.8765*width, y: 0.86926*height))
        path.addLine(to: CGPoint(x: 0.8765*width, y: 0.53593*height))
        path.addLine(to: CGPoint(x: 0.54317*width, y: 0.53593*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.37651*width, y: 0.36926*height))
        path.addLine(to: CGPoint(x: 0.20984*width, y: 0.36926*height))
        path.addLine(to: CGPoint(x: 0.20984*width, y: 0.2026*height))
        path.addLine(to: CGPoint(x: 0.37651*width, y: 0.2026*height))
        path.addLine(to: CGPoint(x: 0.37651*width, y: 0.36926*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.79317*width, y: 0.78593*height))
        path.addLine(to: CGPoint(x: 0.6265*width, y: 0.78593*height))
        path.addLine(to: CGPoint(x: 0.6265*width, y: 0.61926*height))
        path.addLine(to: CGPoint(x: 0.79317*width, y: 0.61926*height))
        path.addLine(to: CGPoint(x: 0.79317*width, y: 0.78593*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.37651*width, y: 0.78593*height))
        path.addLine(to: CGPoint(x: 0.20984*width, y: 0.78593*height))
        path.addLine(to: CGPoint(x: 0.20984*width, y: 0.61926*height))
        path.addLine(to: CGPoint(x: 0.37651*width, y: 0.61926*height))
        path.addLine(to: CGPoint(x: 0.37651*width, y: 0.78593*height))
        path.closeSubpath()
        return path
    }
}
