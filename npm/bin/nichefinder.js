#!/usr/bin/env node
/**
 * Orbix NicheFinder X — CLI Entry Point
 * Usage: nichefinder  OR  nichefinder-x
 *
 * On first run: copies the app files to ~/.nichefinder-x/
 * On every run: starts the Vite dev server from that directory
 */

const path   = require("path")
const fs     = require("fs")
const os     = require("os")
const cp     = require("child_process")

// ── PATHS ──────────────────────────────────────────────────
const PKG_DIR  = path.join(__dirname, "..")           // npm package root
const APP_SRC  = path.join(PKG_DIR, "app")            // bundled template files
const APP_HOME = path.join(os.homedir(), ".nichefinder-x")  // user's working dir
const VERSION  = require("../package.json").version

// ── COLORS ─────────────────────────────────────────────────
const C = {
  reset:  "\x1b[0m",
  cyan:   "\x1b[36m",
  yellow: "\x1b[33m",
  green:  "\x1b[32m",
  red:    "\x1b[31m",
  gray:   "\x1b[90m",
  white:  "\x1b[97m",
  gold:   "\x1b[33m",
}

const ok   = msg => console.log(`  ${C.green}[OK]${C.reset}  ${msg}`)
const warn = msg => console.log(`  ${C.yellow}[!!]${C.reset}  ${msg}`)
const info = msg => console.log(`        ${C.gray}${msg}${C.reset}`)
const fail = msg => console.log(`  ${C.red}[XX]${C.reset}  ${msg}`)

// ── HEADER ─────────────────────────────────────────────────
console.log("")
console.log(`  ${C.cyan}+============================================================+${C.reset}`)
console.log(`  ${C.cyan}|${C.reset}                                                            ${C.cyan}|${C.reset}`)
console.log(`  ${C.cyan}|${C.reset}   ${C.white}ORBIX NicheFinder X${C.reset} ${C.cyan}v${VERSION}${C.reset}                            ${C.cyan}|${C.reset}`)
console.log(`  ${C.cyan}|${C.reset}   ${C.gold}The perfect companion to Andy Hafell's Content Mate${C.reset}   ${C.cyan}|${C.reset}`)
console.log(`  ${C.cyan}|${C.reset}                                                            ${C.cyan}|${C.reset}`)
console.log(`  ${C.cyan}|${C.reset}   ${C.gray}getorbix.com  |  (610) ORBIX AI  |  twitterapi.io${C.reset}      ${C.cyan}|${C.reset}`)
console.log(`  ${C.cyan}+============================================================+${C.reset}`)
console.log("")

// ── PARSE ARGS ─────────────────────────────────────────────
const args   = process.argv.slice(2)
const isHelp = args.includes("--help") || args.includes("-h")
const isVer  = args.includes("--version") || args.includes("-v")
const isReset= args.includes("--reset")   // force re-copy app files
const isUnin = args.includes("--uninstall")

if (isVer) {
  console.log(`  NicheFinder X v${VERSION}`)
  process.exit(0)
}

if (isHelp) {
  console.log("  Usage:")
  console.log("    nichefinder              Start the app")
  console.log("    nichefinder --version    Show version")
  console.log("    nichefinder --reset      Re-copy app files (fixes corrupted install)")
  console.log("    nichefinder --uninstall  Remove app files from ~/.nichefinder-x")
  console.log("")
  console.log("  API key: twitterapi.io?ref=roughboy666")
  console.log("  Docs:    github.com/roughboy99/orbix-nichefinder-x")
  console.log("")
  process.exit(0)
}

if (isUnin) {
  if (fs.existsSync(APP_HOME)) {
    fs.rmSync(APP_HOME, { recursive: true, force: true })
    ok(`App files removed: ${APP_HOME}`)
    info("Node.js and the npm package itself were NOT removed.")
    info("To fully uninstall: npm uninstall -g orbix-nichefinder-x")
  } else {
    info("App directory not found — nothing to remove.")
  }
  console.log("")
  process.exit(0)
}

// ── COPY APP FILES IF NEEDED ────────────────────────────────
const needsCopy = !fs.existsSync(APP_HOME) ||
                  !fs.existsSync(path.join(APP_HOME, "src", "orbix-nichefinder-x.jsx")) ||
                  isReset

if (needsCopy) {
  console.log(`  ${C.yellow}>>> Setting up app files...${C.reset}`)
  info(`Destination: ${APP_HOME}`)

  // Recursive copy helper
  const copyDir = (src, dest) => {
    fs.mkdirSync(dest, { recursive: true })
    for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
      const srcPath  = path.join(src, entry.name)
      const destPath = path.join(dest, entry.name)
      if (entry.isDirectory()) {
        copyDir(srcPath, destPath)
      } else {
        fs.copyFileSync(srcPath, destPath)
      }
    }
  }

  copyDir(APP_SRC, APP_HOME)
  ok("App files ready")
  console.log("")
} else {
  info(`Using existing app files: ${APP_HOME}`)
  console.log("")
}

// ── CHECK / INSTALL DEPENDENCIES ───────────────────────────
const nodeModules = path.join(APP_HOME, "node_modules")
const pkgJson     = path.join(APP_HOME, "package.json")

if (!fs.existsSync(nodeModules) || isReset) {
  console.log(`  ${C.yellow}>>> Installing dependencies (first run — ~30 seconds)...${C.reset}`)

  // Write a minimal package.json into the working directory
  const appPkg = {
    name: "nichefinder-x-app",
    private: true,
    version: VERSION,
    type: "module",
    scripts: { dev: "vite", build: "vite build" },
    dependencies: { react: "^18.3.1", "react-dom": "^18.3.1" },
    devDependencies: {
      "@vitejs/plugin-react": "^4.3.4",
      "vite": "^6.3.5"
    }
  }
  fs.writeFileSync(pkgJson, JSON.stringify(appPkg, null, 2))

  try {
    cp.execSync("npm install", {
      cwd: APP_HOME,
      stdio: "inherit",
    })
    ok("Dependencies installed")
  } catch (e) {
    fail("npm install failed. Check your internet connection.")
    process.exit(1)
  }
  console.log("")
}

// ── START VITE ─────────────────────────────────────────────
console.log(`  ${C.yellow}>>> Starting NicheFinder X...${C.reset}`)
info("Vite will open your browser automatically.")
info("If port 5173 is busy, Vite picks the next free port.")
info("Check the output below for the actual URL.")
info("Press Ctrl+C to stop the server.")
console.log("")

// Find the vite binary inside the working directory
const viteBin = path.join(APP_HOME, "node_modules", ".bin", "vite")

if (!fs.existsSync(viteBin)) {
  fail("Vite not found. Run: nichefinder --reset")
  process.exit(1)
}

const server = cp.spawn(viteBin, ["--open"], {
  cwd: APP_HOME,
  stdio: "inherit",
  shell: process.platform === "win32",
})

server.on("error", err => {
  fail(`Failed to start server: ${err.message}`)
  process.exit(1)
})

server.on("exit", code => {
  if (code !== 0 && code !== null) {
    fail(`Server exited with code ${code}`)
  }
  process.exit(code || 0)
})

// Forward Ctrl+C
process.on("SIGINT", () => {
  server.kill("SIGINT")
})
process.on("SIGTERM", () => {
  server.kill("SIGTERM")
})
