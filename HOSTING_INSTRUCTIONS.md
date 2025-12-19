# Hosting Instructions for Privacy Policy and Support Page

## Files to Host

You have two HTML files that need to be hosted online:

1. **`privacy_policy.html`** - Your app's privacy policy (REQUIRED for App Store)
2. **`support.html`** - Your app's support page (REQUIRED for App Store)

Both files are already created and ready to upload. Your contact details are already filled in:
- Email: info@incredereservices.com
- Developer: Incredere Services Pvt Ltd

---

## Option 1: GitHub Pages (Recommended - FREE)

GitHub Pages is the easiest and free way to host these pages.

### Step-by-Step Instructions:

#### 1. Create a New Repository

1. Go to https://github.com
2. Log in to your account (or create one if needed)
3. Click the "+" icon in the top right → "New repository"
4. Fill in:
   - **Repository name:** `wordbridge-privacy`
   - **Description:** "Privacy policy and support page for WordBridge app"
   - **Visibility:** ✅ Public (must be public for GitHub Pages)
   - **Initialize:** ✅ Check "Add a README file"
5. Click "Create repository"

#### 2. Upload Your HTML Files

1. In your new repository, click "Add file" → "Upload files"
2. Drag and drop both files:
   - `privacy_policy.html`
   - `support.html`
3. Add commit message: "Add privacy policy and support page"
4. Click "Commit changes"

#### 3. Enable GitHub Pages

1. In your repository, click "Settings" (top menu)
2. Scroll down the left sidebar and click "Pages"
3. Under "Source", select:
   - **Branch:** `main` (or `master`)
   - **Folder:** `/ (root)`
4. Click "Save"
5. Wait 1-2 minutes for deployment

#### 4. Get Your URLs

After deployment (usually takes 1-2 minutes), your URLs will be:

```
Privacy Policy:
https://[your-github-username].github.io/wordbridge-privacy/privacy_policy.html

Support Page:
https://[your-github-username].github.io/wordbridge-privacy/support.html
```

**Example:** If your GitHub username is `incredere`, your URLs would be:
```
https://incredere.github.io/wordbridge-privacy/privacy_policy.html
https://incredere.github.io/wordbridge-privacy/support.html
```

#### 5. Test Your URLs

Click both URLs to verify they load correctly. You should see:
- Privacy policy page with blue header and your contact info
- Support page with gradient header and FAQ section

#### 6. Save These URLs

You'll need to paste these URLs into App Store Connect:
- Privacy Policy URL → App Information section
- Support URL → App Information section

**✅ That's it! Your pages are now live and ready for App Store submission.**

---

## Option 2: Netlify (Alternative - Also FREE)

If you prefer not to use GitHub, Netlify offers free static hosting.

### Steps:

1. Go to https://www.netlify.com/
2. Sign up for a free account
3. Click "Add new site" → "Deploy manually"
4. Create a folder on your computer with both HTML files
5. Drag the folder into Netlify
6. Your site will be deployed with a random URL like: `https://random-name-123.netlify.app/`
7. Your URLs will be:
   ```
   https://random-name-123.netlify.app/privacy_policy.html
   https://random-name-123.netlify.app/support.html
   ```
8. Optional: You can change the site name in Netlify settings

---

## Option 3: Vercel (Alternative - Also FREE)

Another free hosting option similar to Netlify.

### Steps:

1. Go to https://vercel.com/
2. Sign up for a free account
3. Click "Add New" → "Project"
4. Upload your HTML files
5. Deploy and get your URLs

---

## Important Notes

### ⚠️ Do NOT Change URLs After Submission

Once you submit your app to the App Store with these URLs, **do not change them**. Apple and users will expect these URLs to remain permanent.

### ✅ URLs Must Be:

- **Public** - Anyone can access without login
- **HTTPS** - Must use secure connection (GitHub Pages/Netlify/Vercel all use HTTPS)
- **Permanent** - Don't delete or change URLs
- **Working** - Test before submitting to App Store

### 📝 What to Do Next:

1. ✅ Host both HTML files using one of the options above
2. ✅ Test both URLs to make sure they load
3. ✅ Save both URLs somewhere safe
4. ✅ Open `APP_STORE_METADATA.md`
5. ✅ Replace `[YOUR HOSTED PRIVACY POLICY URL]` with your actual privacy URL
6. ✅ Replace `[YOUR HOSTED SUPPORT URL]` with your actual support URL
7. ✅ Use those URLs when filling out App Store Connect

---

## Troubleshooting

### GitHub Pages not working?
- Make sure repository is **Public**
- Wait 2-5 minutes after enabling Pages
- Check repository Settings → Pages for deployment status
- Look for green checkmark saying "Your site is live at..."

### Want to update the pages later?
- Simply edit the files and upload again to GitHub
- Changes appear automatically within 1-2 minutes
- No need to update App Store (URLs stay the same)

### Need custom domain?
- GitHub Pages supports custom domains (e.g., support.yourcompany.com)
- See GitHub Pages documentation for details
- Not required for App Store submission

---

## Quick Reference

### Files Location:
```
/Users/incredereservices/Documents/AI_APP/Flutter_offline_dictionary/
├── privacy_policy.html  ← Upload this
├── support.html         ← Upload this
```

### Where to Use URLs:

**App Store Connect:**
1. App Information → Privacy Policy URL
2. App Information → Support URL

**Both URLs are REQUIRED for App Store submission!**

---

## Next Steps After Hosting

Once your pages are hosted:

1. ✅ Save your URLs
2. ✅ Test both URLs in a browser
3. ✅ Update `APP_STORE_METADATA.md` with your URLs
4. ✅ Continue with App Store Connect setup (see `APP_STORE_SUBMISSION_CHECKLIST.md`)

---

Good luck with your hosting! If you have any questions, both privacy_policy.html and support.html are ready to go - just upload them to any of the hosting options above.
