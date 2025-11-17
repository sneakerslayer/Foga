# Quick Start Guide - Model Training

This guide will help you get started training the facial analysis model.

## Prerequisites

1. **Python 3.8+** installed
2. **Training data** prepared (see `DATA_PREPARATION.md`)
3. **Dependencies** installed (see below)

## Setup

### 1. Install Dependencies

```bash
cd training
pip install -r requirements.txt
```

Or create a virtual environment (recommended):

```bash
cd training
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Prepare Training Data

Create a data directory with the following structure:

```
data/
├── images/
│   ├── image_001.png
│   ├── image_002.png
│   └── ...
├── metadata.csv
├── arkit_features.csv
└── labels.csv
```

See `DATA_PREPARATION.md` for detailed CSV schemas and requirements.

### 3. Run Training

Basic training command:

```bash
python train_facial_analysis_model.py \
    --data_dir ./data \
    --output_dir ./models \
    --epochs 50 \
    --batch_size 32 \
    --learning_rate 0.001 \
    --quantize
```

**Arguments**:
- `--data_dir`: Path to your data directory (required)
- `--output_dir`: Where to save the trained model (default: `./models`)
- `--epochs`: Number of training epochs (default: 50)
- `--batch_size`: Batch size (default: 32)
- `--learning_rate`: Learning rate (default: 0.001)
- `--quantize`: Quantize model to 16-bit for mobile deployment
- `--device`: `cpu` or `cuda` (default: `cpu`)

### 4. Monitor Training

The script will print progress for each epoch:
- Training/validation loss
- Angle prediction MAE (Mean Absolute Error)
- Category classification accuracy

Training history is saved to `training_history.json` in the output directory.

### 5. Use Trained Model

After training completes, you'll have:
- `FacialAnalysisModel.mlmodelc` - Core ML model file
- `model_info.json` - Model architecture information
- `training_history.json` - Training metrics

**Next Steps**:
1. Copy `FacialAnalysisModel.mlmodelc` to your Xcode project
2. Add it to the app bundle in Xcode
3. The Swift `FacialAnalysisModel` class will automatically load it

## Testing with Sample Data

If you don't have real training data yet, you can test the pipeline with synthetic data. Create a small test dataset:

```python
# generate_test_data.py (example)
import pandas as pd
import numpy as np
from PIL import Image

# Generate sample CSVs
n_samples = 100
image_ids = [f"image_{i:03d}" for i in range(n_samples)]

# Metadata
metadata = pd.DataFrame({
    'image_id': image_ids,
    'age': np.random.randint(18, 80, n_samples),
    'gender': np.random.choice(['male', 'female'], n_samples),
    'bmi': np.random.uniform(18, 30, n_samples),
    'ethnicity': np.random.choice(['caucasian', 'asian', 'african_american'], n_samples),
    'skin_tone': np.random.randint(1, 7, n_samples),
    'context': 'baseline'
})

# ARKit features
arkit = pd.DataFrame({
    'image_id': image_ids,
    'cervico_mental_angle': np.random.uniform(90, 120, n_samples),
    'submental_cervical_length': np.random.uniform(30, 50, n_samples),
    'jaw_definition_index': np.random.uniform(0.5, 0.8, n_samples),
    'neck_circumference': np.random.uniform(350, 400, n_samples),
    'facial_adiposity_index': np.random.uniform(20, 50, n_samples),
    'face_width': np.random.uniform(135, 155, n_samples),
    'face_height': np.random.uniform(195, 220, n_samples),
    'head_pose_pitch': np.random.uniform(-5, 5, n_samples),
    'head_pose_yaw': np.random.uniform(-5, 5, n_samples),
    'head_pose_roll': np.random.uniform(-2, 2, n_samples)
})

# Labels
labels = pd.DataFrame({
    'image_id': image_ids,
    'true_angle': arkit['cervico_mental_angle'],
    'true_category': ['low' if a < 105 else 'moderate' if a < 120 else 'high' 
                     for a in arkit['cervico_mental_angle']]
})

# Save CSVs
metadata.to_csv('data/metadata.csv', index=False)
arkit.to_csv('data/arkit_features.csv', index=False)
labels.to_csv('data/labels.csv', index=False)

# Generate placeholder images
import os
os.makedirs('data/images', exist_ok=True)
for img_id in image_ids:
    img = Image.new('RGB', (224, 224), color=(200, 200, 200))
    img.save(f'data/images/{img_id}.png')
```

Then run training with this test data to verify the pipeline works.

## Troubleshooting

### "FileNotFoundError: Metadata CSV not found"
- Ensure your data directory contains all required CSV files
- Check file paths are correct

### "CUDA out of memory"
- Reduce batch size: `--batch_size 16` or `--batch_size 8`
- Use CPU: `--device cpu`

### "Core ML Tools not available"
- Install: `pip install coremltools`
- Model will train but won't convert to Core ML format

### Training loss not decreasing
- Check data quality and labels
- Try different learning rates: `--learning_rate 0.0001` or `--learning_rate 0.01`
- Increase epochs: `--epochs 100`

## Next Steps

1. **Collect real training data** following `DATA_PREPARATION.md`
2. **Train model** with diverse, balanced dataset
3. **Validate fairness** across demographic groups
4. **Convert to Core ML** and integrate into app
5. **Test on-device** inference performance

For detailed information, see:
- `DATA_PREPARATION.md` - Data format and collection
- `README.md` - Model architecture and requirements
- `train_facial_analysis_model.py` - Training script documentation

