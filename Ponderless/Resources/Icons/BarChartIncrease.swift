//
//  BarChartIncrease.swift
//  Ponderless
//
//  Created by Pious Alpha on 12/11/2025.
//

import SwiftUI

struct BarChartIncrease: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.875*width, y: 0.166666666667*height))
        path.addCurve(to: CGPoint(x: 0.916666666667*width, y: 0.208333333333*height), control1: CGPoint(x: 0.8980125*width, y: 0.166666666667*height), control2: CGPoint(x: 0.916666666667*width, y: 0.185321666667*height))
        path.addLine(to: CGPoint(x: 0.916666666667*width, y: 0.875*height))
        path.addCurve(to: CGPoint(x: 0.875*width, y: 0.916666666667*height), control1: CGPoint(x: 0.916666666667*width, y: 0.8980125*height), control2: CGPoint(x: 0.8980125*width, y: 0.916666666667*height))
        path.addLine(to: CGPoint(x: 0.125*width, y: 0.916666666667*height))
        path.addCurve(to: CGPoint(x: 0.083333333333*width, y: 0.875*height), control1: CGPoint(x: 0.101988333333*width, y: 0.916666666667*height), control2: CGPoint(x: 0.083333333333*width, y: 0.8980125*height))
        path.addLine(to: CGPoint(x: 0.083333333333*width, y: 0.583333333333*height))
        path.addCurve(to: CGPoint(x: 0.125*width, y: 0.541666666667*height), control1: CGPoint(x: 0.083333333333*width, y: 0.560320833333*height), control2: CGPoint(x: 0.101988333333*width, y: 0.541666666667*height))
        path.addLine(to: CGPoint(x: 0.333333333333*width, y: 0.541666666667*height))
        path.addLine(to: CGPoint(x: 0.333333333333*width, y: 0.458333333333*height))
        path.addCurve(to: CGPoint(x: 0.375*width, y: 0.416666666667*height), control1: CGPoint(x: 0.333333333333*width, y: 0.435320833333*height), control2: CGPoint(x: 0.351988333333*width, y: 0.416666666667*height))
        path.addLine(to: CGPoint(x: 0.583333333333*width, y: 0.416666666667*height))
        path.addLine(to: CGPoint(x: 0.583333333333*width, y: 0.208333333333*height))
        path.addCurve(to: CGPoint(x: 0.595541666667*width, y: 0.17887375*height), control1: CGPoint(x: 0.583333333333*width, y: 0.1972825*height), control2: CGPoint(x: 0.587725*width, y: 0.186687916667*height))
        path.addCurve(to: CGPoint(x: 0.625*width, y: 0.166666666667*height), control1: CGPoint(x: 0.603354166667*width, y: 0.171059583333*height), control2: CGPoint(x: 0.61395*width, y: 0.166666666667*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.166666666667*width, y: 0.833333333333*height))
        path.addLine(to: CGPoint(x: 0.333333333333*width, y: 0.833333333333*height))
        path.addLine(to: CGPoint(x: 0.333333333333*width, y: 0.625*height))
        path.addLine(to: CGPoint(x: 0.166666666667*width, y: 0.625*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.416666666667*width, y: 0.833333333333*height))
        path.addLine(to: CGPoint(x: 0.583333333333*width, y: 0.833333333333*height))
        path.addLine(to: CGPoint(x: 0.583333333333*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.416666666667*width, y: 0.5*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.666666666667*width, y: 0.833333333333*height))
        path.addLine(to: CGPoint(x: 0.833333333333*width, y: 0.833333333333*height))
        path.addLine(to: CGPoint(x: 0.833333333333*width, y: 0.25*height))
        path.addLine(to: CGPoint(x: 0.666666666667*width, y: 0.25*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.416666666667*width, y: 0.083333333333*height))
        path.addCurve(to: CGPoint(x: 0.458333333333*width, y: 0.125*height), control1: CGPoint(x: 0.439679166667*width, y: 0.083333333333*height), control2: CGPoint(x: 0.458333333333*width, y: 0.101988333333*height))
        path.addLine(to: CGPoint(x: 0.458333333333*width, y: 0.3125*height))
        path.addLine(to: CGPoint(x: 0.375*width, y: 0.3125*height))
        path.addLine(to: CGPoint(x: 0.375*width, y: 0.225585833333*height))
        path.addLine(to: CGPoint(x: 0.19612625*width, y: 0.404459583333*height))
        path.addLine(to: CGPoint(x: 0.137207083333*width, y: 0.345540416667*height))
        path.addLine(to: CGPoint(x: 0.316080833333*width, y: 0.166666666667*height))
        path.addLine(to: CGPoint(x: 0.229166666667*width, y: 0.166666666667*height))
        path.addLine(to: CGPoint(x: 0.229166666667*width, y: 0.083333333333*height))
        path.closeSubpath()
        return path
    }
}
