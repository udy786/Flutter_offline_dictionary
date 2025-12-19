# App Store Connect Metadata - Ready to Copy & Paste

This document contains pre-written metadata you can copy directly into App Store Connect.

---

## Basic Information

### App Name
```
WordBridge – OfflineDictionary
```

### Subtitle (30 chars max)
```
English-Hindi Dictionary
```

### Bundle ID
```
org.wordbridge
```

### SKU
```
wordbridge-001
```
(You can use any unique identifier you prefer)

---

## Pricing & Availability

**Price Tier:** Free

**Availability:** All countries (recommended)

---

## App Store Description

### Promotional Text (170 chars - can update anytime without review)
```
Over 1.4 million English words and 35,000 Hindi words. No internet required. Perfect for students, travelers, and language learners.
```

### Description (Main description shown on App Store)
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

### Keywords (100 chars max, comma-separated)
```
dictionary,offline,English,Hindi,words,definitions,vocabulary,translator,reference,learning
```

---

## App Review Information

### Contact Information
**First Name:** [Your First Name]

**Last Name:** [Your Last Name]

**Phone Number:** [Your Phone with country code, e.g., +1-555-123-4567]

**Email:** [Your Email]

### Notes for Review
```
This is an offline dictionary application featuring over 1.4 million English words and 35,000 Hindi words sourced from Wiktionary.

TESTING NOTES:
• No login/account required - app is ready to use immediately
• Core dictionary functionality works completely offline
• Internet connection only required for displaying ads (Google AdMob)
• To test offline functionality, enable Airplane Mode after launch
• Search for common words like: "apple", "hello", "computer" (English) or "नमस्ते", "किताब" (Hindi)
• Database is large (460MB) so initial download may take time

The app displays banner advertisements via Google AdMob. User tracking permission is implemented as required.
```

### Demo Account
**Username:** Not applicable

**Password:** Not applicable

**Additional Info:** No account or login required. App is ready to use immediately after installation.

---

## App Privacy

### Data Collection Summary

**Does your app collect data from this app?**
❌ No

**Explanation:**
- WordBridge uses **non-personalized ads only**
- No user tracking across apps or websites
- No Device ID or IDFA collection
- Search history and favorites are stored locally only (never transmitted)
- AdMob collects minimal technical data (IP address, device type) for serving contextual ads, but this is NOT considered "data collection" by Apple's definition since:
  - It's not linked to user identity
  - It's not used for tracking
  - It's standard for ad delivery

### Important Note:
Since you removed `NSUserTrackingUsageDescription` and configured the app to use non-personalized ads, you should answer **"No"** to data collection in App Store Connect. The contextual ads do not constitute data collection under Apple's privacy policy framework.

### Privacy Policy URL
```
[PASTE YOUR HOSTED PRIVACY POLICY URL HERE]
Example: https://yourusername.github.io/wordbridge-privacy/privacy_policy.html
```

---

## Age Rating

Answer the questionnaire as follows:

**Cartoon or Fantasy Violence:** No
**Realistic Violence:** No
**Sexual Content or Nudity:** No
**Profanity or Crude Humor:** No
**Alcohol, Tobacco, or Drug Use:** No
**Mature/Suggestive Themes:** No
**Horror/Fear Themes:** No
**Gambling:** No
**Unrestricted Web Access:** No
**Simulated Gambling:** No

**Expected Rating:** 4+

---

## App Categories

**Primary Category:** Reference

**Secondary Category:** Education

---

## Support & Marketing URLs

### Support URL (Required)
```
[YOUR HOSTED SUPPORT URL]
Example: https://yourusername.github.io/wordbridge-privacy/support.html
```

**Note:** A complete support page (`support.html`) has been created in your project root. Upload it alongside your privacy policy to the same hosting location (GitHub Pages or similar).

### Marketing URL (Optional)
```
[Leave blank unless you have a dedicated marketing website]
```

---

## Copyright

### Copyright Text
```
© 2025 [Your Name or Company]. All rights reserved.
Dictionary data sourced from Wiktionary under CC BY-SA 3.0 license.
```

---

## App Store Assets Required

### App Icon
✅ Already configured in your Xcode project (Assets.xcassets/AppIcon)

### Screenshots Required

You MUST provide screenshots for at least ONE of these sizes:

**6.7" Display (iPhone 15 Pro Max, 14 Pro Max, 13 Pro Max, 12 Pro Max)**
- Size: 1290 x 2796 pixels
- Required: 3-10 screenshots

**6.5" Display (iPhone 11 Pro Max, XS Max)**
- Size: 1242 x 2688 pixels
- Required: 3-10 screenshots

**5.5" Display (iPhone 8 Plus, 7 Plus, 6s Plus)**
- Size: 1242 x 2208 pixels
- Required: 3-10 screenshots

### Recommended Screenshots (in order):

1. **Home Screen** - Showing search bar, language toggle, and database stats
2. **Search Results** - Showing list of word matches
3. **Word Detail** - Showing a word with its complete definition
4. **Favorites Screen** - Showing saved favorite words
5. **History Screen** - Showing search history with dates

### How to Capture Screenshots:

```bash
# 1. Open iOS Simulator
open -a Simulator

# 2. Select iPhone 15 Pro Max (6.7" display)
# 3. Run your app:
flutter run

# 4. Navigate to each screen and press Cmd+S to save screenshot
# 5. Screenshots saved to Desktop
```

---

## Version & Build Information

### Version Number
```
1.0.0
```

### Build Number
```
1
```

### What's New in This Version (for future updates)
```
Initial Release

Features:
• 1.4+ million English words
• 35,000+ Hindi words
• Complete offline functionality
• Search history and favorites
• Fast full-text search
• Beautiful, intuitive interface
```

---

## Export Compliance

**Does your app use encryption?**

Select: **No** (or if Yes, select "App uses standard encryption")

Standard iOS encryption (HTTPS, secure storage) doesn't require export documentation.

---

## Quick Copy Checklist

Before submitting, make sure you've customized these fields:

- [ ] Replace [Your Name] with actual name
- [ ] Replace [Your Email] with actual email
- [ ] Replace [Your Phone] with actual phone number
- [ ] Add hosted Privacy Policy URL
- [ ] Add Support URL (GitHub or website)
- [ ] Verify copyright text
- [ ] Prepare and upload screenshots

---

## App Store Connect Step-by-Step

1. **Create App**
   - Apps → + → New App
   - Paste metadata from above

2. **App Information Tab**
   - Add subtitle, categories, privacy URL

3. **Pricing and Availability**
   - Set to Free
   - Select countries

4. **Prepare for Submission**
   - Add version: 1.0.0
   - Add description, keywords
   - Upload screenshots
   - Fill App Review Information

5. **App Privacy**
   - Complete privacy questionnaire
   - Add Device ID tracking for ads

6. **Age Rating**
   - Complete questionnaire (all "No" = 4+ rating)

7. **Build**
   - Upload via Xcode
   - Select build in App Store Connect

8. **Submit for Review**
   - Review all sections
   - Click Submit

---

## Need Help?

### Common Questions:

**Q: What if I don't have an Apple Developer Account?**
A: You must enroll at https://developer.apple.com/programs/ ($99/year)

**Q: How long does review take?**
A: Typically 24-48 hours for first submission

**Q: What if my app is rejected?**
A: Apple provides specific reasons. Address them and resubmit.

**Q: Do I need a website for Privacy Policy?**
A: Yes, but GitHub Pages is free and easy. See APP_STORE_SUBMISSION_CHECKLIST.md

**Q: How do I take screenshots?**
A: Run app in iOS Simulator and press Cmd+S on each screen

**Q: Can I update metadata after submission?**
A: Promotional text can be updated anytime. Other fields require new version.

---

All the metadata above is ready to use. Just fill in the bracketed placeholders with your information and paste into App Store Connect!
