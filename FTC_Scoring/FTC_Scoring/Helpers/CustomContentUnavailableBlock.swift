

import SwiftUI

struct CustomContentUnavailableView: View {
    var icon: String
    var title: String
    var description: String
    
    var body: some View {
        // Apple's built-in empty state layout
        ContentUnavailableView {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 96)
            
            Text(title)
                .font(.title)
        } description: {
            Text(description)
        }
        .foregroundStyle(Color("ftc_orange"))
    }
}

//#Preview {
//    CustomContentUnavailableView(icon: "tree.circle", title: "no parks", description: "seems like theres nothing here...maybe check outside and touch some grass?")
//}
