//
//  Tip.swift
//  HW2_packingList
//
//  Created by Andrew Lee on 9/16/25.
//

import Foundation
import TipKit

struct ButtonTip:  Tip {
    var title: Text = Text("Essential Items")
    var message: Text? = Text("Add some travel essentials to your packing list.")
    var image: Image? = Image(systemName: "info.circle")
    
}
