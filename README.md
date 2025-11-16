# Stoic IA ⚽

**Professional Soccer Analysis powered by Apple Intelligence**

Stoic IA is a cutting-edge iOS application that uses Apple's Vision framework and on-device AI to provide professional-level soccer technique analysis. Get expert feedback on your shooting, passing, ball control, and more - all powered by advanced computer vision and biomechanics analysis.

## Features

### 🤖 AI-Powered Analysis
- **Vision Framework Integration**: Advanced pose detection and movement tracking
- **On-Device Processing**: All analysis happens locally using Apple Intelligence
- **Real-time Biomechanics**: Analyzes body posture, foot placement, and technique execution

### ⚽ Professional Soccer Coaching
- **FIFA-Based Standards**: Analysis based on official FIFA coaching methodologies
- **Comprehensive Technique Evaluation**:
  - Ball control and first touch
  - Shooting technique and power generation
  - Passing accuracy and mechanics
  - Body positioning and balance
  - Foot placement and strike quality

### 🎨 Modern UI/UX
- **Liquid Glass Design**: Beautiful, modern iOS design system
- **Smooth Animations**: Fluid transitions and engaging interactions
- **Dark Mode**: Optimized for OLED displays
- **Intuitive Navigation**: Tab-based architecture for easy access

### 📊 Detailed Insights
- **Technique Metrics**: Quantified scores for different aspects of your game
- **Professional Insights**: Categorized feedback with severity levels
- **Actionable Recommendations**: Step-by-step improvement guidance
- **Progress Tracking**: History of all your analyses

## Technical Stack

### Frameworks & Technologies
- **SwiftUI**: Modern declarative UI framework
- **Vision**: Apple's computer vision framework for pose detection
- **AVFoundation**: Video processing and playback
- **Core ML**: On-device machine learning
- **PhotosUI**: Photo and video selection

### Architecture
- **MVVM Pattern**: Clean separation of concerns
- **Async/Await**: Modern concurrency for smooth performance
- **Lazy Loading**: Optimized memory usage
- **Modular Design**: Reusable components and services

### Key Components

#### Services
- `VisionAnalysisService`: Handles video frame extraction and pose detection
- `SoccerAnalysisEngine`: Professional technique evaluation based on FIFA standards

#### Views
- `SplashScreenView`: Animated launch screen
- `OnboardingView`: Introduction and feature overview
- `HomeView`: Dashboard with quick stats and recent analyses
- `VideoAnalysisView`: Video selection and analysis initiation
- `AnalysisResultsView`: Detailed results and history
- `VideoPlayerView`: Custom video player with overlays

#### Design System
- `LiquidGlassButton`: Glassmorphic button component
- `GlassmorphicCard`: Reusable card component with glass effect
- `MetricCard`, `InsightCard`, `RecommendationCard`: Specialized cards

## Requirements

- **iOS**: 17.0 or later
- **Xcode**: 15.0 or later
- **Swift**: 5.9 or later
- **Device**: iPhone (Portrait orientation)

## Installation

### For Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/mitre88/soccer-analist.git
   cd soccer-analist
   ```

2. **Open in Xcode**
   ```bash
   open StoicIA/StoicIA.xcodeproj
   ```

3. **Configure Signing**
   - Select the StoicIA target
   - Go to "Signing & Capabilities"
   - Select your development team

4. **Build and Run**
   - Select your target device or simulator
   - Press Cmd+R to build and run

### For App Store Submission

1. **Generate App Icon**
   - Create a 1024x1024px icon with black and white design
   - Place in `StoicIA/StoicIA/Resources/Assets.xcassets/AppIcon.appiconset/`
   - Update `Contents.json` if needed

2. **Configure Bundle Identifier**
   - Update to your unique bundle ID in project settings

3. **Review Info.plist**
   - Ensure camera and photo library usage descriptions are appropriate
   - Update app display name if needed

4. **Archive and Upload**
   - Product → Archive
   - Upload to App Store Connect

## Usage

### Recording Tips
For best analysis results:
- Record in good lighting conditions
- Position camera to show full body from the side
- Keep videos between 5-30 seconds
- Focus on one technique at a time
- Ensure the ball is visible in frame

### Analysis Process
1. **Select Action Type**: Choose what you're practicing (shooting, passing, etc.)
2. **Upload Video**: Select from your photo library
3. **AI Analysis**: Wait while the app analyzes your technique (15-30 seconds)
4. **Review Results**: Get detailed insights and recommendations
5. **Track Progress**: View history and improvement over time

## Privacy & Security

- **On-Device Processing**: All video analysis happens locally on your device
- **No Data Collection**: Videos and analysis results are stored only on your device
- **Privacy First**: No data is sent to external servers
- **Secure Storage**: All data is protected by iOS security mechanisms

## Analysis Methodology

### Vision Framework Analysis
1. **Frame Extraction**: Key frames extracted at 10Hz
2. **Pose Detection**: VNDetectHumanBodyPoseRequest identifies body landmarks
3. **Ball Detection**: Object detection algorithms locate the soccer ball
4. **Movement Tracking**: Frame-by-frame analysis of motion patterns

### Technique Evaluation
Based on professional coaching standards:
- **Body Posture**: Spine alignment, hip position, shoulder alignment
- **Foot Placement**: Plant foot distance (optimal: 15-25cm), angle (30-45°)
- **Strike Quality**: Contact type, swing path, follow-through
- **Timing**: Approach rhythm, impact timing, follow-through completion
- **Balance**: Weight distribution, stability throughout motion

### Scoring System
- **90-100**: Elite level (professional standard)
- **75-89**: Advanced (high-level amateur)
- **60-74**: Intermediate (solid foundation)
- **Below 60**: Developing (focus on fundamentals)

## Roadmap

### Version 1.1
- [ ] Comparison with professional players
- [ ] Training drill recommendations
- [ ] Video overlay with skeletal tracking
- [ ] Custom training programs

### Version 1.2
- [ ] Multiple player tracking
- [ ] Team formation analysis
- [ ] Match statistics integration
- [ ] Social sharing features

### Version 2.0
- [ ] Custom Core ML models for specific techniques
- [ ] 3D biomechanics visualization
- [ ] Coach collaboration features
- [ ] Apple Watch integration

## Contributing

This is a proprietary project for App Store distribution. For bug reports or feature requests, please contact the development team.

## License

Copyright © 2025 Stoic IA. All rights reserved.

## Support

For support, questions, or feedback:
- Create an issue in this repository
- Contact: [Your support email]

## Credits

### Development
- Built with Swift and SwiftUI
- Powered by Apple Intelligence and Vision framework

### References
- FIFA Coaching Methodology
- Professional soccer training standards
- Sports biomechanics research

---

**Made with ⚽ for soccer players who want to reach their full potential**

*Stoic IA - Where AI meets athletic excellence*
