//
//  TeamView.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/9/25.
//

import SwiftUI

struct TeamView: View {
    
    @State private var viewMode: DataViewMode = .report
    @ObservedObject var storageManager: MatchStorageManager
    
    
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
                TeamAnalysisView_Self(storageManager: storageManager)
            case .report:
                TeamReportView(storageManager: storageManager)
                
            }
        }//: end view toggle
        Spacer()
        
    }
}

#Preview {
    TeamView(storageManager: MatchStorageManager())
}
