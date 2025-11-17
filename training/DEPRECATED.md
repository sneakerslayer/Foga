# Deprecated: ML Model Training Infrastructure

**Status**: Deprecated as of 2025-11-17

## Why This Was Removed

The ML model training infrastructure has been removed because:

1. **Redundant Functionality**: ARKit provides direct, accurate 3D measurements (±5° accuracy) that are more precise than ML predictions
2. **No Clear Use Case**: The model was designed to predict measurements that ARKit already calculates directly
3. **Unused in App**: The model was never integrated into the app - it was infrastructure without a purpose
4. **Complexity Without Benefit**: Training requires large datasets, bias mitigation, and ongoing maintenance for no clear advantage

## What We're Using Instead

- **ARKitFaceAnalyzer**: Direct 3D measurement calculation from ARKit face mesh
- **MeasurementValidator**: Validates measurement quality and reliability
- **ProgressPredictionModel**: Predicts future progress trends (different purpose - this remains)

## Files in This Directory

The training scripts and documentation remain for reference but are **not recommended for use**:

- `train_facial_analysis_model.py` - ML model training script (deprecated)
- `DATA_PREPARATION.md` - Data collection guide (deprecated)
- `QUICKSTART.md` - Training quick start guide (deprecated)
- `README.md` - Training documentation (deprecated)
- `requirements.txt` - Python dependencies (deprecated)

## If You Need ML in the Future

If you find a legitimate use case for ML (e.g., analyzing photos without ARKit data), you can:
1. Review this training infrastructure as a reference
2. Design a new model architecture specific to your use case
3. Collect appropriate training data
4. Train and integrate the new model

For now, ARKit measurements are sufficient and more accurate.

