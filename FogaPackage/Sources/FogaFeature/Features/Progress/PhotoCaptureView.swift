import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Photo capture view for progress photos
@available(iOS 15.0, *)
public struct PhotoCaptureView: View {
    @ObservedObject var viewModel: ProgressViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var notes: String = ""
    @State private var showMeasurementPrompt = false
    
    public init(viewModel: ProgressViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppSpacing.large) {
                    // Photo preview or placeholder
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 400)
                            .cornerRadius(AppCornerRadius.medium)
                            .onTapGesture {
                                showImagePicker = true
                            }
                    } else {
                        PhotoPlaceholderView {
                            showImagePicker = true
                        }
                    }
                    
                    // Capture options
                    VStack(spacing: AppSpacing.medium) {
                        PrimaryButton(title: "Take Photo", style: .primary) {
                            showCamera = true
                        }
                        
                        PrimaryButton(title: "Choose from Library", style: .outline) {
                            showImagePicker = true
                        }
                    }
                    
                    // Notes section
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        Text("Add Notes (Optional)")
                            .font(AppTypography.headline)
                            .foregroundColor(AppColors.primaryText)
                        
                        TextField("How are you feeling? Any changes?", text: $notes, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding(AppSpacing.medium)
                            .background(AppColors.cardBackground)
                            .cornerRadius(AppCornerRadius.medium)
                            .lineLimit(3...6)
                    }
                    
                    // Save button
                    if selectedImage != nil {
                        PrimaryButton(title: "Save Progress Photo") {
                            saveProgressPhoto()
                        }
                    }
                }
                .padding(AppSpacing.medium)
            }
            .background(AppColors.background)
            .navigationTitle("Capture Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $selectedImage, sourceType: .camera)
            }
            .alert("Take Face Measurement?", isPresented: $showMeasurementPrompt) {
                Button("Skip") {
                    saveProgressPhoto(includeMeasurement: false)
                }
                Button("Measure Now") {
                    // Navigate to measurement view
                    saveProgressPhoto(includeMeasurement: true)
                }
            } message: {
                Text("Would you like to take a face measurement along with this photo? This helps track your progress more accurately.")
            }
        }
    }
    
    private func saveProgressPhoto(includeMeasurement: Bool = false) {
        guard let image = selectedImage else { return }
        
        #if canImport(UIKit)
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        // Create progress entry
        let progress = Progress(
            photoData: imageData,
            measurements: FaceMeasurement(), // Empty measurement for now
            date: Date(),
            notes: notes.isEmpty ? nil : notes
        )
        
        // Save to viewModel
        viewModel.addProgress(progress)
        
        // If measurement requested, show prompt
        if includeMeasurement {
            // In production, would navigate to measurement view
            // For now, just save the photo
        }
        
        dismiss()
        #endif
    }
}

/// Photo placeholder view
@available(iOS 15.0, *)
struct PhotoPlaceholderView: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .fill(AppColors.cardBackground)
                    .frame(height: 400)
                
                VStack(spacing: AppSpacing.medium) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.primary)
                    
                    Text("Tap to add photo")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("Capture your progress")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#if canImport(UIKit)
/// Image picker wrapper
@available(iOS 15.0, *)
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
#endif

