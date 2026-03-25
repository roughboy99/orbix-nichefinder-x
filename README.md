# Orbix NicheFinder X

> **The perfect companion to [Andy Hafell's Content Mate](https://www.skool.com/aimate/about?ref=ae32f0f121324efbab8e269e59106b04)**

[![Version](https://img.shields.io/badge/version-1.05-blue)](https://github.com/roughboy99/orbix-nichefinder-x)
[![Doc Rev](https://img.shields.io/badge/docs-Rev%201.07-orange)](https://github.com/roughboy99/orbix-nichefinder-x/tree/main/docs)
[![Powered By](https://img.shields.io/badge/powered%20by-TwitterAPI.io-1DA1F2)](https://twitterapi.io?ref=roughboy666)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)](#-installation)

A professional niche influencer and industry research tool for X (Twitter). Find, rank, and export the top influencers in any niche — then feed them directly into Content Mate for automated video creation at scale.

---

## 🔍 What It Does

- Search X/Twitter for top influencers in any niche
- 18 industry presets (Real Estate, SaaS, Finance, Crypto, Health, and more)
- Filter by minimum followers (100 → 500K) and verified status
- Rank up to 100 accounts by reach
- Export full CSV — handle, followers, bio, location, verified status, X profile URL
- Copy all @handles to clipboard in one click
- Auto-update system — checks GitHub for new versions on startup
- Close App button with two-step server shutdown guide

---

## 🚀 Installation

### Windows
1. Download [`NicheFinderX-Windows-Installer.zip`](installer/NicheFinderX-Windows-Installer.zip)
2. Unzip and double-click `INSTALL.bat`
3. Follow the on-screen prompts
4. Launch from the **NicheFinder X** Desktop shortcut

### macOS
1. Download [`NicheFinderX-macOS-Installer.zip`](installer/NicheFinderX-macOS-Installer.zip)
2. Unzip and double-click `install.mac.command`
3. If macOS blocks it: right-click → Open → Open
4. Launch from **NicheFinder X.command** on your Desktop

### Linux
```bash
# Download and run
unzip NicheFinderX-Linux-Installer.zip -d nfx-install
cd nfx-install && chmod +x install.sh && ./install.sh
```

### Universal (All Platforms)
Download [`NicheFinderX-Universal-Installer.zip`](installer/NicheFinderX-Universal-Installer.zip) — contains all platform installers in one package.

### Manual (Any Platform)
```bash
npm create vite@latest nichefinder-x -- --template react
cd nichefinder-x && npm install
# Copy app/orbix-nichefinder-x.jsx into src/
# Edit src/App.jsx:
#   import NicheFinderX from './orbix-nichefinder-x'
#   export default function App() { return <NicheFinderX /> }
npm run dev
```

> You need a [TwitterAPI.io](https://twitterapi.io?ref=roughboy666) API key to run searches.

---

## 📁 Repository Structure

```
orbix-nichefinder-x/
├── README.md
├── version.json                           ← Update manifest
├── app/
│   └── orbix-nichefinder-x.jsx           ← Main React app (v1.05)
├── docs/
│   └── orbix-nichefinder-x-docs-v1.07.pdf  ← Full documentation (Rev 1.07)
├── installer/
│   ├── INSTALL.bat                        ← Windows launcher
│   ├── NicheFinderX-Setup.ps1            ← Windows installer script
│   ├── install.sh                         ← macOS + Linux installer
│   ├── install.mac.command               ← macOS double-click launcher
│   ├── install-linux.sh                  ← Linux alias
│   ├── NicheFinderX-Universal-Installer.zip  ← All platforms
│   ├── NicheFinderX-Windows-Installer.zip
│   ├── NicheFinderX-macOS-Installer.zip
│   └── NicheFinderX-Linux-Installer.zip
└── updater/
    ├── NicheFinderX-Update.bat           ← Windows auto-updater
    └── NicheFinderX-Update.sh            ← macOS + Linux auto-updater
```

---

## 🔄 Auto-Updates

The app checks GitHub for updates on startup (toggle in the Updates panel). When a new version is available:

1. A gold notification banner appears in the header
2. Click **View Update** to see the changelog
3. Click **Download & Install** — two files download to your Downloads folder
4. Run the updater for your platform:
   - **Windows:** double-click `NicheFinderX-Update.bat`
   - **macOS/Linux:** `chmod +x NicheFinderX-Update.sh && ./NicheFinderX-Update.sh`

The updater backs up your current file, replaces it, and restarts the server automatically.

---

## 🔑 API Key

Requires a [TwitterAPI.io](https://twitterapi.io?ref=roughboy666) API key. Free tier available.

---

## 📖 Documentation

Full setup, usage, and installation guide: [`orbix-nichefinder-x-docs-v1.07.pdf`](docs/orbix-nichefinder-x-docs-v1.07.pdf)

**Covers:** Windows / macOS / Linux installation, Docker deployment, auto-update system, CSV export, GitHub repository, troubleshooting, version history.

---

## 📋 Affiliate Disclosure

Links to [TwitterAPI.io](https://twitterapi.io?ref=roughboy666) and [Content Mate](https://www.skool.com/aimate/about?ref=ae32f0f121324efbab8e269e59106b04) in this app and documentation are affiliate links. Orbix Automation Solutions may earn a commission — at no extra cost to you.

---

## 📞 Support

**Orbix Automation Solutions**  
🌐 [getorbix.com](https://getorbix.com)  
📞 (610) ORBIX AI — (610) 672-4924  
📍 Wyomissing, PA

---

*Built by Hector Diaz — Orbix Automation Solutions*  
*The perfect companion to Andy Hafell's Content Mate*
