# Orbix NicheFinder X

> **The perfect companion to [Andy Hafell's Content Mate](https://www.skool.com/aimate/about?ref=ae32f0f121324efbab8e269e59106b04)**

[![npm version](https://img.shields.io/npm/v/orbix-nichefinder-x.svg)](https://www.npmjs.com/package/orbix-nichefinder-x)
[![Node](https://img.shields.io/badge/node-%3E%3D18.0.0-brightgreen)](https://nodejs.org)

Find, rank, and export niche influencers on X/Twitter — then feed them directly into Content Mate for automated content creation at scale.

## Install

```bash
npm install -g orbix-nichefinder-x
```

## Run

```bash
nichefinder
```

That's it. Browser opens automatically at `http://localhost:5173`.

## What It Does

- Search X/Twitter for top influencers by niche keyword
- 18 industry presets (Real Estate, SaaS, Finance, Crypto, Health, and more)
- Filter by minimum followers (100 → 500K) and verified status
- Sort and rank up to 100 accounts by reach
- Export full CSV: handle, followers, bio, location, verified status, profile URL
- API key validated and stored encrypted on your device (AES-256)
- Auto-update notifications

## Requirements

- Node.js 18+
- A [TwitterAPI.io](https://twitterapi.io?ref=roughboy666) API key (free tier available)

## Commands

```bash
nichefinder               # Start the app
nichefinder --version     # Show version
nichefinder --reset       # Re-copy app files (fixes issues)
nichefinder --uninstall   # Remove local app files
npm uninstall -g orbix-nichefinder-x  # Full uninstall
```

## How It Works

On first run, NicheFinder X copies its app files to `~/.nichefinder-x/` and installs dependencies there (one-time, ~30 seconds). Every subsequent run starts instantly from that directory.

Your API key is stored encrypted using AES-256-GCM in your browser's localStorage. It is never written to disk as plaintext.

## Links

- **GitHub:** [github.com/roughboy99/orbix-nichefinder-x](https://github.com/roughboy99/orbix-nichefinder-x)
- **API Key:** [twitterapi.io](https://twitterapi.io?ref=roughboy666)
- **Content Mate:** [skool.com/aimate](https://www.skool.com/aimate/about?ref=ae32f0f121324efbab8e269e59106b04)
- **Support:** [getorbix.com](https://getorbix.com) | (610) ORBIX AI

## Affiliate Disclosure

Links to TwitterAPI.io and Content Mate are affiliate links. Orbix Automation Solutions may earn a commission — at no extra cost to you.

---

*Built by Hector Diaz — Orbix Automation Solutions*
