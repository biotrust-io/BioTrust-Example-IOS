import SwiftUI
import BiometricFaceValidator


struct ContentView: View {
    @State private var currentLauncher: BiometricValidationLauncher?
    @State private var currentCallback: DemoValidationCallback?
    
    var body: some View {
        VStack {
            Text("Exemplo de uso SDK BioTrust")
                .padding(.top,10)
                .padding(.bottom,20)
            
            Button("Iniciar validação liveness", action:{})
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            if let topVC = getRootViewController() {
                                startValidation(from: topVC, validationMode: .livenessOnly)
                            }
                        }
                )
                .padding(10)
            
            Button("Iniciar validação liveness + documento", action:{})
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            if let topVC = getRootViewController() {
                                startValidation(from: topVC, validationMode: .livenessWithDocument)
                            }
                        }
                )
                .padding(10)
            
            Button("FaceMatch", action:{})
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            if let topVC = getRootViewController() {
                                startValidation(from: topVC, validationMode: .faceMatch(requireChallenges: false))
                            }
                        }
                )
                .padding(10)
            
            
            Button("FaceMatch Exact", action:{})
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            if let topVC = getRootViewController() {
                                startValidation(from: topVC, validationMode: .faceMatchExact(documentNumber: "00000000000", requireChallenges: false))
                            }
                        }
                )
                .padding(10)
        }
        .padding()
    }
    
    private func startValidation(from viewController: UIViewController, validationMode: ValidationMode) {
        let builder = FaceBiometricConfig.Builder()
            .setUuid("INSISRA SEU UUID AQUI")
            .setApiUrl("https://api.biotrust.io")
            .setChallengeCount(3)
            .setValidationMode(validationMode)
            .setLocale("en-US")

        if(validationMode == .livenessWithDocument){
        
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let date = formatter.date(from: "1999-01-29")!
            let documentInfo = DocumentInfo(cpf: "00000000000", birthDate: date)
            let isValidResult = documentInfo.isValid()
            if(isValidResult){
                _ = builder.setDocumentInfo(documentInfo)
            }
            
        }
        

        do {
            let config = try builder.build()
            let callback = DemoValidationCallback()
            self.currentCallback = callback
            
            BiometricFaceValidatorFramework.initializeFramework()
            
            let launcher = BiometricValidationLauncher(
                viewController: viewController,
                callback: callback,
                config: config
            )
            
            self.currentLauncher = launcher
            launcher.launch(from: viewController)
        } catch {
            return
        }
    }
}

private func getRootViewController() -> UIViewController? {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = scene.windows.first(where: { $0.isKeyWindow }),
          let rootVC = window.rootViewController else {
        return nil
    }
    var topVC = rootVC
    while let presented = topVC.presentedViewController {
        topVC = presented
    }
    return topVC
}

class DemoValidationCallback: BiometricValidationLauncher.ValidationResultCallback {
    
    
    func onFaceMatchComplete(result : ValidationResult){
        print("==FaceMatchComplete==")
        
        print("isSuccess: \(result.getIsSuccess())")
        print("Message: \(result.getMessage())")
        print("Match: \(result.getMatch() ?? false)")
        print("Match Confidence: \(String(describing: result.getMatchConfidence()))")
        print("Liveness Confidence: \(result.getLivenessConfidence())")
        print("Image size: \(result.getFaceImage()?.size ?? CGSize.zero)")
        
        print("Person ID: \(String(describing: result.getMatchedPersonId()))")
        print("Person Document: \(String(describing: result.getPersonDocument()))")
        print("Person Name: \(String(describing: result.getPersonName()))")
        
        
        
    }
    
    func onValidationSuccess(message: String, livenessConfidence: Float, faceImage: UIImage?) {
        
        print("==ValidationSuccess==")
        print("Message: \(message)")
        print("Liveness confidence: \(livenessConfidence)")
        print("Image size: \(faceImage?.size ?? CGSize.zero)")
        
    }
    
    func onDocumentValidationComplete(result: ValidationResult) {
        
        print("==onDocumentValidationComplete==")
        print("Message: \(result.getMessage())")
        print("Liveness confidence: \(result.getLivenessConfidence())")
        print("Image size: \(result.getFaceImage()?.size ?? CGSize.zero)")
        
        print("Document: \(result.getDocumentResult()?.getCpf() ?? String())")
        print("Full name: \(result.getDocumentResult()?.getFullName() ?? String())")
        print("Birth date: \(result.getDocumentResult()?.getBirthDate() ?? String())")
        
        print("Is Available: \(result.getDocumentResult()?.getIsAvailable() ?? false)")
        print("Similarity: \(result.getDocumentResult()?.getSimilarityPercentage() ?? 0)")
        print("Probability: \(result.getDocumentResult()?.getProbability() ?? String())")
                
    }
    
    func onValidationFailed(errorMessage: String) {
        
        print("==onValidationFailed==")
        print("Error message: \(errorMessage)")
        
    }
    
    func onValidationError(errorMessage: String) {
        
        print("==onValidationError==")
        print("Failure message: \(errorMessage)")
        
    }
}

#Preview {
    ContentView()
}
