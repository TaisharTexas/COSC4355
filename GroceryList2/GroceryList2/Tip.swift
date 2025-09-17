//
//  Tip.swift
//  GroceryList2
//
//  Created by Ioannis Pavlidis on 9/11/25.
//

import Foundation
import TipKit

struct ButtonTip:  Tip {
    var title: Text = Text("Essential Foods")
    var message: Text? = Text("Add some everyday items to the shopping list.")
    var image: Image? = Image(systemName: "info.circle")
    
}
