//
//  TeamView.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/9/25.
//

import SwiftUI

/**
 Need to redefine button style to use orange
 
 Add ranking points calc to stats. distingush between small and large triangle scores 
 
 Need to change structure where each session can be expanded to show the list of matches
    the entire session can be included or not
    individual matches can be included or not
 Add edit mode where sessions and/or matches can be deleted from memory (warn user)
 */

struct TeamView: View {
    
    @State private var viewMode: DataViewMode = .report
    
    
    enum DataViewMode {
        case analysis, report
    }
    
    var body: some View {
        
        Picker("View Mode", selection: $viewMode) {
            Text("Report").tag(DataViewMode.report)
            Text("Analysis").tag(DataViewMode.analysis)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        
        Group{
            switch viewMode {
            case .analysis:
                TeamAnalysisView_Self()
            case .report:
                TeamReportView()
                
            }
        }//: end view toggle
        Spacer()
        
    }
}

#Preview {
    TeamView()
}
