# App Store Submission Checklist for WordBridge

## ✅ Technical Requirements

### App Configuration
- [x] **App Version:** 1.0.0+1 (verified in pubspec.yaml)
- [x] **Bundle ID:** org.wordbridge (verified in project.pbxproj and Info.plist)
- [x] **App Name:** WordBridge (display name in Info.plist)
- [x] **App Store Name:** WordBridge – OfflineDictionary
- [x] **App Icons:** All required sizes present in Assets.xcassets

### Required Permissions & Privacy
- [x] **NSUserTrackingUsageDescription:** Added for AdMob tracking
  - Description: "This identifier will be used to deliver personalized ads to you."
- [x] **GADApplicationIdentifier:** Configured (ca-app-pub-6174288335500940~9448595047)
- [x] **SKAdNetworkItems:** Added for ad attribution

### AdMob Configuration
- [x] **App ID (iOS):** ca-app-pub-6174288335500940~9448595047
- [x] **Banner Ad Unit ID:** ca-app-pub-6174288335500940/9670395824
- [x] **Ad Integration:** Banner ads implemented on Home, Favorites, and History screens
- [x] **google_mobile_ads SDK:** v5.1.0 added to pubspec.yaml

### Database & Core Functionality
- [x] **Dictionary Database:** 460MB database file (1.4M+ words)
- [x] **Offline Functionality:** Fully functional without internet
- [x] **Search:** Working with FTS5 full-text search
- [x] **History & Favorites:** Local storage implemented
- [x] **Language Support:** English and Hindi (Devanagari)

---

## 🔴 CRITICAL - Must Complete Before Submission

### 1. Privacy Policy & Support Page (REQUIRED)
- [ ] **Host Privacy Policy and Support Page Online**
  - Files created: `privacy_policy.html` and `support.html`
  - **Action Needed:** Upload both files to a public URL

  **Option A - GitHub Pages (Recommended - Free):**
  ```bash
  # 1. Create a new repository on GitHub (e.g., "wordbridge-privacy")
  # 2. Upload privacy_policy.html and support.html
  # 3. Enable GitHub Pages in repository settings
  # 4. Your URLs will be:
  #    Privacy: https://[your-username].github.io/wordbridge-privacy/privacy_policy.html
  #    Support: https://[your-username].github.io/wordbridge-privacy/support.html
  ```

  **Option B - Other Hosting:**
  - Use any web hosting service (Netlify, Vercel, Firebase Hosting, etc.)
  - Ensure the URLs are permanent and won't change

- [ ] **Privacy Policy is Already Updated:**
  - ✅ Contact email: info@incredereservices.com
  - ✅ Developer: Incredere Services Pvt Ltd
  - Save both URLs - you'll need them for App Store Connect

### 2. Apple Developer Account
- [ ] **Enroll in Apple Developer Program**
  - Cost: $99/year
  - URL: https://developer.apple.com/programs/
  - Note: Required to submit apps to App Store

### 3. App Signing & Certificates
- [ ] **Create App ID in Apple Developer Portal**
  - Bundle ID: org.wordbridge
  - Enable capabilities if needed (none required for this app)

- [ ] **Generate Certificates**
  - Distribution Certificate (for App Store)
  - Provisioning Profile

- [ ] **Configure Signing in Xcode**
  - Open: `ios/Runner.xcworkspace` in Xcode
  - Select Runner target → Signing & Capabilities
  - Select your Team
  - Enable "Automatically manage signing"

---

## 📱 App Store Connect Setup

### 1. Create App in App Store Connect
- [ ] Go to https://appstoreconnect.apple.com
- [ ] Click "My Apps" → "+" → "New App"
- [ ] Fill in:
  - **Platform:** iOS
  - **Name:** WordBridge – OfflineDictionary
  - **Primary Language:** English (US)
  - **Bundle ID:** org.wordbridge
  - **SKU:** Choose unique identifier (e.g., "wordbridge-001")

### 2. App Information
- [ ] **Subtitle** (30 characters max):
  ```
  English-Hindi Dictionary
  ```

- [ ] **Privacy Policy URL:**
  ```
  [YOUR HOSTED PRIVACY POLICY URL]
  ```

- [ ] **Category:**
  - **Primary:** Reference
  - **Secondary:** Education

- [ ] **Age Rating:**
  - Complete the questionnaire
  - Expected: 4+ (No objectionable content)

### 3. Pricing and Availability
- [ ] **Price:** Free
- [ ] **Availability:** All countries (or select specific countries)

### 4. App Privacy
Apple requires detailed privacy information. Based on your app:

**Data Types Collected:**
- [ ] Check "Yes, we collect data from this app"
- [ ] **Device ID** (collected by AdMob for advertising)
  - Linked to User: Yes
  - Used for Tracking: Yes
  - Purposes: Advertising, Analytics

**Data Not Collected by Your App:**
- Search history (stored locally only)
- Favorites (stored locally only)
- Name, email, or any personal information

---

## 📸 App Store Screenshots (REQUIRED)

You must provide screenshots for at least one device size. Recommended sizes:

### iPhone 6.7" Display (iPhone 15 Pro Max, 14 Pro Max, etc.)
- **Required:** 3-10 screenshots
- **Size:** 1290 x 2796 pixels
- **Suggested Screenshots:**
  1. Home screen with search bar and stats
  2. Search screen showing search results
  3. Word detail screen with definition
  4. Favorites screen
  5. History screen

### How to Take Screenshots:
1. Run app on iOS Simulator (iPhone 15 Pro Max recommended)
2. Navigate to each screen
3. Press Cmd+S to save screenshot
4. Screenshots will be saved to Desktop

### Screenshot Tips:
- Use Status Bar Override in Xcode to show full battery, signal
- Show the app's key features
- Consider adding text overlay describing features (optional)

---

## 📝 App Store Description

### App Name (30 characters max)
```
WordBridge – OfflineDictionary
```

### Promotional Text (170 characters max - can be updated anytime)
```
Over 1.4 million English words and 35,000 Hindi words. No internet required. Perfect for students, travelers, and language learners.
```

### Description (4000 characters max)
```
WordBridge – Offline Dictionary is your comprehensive English-Hindi dictionary with over 1.4 million English words and 35,000 Hindi words, all accessible completely offline.

KEY FEATURES:

📚 MASSIVE OFFLINE DATABASE
• 1,400,000+ English word definitions
• 35,000+ Hindi (Devanagari) words with translations
• Complete Wiktionary data
• No internet connection required
• Instant search results

🔍 POWERFUL SEARCH
• Fast full-text search
• Search in both English and Hindi
• Smart suggestions as you type
• Find words by prefix, meaning, or partial match

⭐ PERSONALIZED EXPERIENCE
• Save favorite words for quick access
• Automatic search history
• Language preference toggle
• Clean, intuitive interface

📖 COMPREHENSIVE DEFINITIONS
• Detailed word meanings
• Multiple definitions per word
• Part of speech information
• Usage examples (where available)

🎨 BEAUTIFUL DESIGN
• Modern Material Design 3 interface
• Smooth animations and transitions
• Easy-to-read typography
• Support for Devanagari script

✈️ PERFECT FOR:
• Students and learners
• Travelers to India
• Language enthusiasts
• Writers and readers
• Anyone needing quick word lookups without internet

💾 PRIVACY FOCUSED
• All data stored locally on your device
• No account required
• No personal information collected
• Your search history stays private

🆓 FREE TO USE
• No subscription required
• Full access to all words
• No feature limitations
• Supported by non-intrusive ads

Whether you're learning English, studying Hindi, or simply need a reliable offline dictionary, WordBridge has you covered with instant access to comprehensive word definitions.

Download WordBridge today and carry a complete dictionary in your pocket!
```

### Keywords (100 characters max, comma-separated)
```
dictionary,offline,English,Hindi,words,definitions,vocabulary,translator,reference,learning
```

### Support URL
```
[YOUR WEBSITE OR GITHUB REPO URL]
Example: https://github.com/[your-username]/flutter_offline_dictionary
```

### Marketing URL (Optional)
```
[Leave blank or add a marketing website if you have one]
```

---

## 🏗️ Build and Submit

### 1. Create Archive
```bash
# From project root
cd ios

# Clean build
flutter clean
flutter pub get

# Build for release
flutter build ios --release

# Open Xcode workspace
open Runner.xcworkspace
```

### 2. In Xcode
1. Select "Any iOS Device (arm64)" as destination
2. Product → Archive
3. Wait for archive to complete
4. When done, Organizer window will open
5. Select your archive
6. Click "Distribute App"
7. Choose "App Store Connect"
8. Follow the prompts
9. Upload to App Store Connect

### 3. Submit for Review
1. Go to App Store Connect
2. Select your app
3. Go to version you want to submit
4. Complete all required fields
5. Add screenshots
6. Add app review information:
   - **Demo Account:** Not needed (no login required)
   - **Notes:** "This is an offline dictionary app. No internet connection required for core functionality. Ads require internet connection."
7. Click "Submit for Review"

---

## ⚠️ Common Rejection Reasons to Avoid

- [ ] **Missing Privacy Policy:** Ensure privacy policy URL is valid and accessible
- [ ] **AdMob Compliance:** User tracking permission is properly implemented
- [ ] **App Completeness:** All features work as described
- [ ] **Metadata Accuracy:** Description matches actual functionality
- [ ] **Screenshots:** Show actual app screens (not mockups)
- [ ] **Age Rating:** Correctly filled out questionnaire
- [ ] **Copyright:** Don't use "Wiktionary" branding in app name or screenshots

---

## 📋 Pre-Submission Checklist

Before clicking "Submit for Review", verify:

- [ ] App runs without crashes on physical iOS device
- [ ] Search functionality works correctly
- [ ] Favorites can be added/removed
- [ ] History is being recorded
- [ ] Ads display correctly (use real device, not simulator)
- [ ] App works completely offline (test in Airplane Mode)
- [ ] No console errors or warnings
- [ ] Privacy policy URL is live and accessible
- [ ] All App Store Connect fields are completed
- [ ] Screenshots are uploaded for at least one device size
- [ ] App description is accurate and compelling
- [ ] Support URL is working
- [ ] Age rating is appropriate (4+)

---

## 📞 Support & Contact

### If App is Rejected:
1. Read rejection reason carefully in Resolution Center
2. Address the specific issues mentioned
3. Update app if needed and resubmit
4. Respond to reviewer if clarification is needed

### Typical Review Time:
- First review: 24-48 hours
- Resubmission: 12-24 hours

---

## 🎉 After Approval

Once approved:
- [ ] App will appear on App Store within 24 hours
- [ ] Monitor user reviews and ratings
- [ ] Respond to user feedback
- [ ] Plan updates based on user requests
- [ ] Track app analytics in App Store Connect

---

## 📱 Testing on Real Device (Highly Recommended)

Before submission, test on a real iOS device:

```bash
# 1. Connect iPhone via USB
# 2. Trust computer on iPhone
# 3. Run in Xcode or via Flutter:
flutter run --release
```

Test these scenarios:
- [ ] Fresh install (uninstall first if previously installed)
- [ ] Search for various words (English and Hindi)
- [ ] Add/remove favorites
- [ ] Clear history
- [ ] Navigate all screens
- [ ] Verify ads display (on real device only)
- [ ] Test in Airplane Mode (offline functionality)
- [ ] Check app size (should be ~500MB due to database)

---

## 🔐 Important Notes

1. **Privacy Policy is MANDATORY** - App will be rejected without it
2. **Test on Real Device** - Simulator doesn't show ads correctly
3. **First Submission** - May take 24-48 hours for review
4. **Be Patient** - Review process can't be rushed
5. **Read Rejection Carefully** - Apple provides specific feedback

---

## ✅ Status Overview

**Ready:**
- ✅ App code complete
- ✅ AdMob integrated
- ✅ Info.plist configured
- ✅ Bundle ID set
- ✅ Privacy policy document created
- ✅ App icons ready

**Need to Complete:**
- 🔴 Host privacy policy online (CRITICAL)
- 🔴 Apple Developer Account enrollment
- 🔴 App Store Connect setup
- 🔴 Screenshots
- 🔴 App signing/certificates
- 🔴 Build and upload

---

Good luck with your submission! The app is technically ready - you just need to complete the App Store paperwork and hosting requirements.
