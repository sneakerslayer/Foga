# Facial Analysis Model Training

This directory contains the Python training infrastructure for the Core ML facial analysis model.

## Overview

The model is a multi-modal neural network that combines:
- **Image features**: 224x224 RGB images processed through MobileNetV2 backbone
- **Metadata**: 6 demographic/contextual features (age, gender, BMI, ethnicity, skin tone, context)
- **ARKit features**: 10 3D measurements from ARKit face mesh

**Outputs**:
- Cervico-mental angle regression (degrees)
- Fat category classification (Low/Moderate/High)
- Confidence/uncertainty score (0.0-1.0)

## Requirements

- Python 3.8+
- PyTorch 1.12+ or TensorFlow 2.x
- Core ML Tools 7.0+
- NumPy, Pandas, Scikit-learn

Install dependencies:
```bash
pip install -r requirements.txt
```

## Model Architecture

- **Backbone**: MobileNetV2 (4M parameters, optimized for mobile)
- **Fusion**: Multi-modal concatenation + fully connected layers
- **Heads**: Separate heads for regression, classification, and confidence
- **Quantization**: 16-bit for mobile deployment (reduces model size by ~50%)

## Bias Mitigation

The training script includes:
- **Stratified sampling**: Ensures demographic balance in train/test splits
- **Fairness constraints**: Enforces maximum 5% accuracy gap between groups
- **Demographic metrics**: Tracks accuracy across all demographic combinations
- **Bias audits**: Regular validation across race, gender, age, skin tone groups

## Usage

### Basic Training

```bash
python train_facial_analysis_model.py \
    --data_dir ./data \
    --output_dir ./models \
    --epochs 50 \
    --batch_size 32 \
    --learning_rate 0.001 \
    --quantize
```

### Data Format

Expected data structure:
```
data/
├── images/
│   ├── image_001.png  # 224x224 RGB images
│   ├── image_002.png
│   └── ...
├── metadata.csv       # age, gender, bmi, ethnicity, skin_tone, context
├── arkit_features.csv # 10 ARKit measurement features
└── labels.csv         # true_angle, true_category
```

### Model Output

Trained model will be saved as:
- `FacialAnalysisModel.mlmodelc` - Core ML model bundle (for iOS deployment)
- `model_info.json` - Model architecture and metadata
- `training_history.json` - Training metrics and bias audit results

## Fairness Requirements

**Critical Criteria**:
- >95% accuracy across ALL demographic groups
- Maximum 5% gap between best and worst performing groups
- Stratified metrics for every demographic combination
- Quarterly fairness reports

## Scientific Validation

The model must be validated against:
- **Gold standard**: 3D stereophotogrammetry measurements
- **Clinical assessment**: Expert clinician ratings
- **Test-retest reliability**: ICC >0.90
- **Measurement accuracy**: ±5° for cervico-mental angle

## Notes

- This is a **template script** - full implementation requires:
  1. Data loading and preprocessing pipeline
  2. Complete training loop with bias monitoring
  3. Fairness constraint implementation
  4. Model validation across demographics
  5. Core ML conversion with proper input/output specifications

- Model file must be manually added to Xcode project after training
- On-device inference uses Vision framework for image preprocessing
- All processing happens on-device (privacy-preserving)

## References

- MobileNetV2: [Sandler et al., 2018](https://arxiv.org/abs/1801.04381)
- Farkas Anthropometric Standards: [Farkas, 1994](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2376964/)
- Bias Mitigation: [Mehrabi et al., 2021](https://arxiv.org/abs/1908.09635)


