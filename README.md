# Orbix NicheFinder X

> **The perfect companion to [Andy Hafell's Content Mate](https://www.skool.com/aimate/about?ref=ae32f0f121324efbab8e269e59106b04)**

[![Version](https://img.shields.io/badge/version-1.05-blue)](https://github.com/roughboy99/orbix-nichefinder-x/releases)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Powered By](https://img.shields.io/badge/powered%20by-TwitterAPI.io-1DA1F2)](https://twitterapi.io?ref=roughboy666)

A professional niche influencer and industry research tool for X (Twitter). Find, rank, and export the top influencers in any niche — then feed them directly into Content Mate for automated video creation.

---

## 🔍 What It Does

- Search X/Twitter for top influencers in any niche
- 18 industry presets (Real Estate, SaaS, Finance, Crypto, Health, and more)
- Filter by minimum followers (100 → 500K)
- Rank up to 100 accounts by reach
- Export full CSV — handle, followers, bio, location, verified status
- Auto-update system — checks GitHub for new versions on startup

---

## 🚀 Quick Start

### Windows (Recommended)
1. Download `NicheFinderX-Windows-Installer.zip` from the [installer](installer/) folder
2. Unzip and double-click `INSTALL.bat`
3. Follow the on-screen prompts
4. Launch from the Desktop shortcut

### Manual (All Platforms)
```bash
npm create vite@latest nichefinder-x -- --template react
cd nichefinder-x
npm install
# Copy app/orbix-nichefinder-x.jsx into src/
# Edit src/App.jsx — import NicheFinderX from './orbix-nichefinder-x'; export default function App() { return <NicheFinderX /> }
npm run dev
```

Open `http://localhost:5173` — you need a [TwitterAPI.io](https://twitterapi.io?ref=roughboy666) key to run searches.

---

## 📁 Repository Structure

```
orbix-nichefinder-x/
├── app/
│   └── orbix-nichefinder-x.jsx     # Main React app (single file)
├── docs/
│   └── orbix-nichefinder-x-docs-v1.05.docx  # Full documentation
├── installer/
│   ├── INSTALL.bat                  # Windows installer launcher
│   └── NicheFinderX-Setup.ps1      # PowerShell installer script
├── updater/
│   └── NicheFinderX-Update.bat     # Auto-updater script
├── version.json                     # Update manifest
└── README.md
```

---

## 🔄 Updates

The app checks for updates automatically on startup (can be disabled in the Updates panel).  
You can also click **Check for Updates** manually at any time.

When an update is available:
1. Click **Download & Install** in the app
2. Two files download: the new `.jsx` and `NicheFinderX-Update.bat`
3. Double-click `NicheFinderX-Update.bat` — it replaces the file and restarts the server

---

## 🔑 API Key

This app requires a [TwitterAPI.io](https://twitterapi.io?ref=roughboy666) API key. Free tier available.

---

## 📋 Affiliate Disclosure

Links to TwitterAPI.io and Content Mate in this app and documentation are affiliate links. Orbix Automation Solutions may earn a commission if you sign up — at no extra cost to you.

---

## 📞 Support

**Orbix Automation Solutions**  
🌐 [getorbix.com](https://getorbix.com)  
📞 (610) ORBIX AI — (610) 672-4924  
📍 Wyomissing, PA

---

*Built by Hector Diaz — Orbix Automation Solutions*
