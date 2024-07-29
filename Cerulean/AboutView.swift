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
        
        Link(destination: URL(string: "https://www.transitchicago.com/developers/traintracker/")!, label: {
            UserInfo(title: "CTA Train Tracker API", subTitle: "Provides all train information", titleColor: Color(red: 0, green: 0.470588235, blue: 0.752941176), subTitleColor: Color(red: 0.82745098, green: 0.2666666667, blue: 0.470588235), imageName: "trainTracker", showChevron: true, dontClipImage: true)
        })
        
        Link(destination: URL(string: "https://data.cityofchicago.org/Transportation/CTA-System-Information-List-of-L-Stops/8pix-ypme/about_data")!, label: {
            UserInfo(title: "Chicago Data Portal", subTitle: "Provides station location information", titleColor: Color(red: 0.701960784, green: 0.866666667, blue: 0.949019608), subTitleColor: Color(red: 1, green: 0.3, blue: 0.3), imageName: "dataPortal", showChevron: true)
        })
    }
}
