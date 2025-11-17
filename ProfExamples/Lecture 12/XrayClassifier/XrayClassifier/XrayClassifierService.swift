//
//  XrayClassifierService.swift
//  XrayClassifier
//
//  Created by Ioannis Pavlidis on 11/12/25.
//

//  UIKit: for UIImage.
// Vision: for VNCoreMLModel, VNCoreMLRequest, VNClassificationObservation.
// CoreML: for the underlying ML model.
// final class means this service can’t be subclassed (a small safety/performance win).

import UIKit
import Vision
import CoreML

// This class is used by ContentView to do the actual classification.
final class XrayClassifierService {
    enum ClassifierError: LocalizedError {
        case modelLoadFailed
        case requestFailed

        var errorDescription: String? {
            switch self {
            case .modelLoadFailed:
                return "Could not load Core ML model."
            case .requestFailed:
                return "Vision request failed."
            }
        }
    }

    private let vnModel: VNCoreMLModel?

    // 1. Create an MLModelConfiguration.
    // 2. config.computeUnits = .cpuOnly. Forces Core ML to run on the CPU only.This avoids GPU/ANe issues on the simulator, which often cause “Could not create inference context” errors.
    // 3. XrayClassifier1(configuration: config). This is the auto-generated class from your .mlmodel file. try is used because loading the compiled model can fail.
    // 4. Wrap it in a Vision model:
    init() {
        do {
            // 👉 Force CPU-only to avoid simulator / GPU issues
            let config = MLModelConfiguration()
            config.computeUnits = .cpuOnly

            // Use your actual model class name here (e.g. xrayClassifier)
            let coreMLModel = try XrayClassifier1(configuration: config)
            self.vnModel = try VNCoreMLModel(for: coreMLModel.model)
        } catch {
            self.vnModel = nil
            print("❌ Error loading Core ML model:", error)
        }
    }

    func classify(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let vnModel else {
            completion(.failure(ClassifierError.modelLoadFailed))
            return
        }

        guard let cgImage = image.cgImage else {
            completion(.failure(ClassifierError.requestFailed))
            return
        }

        let request = VNCoreMLRequest(model: vnModel) { request, error in
            if let error {
                print("🔴 Vision/CoreML error:", error)
                completion(.failure(error))
                return
            }

            // VNCoreMLRequest tells Vision: “Run this Core ML model on the image and give me classification results.”
            // The closure (request, error) is called after the model runs. Inside the closure:
                //  1. If Vision/CoreML reports an error, log it and call completion(.failure(error)).
                //  2. Otherwise, try to cast request.results to [VNClassificationObservation].
                // 3. Take results.first as the top prediction (best).
                // 4. Build a readable string:
            guard
                let results = request.results as? [VNClassificationObservation],
                let best = results.first
            else {
                completion(.failure(ClassifierError.requestFailed))
                return
            }

            let label = "\(best.identifier) (\(String(format: "%.1f", best.confidence * 100))%)"
            completion(.success(label))
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("🔴 Handler perform error:", error)
                completion(.failure(error))
            }
        }
    }
}
