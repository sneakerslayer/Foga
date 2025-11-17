# User Acceptance Testing Plan - Foga App
## Task 8.9.5: User Acceptance Testing with Diverse Users

## Overview

This document outlines the user acceptance testing (UAT) plan for the Foga app, focusing on testing with diverse users from different demographics to validate transparency, understand limitations, and ensure the app works fairly for all users.

## Objectives

1. **Validate Transparency**: Ensure users understand the scientific limitations and evidence level of facial exercises
2. **Test Understanding**: Verify users comprehend that the app is a wellness tool, not a medical device
3. **Demographic Fairness**: Test app functionality and accuracy across diverse demographic groups
4. **User Experience**: Gather feedback on UI/UX, especially transparency components and disclaimers
5. **Ethical Safeguards**: Validate that ethical safeguards (body dysmorphia detection, mental health resources) work appropriately

## Success Criteria

- ✅ Tests conducted with users from at least 5 different demographic groups (race, skin tone, age, gender combinations)
- ✅ Users demonstrate understanding of scientific limitations (via feedback/questions)
- ✅ Users report transparency components are clear and helpful
- ✅ No significant usability issues reported across demographic groups
- ✅ Ethical safeguards appropriately detect concerning behavior patterns
- ✅ Feedback collected and analyzed for improvements

## Test Participant Demographics

### Target Demographics (Minimum 30 participants)

**Race/Ethnicity** (at least 5 participants per group):
- Asian
- Black/African American
- Hispanic/Latino
- White/Caucasian
- Middle Eastern/North African
- Multiracial/Other

**Skin Tone** (Fitzpatrick Scale, distributed across):
- Type I-II (Very fair to fair)
- Type III-IV (Medium to olive)
- Type V-VI (Brown to very dark)

**Age Groups**:
- 18-24 (at least 5 participants)
- 25-34 (at least 10 participants)
- 35-44 (at least 5 participants)
- 45-54 (at least 5 participants)
- 55+ (at least 5 participants)

**Gender**:
- Female (at least 15 participants)
- Male (at least 15 participants)
- Non-binary/Other (at least 2 participants)

**Geographic Distribution**:
- At least 3 different regions/countries
- Urban and suburban participants
- Various socioeconomic backgrounds

## Test Scenarios

### Scenario 1: First-Time User Onboarding
**Objective**: Test onboarding flow, transparency, and initial understanding

**Steps**:
1. Launch app for first time
2. Complete onboarding flow:
   - Welcome screen
   - Benefits carousel
   - Permission requests (camera, notifications)
   - Face scan tutorial
   - Goal setting
3. Read all disclaimers and transparency information

**Questions to Ask**:
- Did you understand what the app does?
- Did you notice the disclaimers about scientific evidence?
- Were the permission requests clear?
- Did you feel comfortable granting camera permissions?
- What were your expectations after onboarding?

**Success Criteria**:
- User can complete onboarding without confusion
- User mentions seeing disclaimers/transparency information
- User understands app is for wellness, not medical treatment

### Scenario 2: Face Measurement Capture
**Objective**: Test face scanning functionality and measurement accuracy across demographics

**Steps**:
1. Navigate to face scan feature
2. Follow ARKit face tracking instructions
3. Capture baseline measurement
4. Review measurement results
5. Read measurement disclaimers and transparency information

**Questions to Ask**:
- Was the face tracking clear and easy to follow?
- Did the measurement feel accurate?
- Did you understand what the cervico-mental angle means?
- Were the disclaimers about measurement accuracy clear?
- Did you see the optimal range information (90-105°)?
- Were the confidence scores explained well?

**Success Criteria**:
- Face tracking works reliably across all skin tones and face shapes
- Users understand measurement results and confidence scores
- Users notice and read transparency disclaimers
- No significant accuracy issues reported by any demographic group

### Scenario 3: Progress Prediction Understanding
**Objective**: Validate users understand predictions include confidence intervals and limitations

**Steps**:
1. Capture at least 2 measurements (baseline + follow-up)
2. View progress predictions
3. Read prediction disclaimers
4. Review responder type classification (if available)

**Questions to Ask**:
- Did you understand that predictions are estimates with ranges?
- Did you notice the confidence intervals (e.g., "5-15° improvement in 3 months")?
- Were you confused by any prediction terminology?
- Did the disclaimers about individual variation make sense?
- Did you feel the predictions were realistic or too optimistic?

**Success Criteria**:
- Users understand predictions are ranges, not exact numbers
- Users notice confidence intervals
- Users understand individual variation
- No users report feeling misled by predictions

### Scenario 4: Scientific Transparency Components
**Objective**: Test understanding of evidence limitations and scientific honesty

**Steps**:
1. Navigate to measurement results
2. View EvidenceDisclosure component
3. Read scientific citations
4. View full disclaimer
5. Check MedicalAlternativesCard (if angle is concerning)

**Questions to Ask**:
- Did you understand that facial exercises have limited scientific evidence?
- Were the scientific citations helpful or confusing?
- Did you feel the app was being honest about limitations?
- Did you understand the difference between wellness tool vs. medical device?
- Were the medical alternatives information helpful (if shown)?

**Success Criteria**:
- Users demonstrate understanding of evidence limitations
- Users appreciate scientific honesty
- Users understand wellness vs. medical positioning
- Scientific citations are accessible and helpful

### Scenario 5: Ethical Safeguards Testing
**Objective**: Validate body dysmorphia detection and mental health resources

**Steps**:
1. Perform multiple measurements (test excessive measurement detection)
2. Provide negative satisfaction feedback (test pattern detection)
3. Change goals frequently (test unrealistic goal detection)
4. View wellbeing resources (if risk detected)

**Questions to Ask** (if resources shown):
- Were the mental health resources helpful?
- Did you feel the app was being supportive or intrusive?
- Were the helpline numbers accessible?
- Did you understand why resources were shown?

**Success Criteria**:
- Ethical safeguards detect concerning patterns appropriately
- Resources are shown at appropriate times (not too early, not too late)
- Users feel supported, not judged
- Resources are accessible and helpful

### Scenario 6: Demographic Fairness Validation
**Objective**: Ensure app works equally well across all demographic groups

**Steps**:
1. Test face measurement accuracy across different:
   - Skin tones
   - Face shapes
   - Age groups
   - Gender presentations
2. Compare measurement confidence scores
3. Compare prediction accuracy

**Questions to Ask**:
- Did you feel the app worked well for your face type?
- Were measurements consistent across multiple attempts?
- Did you notice any issues specific to your demographic group?
- Were confidence scores reasonable?

**Success Criteria**:
- No significant accuracy differences across demographic groups
- Confidence scores are appropriate for all groups
- No usability issues specific to any demographic
- Users report fair treatment regardless of demographics

### Scenario 7: Privacy and Data Understanding
**Objective**: Validate users understand privacy protections and data handling

**Steps**:
1. Review privacy settings
2. View privacy report (if available)
3. Test data export functionality
4. Test data deletion functionality

**Questions to Ask**:
- Did you understand what data is collected?
- Were you comfortable with on-device processing only?
- Did you understand the 90-day retention policy?
- Were data export/deletion options clear?

**Success Criteria**:
- Users understand privacy protections
- Users feel comfortable with data handling
- Data export/deletion work as expected

## Feedback Collection Methods

### 1. Structured Survey (Post-Testing)
- Use feedback form (see `UAT_FEEDBACK_FORM.md`)
- Collect quantitative ratings (1-5 scale)
- Collect qualitative feedback (open-ended questions)

### 2. In-App Feedback Collection
- Implement feedback view in app (see `UserFeedbackView.swift`)
- Allow users to submit feedback directly from app
- Include screenshots/annotations if possible

### 3. Interview Sessions (Optional)
- Conduct 15-30 minute interviews with subset of participants
- Focus on transparency understanding and demographic fairness
- Record (with permission) for detailed analysis

### 4. Observational Notes
- Test facilitator notes during testing sessions
- Document usability issues, confusion points, positive feedback
- Note demographic-specific observations

## Feedback Categories

### 1. Transparency & Understanding
- Clarity of disclaimers
- Understanding of scientific limitations
- Comprehension of evidence level
- Appreciation of scientific honesty

### 2. Usability & User Experience
- Ease of navigation
- Clarity of instructions
- Face tracking reliability
- Measurement result clarity

### 3. Demographic Fairness
- Accuracy across skin tones
- Accuracy across face shapes
- Accuracy across age groups
- Fair treatment regardless of demographics

### 4. Ethical Safeguards
- Appropriateness of risk detection
- Helpfulness of mental health resources
- Supportiveness vs. intrusiveness
- Age-appropriate content

### 5. Privacy & Trust
- Understanding of privacy protections
- Comfort with data handling
- Trust in app's honesty
- Willingness to continue using app

## Testing Timeline

### Phase 1: Preparation (Week 1)
- Recruit diverse test participants (30+ participants)
- Prepare test devices (iPhone X or later)
- Set up feedback collection system
- Create test scripts and scenarios

### Phase 2: Testing (Weeks 2-4)
- Conduct testing sessions (1-2 hours per participant)
- Collect feedback via surveys and interviews
- Document observations and issues
- Monitor for demographic-specific patterns

### Phase 3: Analysis (Week 5)
- Analyze quantitative feedback (ratings, scores)
- Analyze qualitative feedback (themes, patterns)
- Identify demographic-specific issues
- Compile findings and recommendations

### Phase 4: Reporting (Week 6)
- Create UAT report (see `UAT_REPORT_TEMPLATE.md`)
- Present findings to development team
- Prioritize improvements based on feedback
- Plan follow-up testing if needed

## Risk Mitigation

### Potential Risks:
1. **Low Participation**: May struggle to recruit diverse participants
   - **Mitigation**: Partner with diverse community organizations, offer incentives

2. **Demographic Imbalance**: May not achieve balanced representation
   - **Mitigation**: Set minimum quotas per demographic group, extend recruitment

3. **Technical Issues**: ARKit may not work on all devices
   - **Mitigation**: Test on multiple device models, have backup devices ready

4. **Privacy Concerns**: Users may be hesitant to share demographic data
   - **Mitigation**: Emphasize optional nature, explain privacy protections clearly

5. **Bias in Feedback**: Testers may not represent actual user base
   - **Mitigation**: Recruit from diverse sources, validate findings with larger sample

## Success Metrics

### Quantitative Metrics:
- **Transparency Understanding**: >80% of users demonstrate understanding of limitations
- **Usability Score**: >4.0/5.0 average rating
- **Demographic Fairness**: <5% difference in accuracy/confidence across groups
- **Trust Score**: >4.0/5.0 average rating for scientific honesty
- **Overall Satisfaction**: >4.0/5.0 average rating

### Qualitative Metrics:
- Users mention appreciating scientific honesty
- Users understand wellness vs. medical positioning
- No significant confusion about disclaimers
- Positive feedback on ethical safeguards
- No demographic-specific complaints

## Reporting

See `UAT_REPORT_TEMPLATE.md` for detailed reporting structure.

## Next Steps After UAT

1. **Analyze Feedback**: Review all feedback and identify patterns
2. **Prioritize Improvements**: Focus on high-impact, high-frequency issues
3. **Implement Fixes**: Address critical issues before launch
4. **Follow-Up Testing**: Conduct additional testing if major issues found
5. **Documentation Updates**: Update user documentation based on feedback

## Notes

- All testing should be conducted with informed consent
- Participants should be compensated appropriately for their time
- Privacy and data protection must be maintained throughout testing
- Feedback should be anonymized before analysis
- Demographic data collection is optional and privacy-preserving

