//
//  AboutWindow.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/25/24.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        Link(destination: URL(string: "https://twitter.com/whitetailani")!, label: {
            UserInfo(title: "WhitetailAni 🏳️‍⚧️", subTitle: "App developer", titleColor: Color(red: 0.129411765, green: 0.784313725, blue: 0.858823529), subTitleColor: Color(red: 0.560784314, green: 0.560784314, blue: 0.560784314), imageName: "cerulean", showChevron: true)
        })
        
        Link(destination: URL(string: "https://fontstruct.com/fontstructors/681805/j4s13")!, label: {
            UserInfo(title: "evie atarax", subTitle: "CTA speedlines and Metra logos", titleColor: Color(red: 0.69803921568, green: 0.81960784313, blue: 0.51764705882), subTitleColor: Color(red: 0.28235294117, green: 0.58431372549, blue: 0.31764705882), imageName: "evieAtarax", showChevron: true)
        })
        
        Link(destination: URL(string: "https://www.transitchicago.com/developers/traintracker/")!, label: {
            UserInfo(title: "CTA Train Tracker API", subTitle: "Provides CTA train information", titleColor: Color(red: 0, green: 0.470588235, blue: 0.752941176), subTitleColor: Color(red: 0.82745098, green: 0.2666666667, blue: 0.470588235), imageName: "trainTracker", showChevron: true, dontClipImage: true)
        })
        
        Link(destination: URL(string: "https://data.cityofchicago.org/Transportation/CTA-System-Information-List-of-L-Stops/8pix-ypme/about_data")!, label: {
            UserInfo(title: "Chicago Data Portal", subTitle: "Provides station location information", titleColor: Color(red: 0.701960784, green: 0.866666667, blue: 0.949019608), subTitleColor: Color(red: 1, green: 0.3, blue: 0.3), imageName: "dataPortal", showChevron: true)
        })
        
        Link(destination: URL(string: "https://metra.com/metra-gtfs-api")!, label: {
            UserInfo(title: "Metra GTFS API", subTitle: "Provides Metra train information", titleColor: Color(red: 0.00392156862, green: 0.3294117647, blue: 0.6431372549), subTitleColor: Color(red: 0.87058823529, green: 0.25882352941, blue: 0.02352941176), imageName: "metraM", showChevron: true, dontClipImage: true)
        })
    }
}
