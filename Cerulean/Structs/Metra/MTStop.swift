//
//  MTStop.swift
//  Cerulean
//
//  Created by WhitetailAni on 12/3/24.
//

import Foundation

struct MTStop {
    var apiName: String
    var position: Int
    var arrivalTime: Date
    var departureTime: Date
    //var station: MTStation
    
    static func purifyApiName(name: String) -> String {
        switch name {
            
            //up-w
        case "ELBURN":
            return "Elburn"
        case "LAFOX":
            return "La Fox"
        case "GENEVA":
            return "Geneva"
        case "WCHICAGO":
            return "West Chicago"
        case "WINFIELD":
            return "Winfield"
        case "WHEATON":
            return "Wheaton"
        case "COLLEGEAVE":
            return "College Avenue"
        case "GLENELLYN":
            return "Glen Ellyn"
        case "LOMBARD":
            return "Lombard"
        case "VILLAPARK":
            return "Villa Park"
        case "ELMHURST":
            return "Elmhurst"
        case "BERKELEY":
            return "Berkeley"
        case "BELLWOOD":
            return "Bellwood"
        case "MELROSEPK":
            return "Melrose Park"
        case "MAYWOOD":
            return "Maywood"
        case "RIVRFOREST":
            return "River Forest"
        case "OAKPARK":
            return "Oak Park"
        case "KEDZIE":
            return "Kedzie"
            
            //hc
        case "LOCKPORT":
            return "Lockport"
        case "ROMEOVILLE":
            return "Romeoville"
        case "LEMONT":
            return "Lemont"
        case "WILLOWSPRN":
            return "Willow Springs"
        case "SUMMIT":
            return "Summit"
            
            //ri
        case "NEWLENOX":
            return "New Lenox"
        case "MOKENA":
            return "Mokena"
        case "HICKORYCRK":
            return "Hickory Creek/Mokena"
        case "TINLEY80TH":
            return "80th Avenue/Tinley Park"
        case "TINLEYPARK":
            return "Tinley Park"
        case "OAKFOREST":
            return "Oak Forest"
        case "MIDLOTHIAN":
            return "Midlothian"
        case "ROBBINS":
            return "Robbins"
        case "VERMONT":
            return "Blue Island/Vermont Street"
            //beverly branch
        case "PRAIRIEST":
            return "Prairie Street"
        case "123RD-BEV":
            return "123rd Street/Blue Island"
        case "119TH-BEV":
            return "119th Street/Blue Island"
        case "115TH-BEV":
            return "115th Street/Morgan Park"
        case "111TH-BEV":
            return "111th Street/Morgan Park"
        case "107TH-BEV":
            return "107th Street/Beverly Hills"
        case "103RD-BEV":
            return "103rd Street/Beverly Hills"
        case "99TH-BEV":
            return "99th Street/Beverly Hills"
        case "95TH-BEV":
            return "95th Street/Beverly Hills"
        case "91ST-BEV":
            return "91st Street/Beverly Hills"
        case "BRAINERD":
            return "Brainerd"
            //mainline
        case "WASHHGTS":
            return "103rd Street/Washington Heights"
        case "LONGWOOD":
            return "95th Street/Longwood"
        
        case "GRESHAM":
            return "Gresham"
        case "35TH":
            return """
35th Street/"Lou" Jones
"""
        case "LSS":
            return "LaSalle Street Station"
            
            //me
            
            //mainline
        case "UNIVERSITY":
            return "University Park"
        case "RICHTON":
            return "Richton Park"
        case "MATTESON":
            return "Matteson"
        case "211TH-UP":
            return "211th Street/Lincoln Highway"
        case "OLYMPIA":
            return "Olympia"
        case "FLOSSMOOR":
            return "Flossmoor"
        case "HOMEWOOD":
            return "Homewood"
        case "CALUMET":
            return "Calumet"
        case "HAZELCREST":
            return "Hazel Crest"
        case "HARVEY":
            return "Harvey"
        case "147TH-UP":
            return "147th Street/Sibley"
        case "IVANHOE":
            return "Ivanhoe"
        case "RIVERDALE":
            return "Riverdale"
            //blue island branch
        case "BLUEISLAND":
            return "Blue Island"
        case "BURROAK":
            return "Burr Oak"
        case "ASHLAND":
            return "Ashland Avenue"
        case "RACINE":
            return "Racine Avenue"
        case "WPULLMAN":
            return "West Pullman"
        case "STEWARTRID":
            return "Stewart Ridge"
        case "STATEST":
            return "State Street"
            //mainline
        case "KENSINGTN":
            return "115th Street/Kensington"
        case "111TH-UP":
            return "111th Street/Pullman"
        case "107TH-UP":
            return "107th Street"
        case "103RD-UP": #warning("103rd maybe inaccurate")
            return "103rd Street"
        case "95TH-UP":
            return "95th Street"
        case "91ST-UP":
            return "91st Street"
        case "87TH-UP":
            return "87th Street"
        case "83RD-UP":
            return "83rd Street"
        case "79TH-UP":
            return "79th Street"
        case "75TH-UP":
            return "75th Street"
            //south chicago branch
        case "93RD-SC":
            return "93rd Street/South Chicago"
        case "87TH-SC":
            return "87th Street/South Chicago"
        case "83RD-SC":
            return "83rd Street"
        case "79TH-SC":
            return "79th Street/Cheltenham"
        case "WINDSORPK":
            return "Windsor Park"
        case "SOUTHSHORE":
            return "South Shore"
        case "BRYNMAWR":
            return "Bryn Mawr"
        case "STONYISLND":
            return "Stony Island"
            //mainline
        case "63RD-UP":
            return "63rd Street"
        case "59TH-UP":
            return "59th Street"
        case "55-56-57TH":
            return "55th-56th-57th Street"
        case "51ST-53RD":
            return "51st/53rd Street/Hyde Park"
        case "47TH-UP":
            return "47th Street/Kenwood"
        case "27TH-UP":
            return "27th Street"
        case "MCCORMICK":
            return "McCormick Place"
        case "18TH-UP":
            return "18th Street"
        case "MUSEUM":
            return "Museum Campus/11th Street"
        case "VANBUREN":
            return "Van Buren Street"
        case "MILLENNIUM":
            return "Millennium Station"
            
            //md-w
        case "BIGTIMBER":
            return "Big Timber Road"
        case "ELGIN":
            return "Elgin"
        case "NATIONALS":
            return "National Street"
        case "BARTLETT":
            return "Bartlett"
        case "HANOVERP":
            return "Hanover Park"
        case "SCHAUM":
            return "Schaumburg"
        case "ROSELLE":
            return "Roselle"
        case "MEDINAH":
            return "Medinah"
        case "ITASCA":
            return "Itasca"
        case "WOODDALE":
            return "Wood Dale"
        case "BENSENVIL":
            return "Bensenville"
        case "MANNHEIM":
            return "Mannheim"
        case "FRANKLIN":
            return "Franklin Park"
        case "RIVERGROVE":
            return "River Grove"
        case "ELMWOODPK":
            return "Elmwood Park"
        case "MONTCLARE":
            return "Mont Clare"
        case "MARS":
            return "Mars"
        case "GALEWOOD":
            return "Galewood"
        case "HANSONPK":
            return "Hanson Park"
        case "GRAND-CIC":
            return "Grand/Cicero"
            
            //md-n
        case "FOXLAKE":
            return "Fox Lake"
        case "INGLESIDE":
            return "Ingleside"
        case "LONGLAKE":
            return "Long Lake"
        case "ROUNDLAKE":
            return "Round Lake"
        case "GRAYSLAKE":
            return "Grayslake"
        case "PRAIRIEXNG":
            return "Prairie Crossing/Libertyville"
        case "LIBERTYVIL":
            return "Libertyville"
        case "LAKEFRST":
            return "Lake Forest"
        case "DEERFIELD":
            return "Deerfield"
        case "LAKECOOKRD":
            return "Lake Cook Road"
        case "NBROOK":
            return "Northbrook"
        case "NGLENVIEW":
            return "The Glen/North Glenview"
        case "GLENVIEW":
            return "Glenview"
        case "GOLF":
            return "Golf"
        case "MORTONGRV":
            return "Morton Grove"
        case "EDGEBROOK":
            return "Edgebrook"
        case "FORESTGLEN":
            return "Forest Glen"
        case "MAYFAIR":
            return "Mayfair"
        case "GRAYLAND":
            return "Grayland"
        case "HEALY":
            return "Healy"
            
            //up-nw
        case "HARVARD":
            return "Harvard"
        case "WOODSTOCK":
            return "Woodstock"
        case "CRYSTAL":
            return "Crystal Lake"
        case "MCHENRY":
            return "McHenry"
        case "PINGREE":
            return "Pingree Road"
        case "CARY":
            return "Cary"
        case "FOXRG":
            return "Fox River Grove"
        case "BARRINGTON":
            return "Barrington"
        case "PALATINE":
            return "Palatine"
        case "ARLINGTNPK":
            return "Arlington Park"
        case "ARLINGTNHT":
            return "Arlington Heights"
        case "MTPROSPECT":
            return "Mount Prospect"
        case "CUMBERLAND":
            return "Cumberland"
        case "DESPLAINES":
            return "Des Plaines"
        case "DEEROAD":
            return "Dee Road"
        case "PARKRIDGE":
            return "Park Ridge"
        case "EDISONPK":
            return "Edison Park"
        case "NORWOODP":
            return "Norwood Park"
        case "GLADSTONEP":
            return "Gladstone Park"
        case "JEFFERSONP":
            return "Jefferson Park"
        case "IRVINGPK":
            return "Irving Park"
        
            //bnsf
        case "AURORA":
            return "Aurora"
        case "ROUTE59":
            return "Route 59"
        case "NAPERVILLE":
            return "Naperville"
        case "LISLE":
            return "Lisle"
        case "BELMONT":
            return "Belmont"
        case "MAINST-DG":
            return "Downers Grove/Main Street"
        case "FAIRVIEWDG":
            return "Fairview Avenue"
        case "WESTMONT":
            return "Westmont"
        case "CLARNDNHIL":
            return "Clarendon Hills"
        case "WHINSDALE":
            return "West Hinsdale"
        case "HINSDALE":
            return "Hinsdale"
        case "HIGHLANDS":
            return "Highlands"
        case "WESTSPRING":
            return "Western Springs"
        case "STONEAVE":
            return "Stone Avenue"
        case "LAGRANGE":
            return "LaGrange Road"
        case "CONGRESSPK":
            return "Congress Park"
        case "BROOKFIELD":
            return "Brookfield"
        case "HOLLYWOOD":
            return "Hollywood/Zoo Stop"
        case "RIVERSIDE":
            return "Riverside"
        case "HARLEM":
            return "Harlem Avenue"
        case "BERWYN":
            return "Berwyn"
        case "LAVERGNE":
            return "LaVergne"
        case "CICERO":
            return "Cicero"
        case "BNWESTERN":
            return "Western Avenue"
        case "HALSTED":
            return "Halsted Street"
            
            //up-n
        case "KENOSHA":
            return "Kenosha"
        case "WINTHROP":
            return "Winthrop Harbor"
        case "ZION":
            return "Zion"
        case "WAUKEGAN":
            return "Waukegan"
        case "NCHICAGO":
            return "North Chicago"
        case "GRTLAKES":
            return "Great Lakes"
        case "LAKEBLUFF":
            return "Lake Bluff"
        case "LKFOREST":
            return "Lake Forest"
        case "FTSHERIDAN":
            return "Fort Sheridan"
        case "HIGHWOOD":
            return "Highwood"
        case "HIGHLANDPK":
            return "Highland Park"
        case "RAVINIA":
            return "Ravinia"
        #warning("Missing Ravinia Park")
        case "BRAESIDE":
            return "Braeside"
        case "GLENCOE":
            return "Glencoe"
        case "HUBARDWOOD":
            return "Hubbard Woods"
        case "WINNETKA":
            return "Winnetka"
        case "INDIANHILL":
            return "Indian Hill"
        case "KENILWORTH":
            return "Kenilworth"
        case "WILMETTE":
            return "Wilmette"
        case "CENTRALST":
            return "Central Street/Evanston"
        case "EVANSTON":
            return "Davis Street/Evanston"
        case "MAINST":
            return "Main Street/Evanston"
        case "ROGERPK":
            return "Rogers Park"
        case "PETERSON":
            return "Peterson/Ridge"
        case "RAVENSWOOD":
            return "Ravenswood"
            
            
            //sws
        case "MANHATTAN":
            return "Manhattan"
        case "LARAWAY":
            return "Laraway Road"
        case "179TH-SWS":
            return "179th Street/Orland Park"
        case "153RD-SWS":
            return "153rd Street/Orland Park"
        case "143RD-SWS":
            return "143rd Street/Orland Park"
        case "PALOSPARK":
            return "Palos Park"
        case "PALOSHTS":
            return "Palos Heights"
        case "WORTH":
            return "Worth"
        case "CHICRIDGE":
            return "Chicago Ridge"
        case "OAKLAWN":
            return "Oak Lawn"
        case "ASHBURN":
            return "Ashburn"
        case "WRIGHTWOOD":
            return "Wrightwood"
            
            //ncs
        case "ANTIOCH":
            return "Antioch"
        case "LAKEVILLA":
            return "Lake Villa"
        case "ROUNDLKBCH":
            return "Round Lake Beach"
        case "NCSGRAYSLK":
            return "Washington Street/Grayslake"
        case "PRAIRCROSS":
            return "Prairie Crossing/Libertyville"
        case "MUNDELEIN":
            return "Mundelein"
        case "VERNON":
            return "Vernon Hills"
        case "PRAIRIEVW":
            return "Prairie View"
        case "BUFFGROVE":
            return "Buffalo Grove"
        case "WHEELING":
            return "Wheeling"
        case "PROSPECTHG":
            return "Prospect Heights"
        case "OHARE":
            return "O'Hare Transfer"
        case "ROSEMONT":
            return "Rosemont"
        case "SCHILLERPK":
            return "Schiller Park"
        case "FRANKLINPK":
            return "Belmont Avenue/Franklin Park"
            
            //common
        case "JOLIET":
            return "Joliet"
            
        case "CLYBOURN":
            return "Clybourn"
        case "OTC":
            return "Ogilvie Transportation Center"
            
        case "WESTERNAVE":
            return "Western Avenue"
        case "CUS":
            return "Chicago Union Station"
        default:
            return name
        }
    }
}
