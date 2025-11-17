# Training Data Preparation Guide

## Overview

This guide explains how to prepare training data for the facial analysis model. The model requires multi-modal data: images, metadata, ARKit features, and ground truth labels.

## Data Requirements

### Minimum Dataset Size
- **Recommended**: 5,000+ samples for robust training
- **Minimum**: 1,000 samples (will have limited accuracy)
- **Ideal**: 10,000+ samples with demographic diversity

### Demographic Distribution
To meet fairness requirements (>95% accuracy across all groups), ensure balanced representation:
- **Race/Ethnicity**: At least 500 samples per group (African American, Asian, Caucasian, Hispanic, etc.)
- **Gender**: Balanced male/female representation
- **Age**: 18-80 years, distributed across age groups
- **Skin Tone**: Fitzpatrick scale 1-6, balanced distribution

## Data Structure

```
data/
├── images/
│   ├── image_001.png  # 224x224 RGB PNG files
│   ├── image_002.png
│   └── ...
├── metadata.csv       # Demographic and contextual data
├── arkit_features.csv # ARKit 3D measurements
└── labels.csv         # Ground truth labels
```

## CSV Schemas

### metadata.csv
Required columns:
```csv
image_id,age,gender,bmi,ethnicity,skin_tone,context
image_001,28,female,22.5,caucasian,3,baseline
image_002,35,male,26.8,asian,4,progress
...
```

**Column Definitions**:
- `image_id`: Filename without extension (e.g., "image_001")
- `age`: Integer, 18-80
- `gender`: "male", "female", or "other"
- `bmi`: Float, 15-40
- `ethnicity`: "african_american", "asian", "caucasian", "hispanic", "middle_eastern", "native_american", "pacific_islander", "mixed", "other", or "prefer_not_to_say"
- `skin_tone`: Integer, 1-6 (Fitzpatrick scale)
- `context`: "baseline", "progress", or "followup"

### arkit_features.csv
Required columns:
```csv
image_id,cervico_mental_angle,submental_cervical_length,jaw_definition_index,neck_circumference,facial_adiposity_index,face_width,face_height,head_pose_pitch,head_pose_yaw,head_pose_roll
image_001,98.5,42.3,0.65,380.2,35.7,145.8,210.3,2.1,-1.5,0.8
image_002,105.2,38.9,0.72,365.4,28.3,142.1,205.7,-1.2,0.9,-0.3
...
```

**Column Definitions**:
- `image_id`: Matches metadata.csv
- `cervico_mental_angle`: Degrees, 70-150° range
- `submental_cervical_length`: Millimeters, 15-60mm range
- `jaw_definition_index`: Dimensionless ratio, 0-1
- `neck_circumference`: Millimeters, 300-500mm range
- `facial_adiposity_index`: Composite score, 0-100
- `face_width`: Millimeters (bigonial breadth), 120-180mm
- `face_height`: Millimeters (nasion-gnathion), 180-250mm
- `head_pose_pitch`: Degrees, ±30° range
- `head_pose_yaw`: Degrees, ±30° range
- `head_pose_roll`: Degrees, ±30° range

### labels.csv
Required columns:
```csv
image_id,true_angle,true_category
image_001,98.5,moderate
image_002,105.2,low
...
```

**Column Definitions**:
- `image_id`: Matches other CSVs
- `true_angle`: Ground truth cervico-mental angle (degrees), 70-150°
- `true_category`: "low", "moderate", or "high" (based on clinical assessment or angle thresholds)

**Category Thresholds** (can be adjusted):
- `low`: Angle < 105° (optimal)
- `moderate`: Angle 105-120° (normal)
- `high`: Angle > 120° (concerning)

## Image Requirements

### Format
- **File format**: PNG (preferred) or JPEG
- **Color space**: RGB
- **Resolution**: 224x224 pixels (will be resized if different)
- **Orientation**: Face should be centered, frontal view preferred

### Quality Standards
- **Lighting**: Even, natural lighting preferred
- **Pose**: Frontal face, neutral expression
- **Background**: Plain background preferred (not required)
- **Face visibility**: Full face visible, no obstructions

## Data Collection Methods

### Option 1: Clinical Study
- Partner with dermatology clinics or research institutions
- Use 3D stereophotogrammetry for ground truth measurements
- Collect demographic data and ARKit measurements simultaneously
- **Pros**: High-quality ground truth, clinical validation
- **Cons**: Expensive, time-consuming, requires IRB approval

### Option 2: App-Based Collection
- Collect data from app users (with consent)
- Use ARKit measurements as features
- Use clinician ratings or self-reported categories as labels
- **Pros**: Scalable, diverse demographics
- **Cons**: Lower quality ground truth, requires large user base

### Option 3: Synthetic Data Generation
- Generate synthetic face images with known measurements
- Use 3D face models to create ARKit features
- **Pros**: Unlimited data, perfect ground truth
- **Cons**: May not generalize to real faces, requires validation

### Option 4: Public Datasets
- Use existing facial analysis datasets
- Extract ARKit features using ARKitFaceAnalyzer
- **Pros**: Readily available, diverse
- **Cons**: May not have all required features, licensing issues

## Data Validation

Before training, validate your dataset:

1. **Completeness**: All CSVs have matching image_ids
2. **Range checks**: All numeric values within expected ranges
3. **Demographic balance**: Check distribution across groups
4. **Image quality**: Verify images load correctly
5. **Label consistency**: Verify labels match angle ranges

## Privacy & Ethics

### Consent
- Obtain informed consent from all participants
- Explain data usage and privacy protections
- Allow opt-out at any time

### Anonymization
- Remove personally identifiable information
- Use anonymized image IDs
- Store demographic data securely

### Bias Mitigation
- Ensure diverse representation
- Monitor for demographic imbalances
- Document data collection methods

## Next Steps

1. **Collect or prepare data** following this guide
2. **Validate data** using validation scripts
3. **Run training script** with prepared data
4. **Monitor training** for bias and accuracy
5. **Validate model** across demographic groups
6. **Convert to Core ML** format
7. **Integrate into app**

## Example Data Generation

For testing purposes, you can generate synthetic data using the provided `generate_sample_data.py` script (to be created). This creates a small dataset for testing the training pipeline.

