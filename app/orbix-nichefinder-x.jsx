import { useState, useRef, useCallback, useEffect } from "react"

// ─────────────────────────────────────────────
// BRAND SYSTEM — Orbix Titanium & Glass
// ─────────────────────────────────────────────
const B = {
  bg:        "#0D1117",
  card:      "#161B22",
  card2:     "#1C2128",
  border:    "#30363D",
  borderHi:  "#484F58",
  blue:      "#2B5BA8",
  blueHi:    "#3B72CC",
  blueGlow:  "rgba(43,91,168,0.25)",
  gold:      "#B8962E",
  goldHi:    "#D4A832",
  goldGlow:  "rgba(184,150,46,0.2)",
  silver:    "#8E9BAE",
  white:     "#E6EDF3",
  muted:     "#656D76",
  success:   "#3FB950",
  error:     "#F85149",
  warning:   "#D29922",
  black:     "#010409",
}

// ─────────────────────────────────────────────
// INDUSTRY PRESETS
// ─────────────────────────────────────────────
const INDUSTRIES = [
  { label: "— All / General —",    kw: "" },
  { label: "Real Estate",          kw: "realtor realestate property agent" },
  { label: "Finance & Investing",  kw: "finance investing stocks trading" },
  { label: "Tech & AI",            kw: "tech AI artificial intelligence software" },
  { label: "Marketing & Growth",   kw: "marketing digitalmarketing growth hacking" },
  { label: "Health & Wellness",    kw: "health wellness fitness nutrition" },
  { label: "E-Commerce & Retail",  kw: "ecommerce shopify retail amazon FBA" },
  { label: "Crypto & Web3",        kw: "crypto blockchain web3 NFT defi" },
  { label: "SaaS & Startups",      kw: "saas startup founder entrepreneur" },
  { label: "Content Creation",     kw: "contentcreator youtube creator influencer" },
  { label: "Coaching & Education", kw: "coaching education mentor training" },
  { label: "Food & Lifestyle",     kw: "food foodie recipe lifestyle blogger" },
  { label: "Fashion & Beauty",     kw: "fashion beauty style ootd skincare" },
  { label: "Sports & Fitness",     kw: "sports fitness athlete workout gym" },
  { label: "Travel & Hospitality", kw: "travel hotel tourism destination" },
  { label: "Legal & Consulting",   kw: "lawyer attorney legal consulting" },
  { label: "Automotive",           kw: "automotive cars vehicle dealership" },
  { label: "Music & Entertainment",kw: "music entertainment artist band podcast" },
  { label: "Politics & News",      kw: "politics news journalist media reporter" },
]

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
const fmt = n => {
  if (!n && n !== 0) return "—"
  if (n >= 1_000_000) return (n / 1_000_000).toFixed(1) + "M"
  if (n >= 1_000)     return (n / 1_000).toFixed(1) + "K"
  return n.toLocaleString()
}

const parseUser = u => ({
  id:          u.id || u.userId || u.id_str || Math.random().toString(36),
  name:        u.name || u.displayName || "",
  handle:      (u.userName || u.screen_name || u.username || "").replace(/^@/, ""),
  followers:   u.followers_count  || u.followersCount  || u.public_metrics?.followers_count || 0,
  following:   u.friends_count    || u.followingCount  || u.public_metrics?.following_count || 0,
  tweets:      u.statuses_count   || u.tweetsCount     || u.public_metrics?.tweet_count     || 0,
  bio:         u.description || u.bio || "",
  verified:    !!(u.verified || u.isVerified),
  blueVerified:!!(u.is_blue_verified || u.blueVerified),
  avatar:      u.profile_image_url || u.profileImageUrl || u.profile_image_url_https || "",
  location:    u.location || "",
  createdAt:   u.created_at || u.createdAt || "",
})

const sleep = ms => new Promise(r => setTimeout(r, ms))

const exportCSV = (results, nicheLabel) => {
  const headers = ["Rank","Name","Handle","Followers","Following","Tweets","Verified","Location","Bio","X URL"]
  const rows = results.map((u, i) => [
    i + 1,
    `"${(u.name || "").replace(/"/g, '""')}"`,
    `@${u.handle}`,
    u.followers,
    u.following,
    u.tweets,
    u.verified || u.blueVerified ? "Yes" : "No",
    `"${(u.location || "").replace(/"/g, '""')}"`,
    `"${(u.bio || "").replace(/"/g, '""')}"`,
    `https://x.com/${u.handle}`,
  ])
  const csv = [headers.join(","), ...rows.map(r => r.join(","))].join("\n")
  const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" })
  const a = document.createElement("a")
  a.href = URL.createObjectURL(blob)
  a.download = `orbix-niche-${nicheLabel.replace(/\s+/g,"-").toLowerCase()}-${Date.now()}.csv`
  a.click()
}

// ─────────────────────────────────────────────
// ICON SVGs (inline, no emoji)
// ─────────────────────────────────────────────
const Icon = ({ d, size=16, color="currentColor", style={} }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2"
    strokeLinecap="round" strokeLinejoin="round" style={style}>
    <path d={d}/>
  </svg>
)

const icons = {
  search: "M21 21l-4.35-4.35M17 11A6 6 0 1 1 5 11a6 6 0 0 1 12 0z",
  save:   "M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2zM17 21v-8H7v8M7 3v5h8",
  csv:    "M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8zM14 2v6h6M16 13H8M16 17H8M10 9H8",
  copy:   "M8 4H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8l-6-6H8zM14 2v6h6",
  trash:  "M3 6h18M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6M10 11v6M14 11v6M9 6V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2",
  key:    "M21 2l-2 2m-7.61 7.61a5.5 5.5 0 1 1-7.778 7.778 5.5 5.5 0 0 1 7.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4",
  x:      "M18 6 6 18M6 6l12 12",
  stop:   "M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0zM9 9h6v6H9z",
  check:  "M20 6 9 17l-5-5",
  eye:    "M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8zM12 9a3 3 0 1 0 0 6 3 3 0 0 0 0-6z",
  eyeOff: "M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24M1 1l22 22",
  tag:    "M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82zM7 7h.01",
  filter: "M22 3H2l8 9.46V19l4 2v-8.54L22 3z",
  sort:   "M3 6h18M7 12h10M11 18h2",
  users:  "M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2M9 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75",
  star:   "M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z",
  link:   "M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71",
  info:   "M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10zM12 16v-4M12 8h.01",
}

// ─────────────────────────────────────────────
// BUTTON COMPONENT
// ─────────────────────────────────────────────
const Btn = ({ children, onClick, disabled, variant="primary", size="md", style={}, title="" }) => {
  const base = {
    display:"inline-flex", alignItems:"center", gap:6, cursor: disabled ? "not-allowed" : "pointer",
    border:"1px solid", borderRadius:8, fontWeight:600, transition:"all 0.18s ease",
    opacity: disabled ? 0.5 : 1, outline:"none", fontFamily:"inherit",
    ...(size === "sm" ? { padding:"6px 12px", fontSize:12 } : { padding:"9px 18px", fontSize:13 }),
  }
  const variants = {
    primary: { background:`linear-gradient(135deg,${B.blue},${B.blueHi})`, borderColor:B.blueHi, color:B.white, boxShadow:`0 0 12px ${B.blueGlow}` },
    gold:    { background:`linear-gradient(135deg,${B.gold},${B.goldHi})`, borderColor:B.goldHi, color:B.black, boxShadow:`0 0 10px ${B.goldGlow}` },
    ghost:   { background:"transparent", borderColor:B.border, color:B.silver },
    danger:  { background:"transparent", borderColor:B.error, color:B.error },
    success: { background:`${B.success}22`, borderColor:B.success, color:B.success },
  }
  return (
    <button onClick={onClick} disabled={disabled} title={title}
      style={{ ...base, ...variants[variant], ...style }}
      onMouseEnter={e => { if (!disabled) { e.currentTarget.style.filter="brightness(1.15)"; e.currentTarget.style.transform="translateY(-1px)" } }}
      onMouseLeave={e => { e.currentTarget.style.filter=""; e.currentTarget.style.transform="" }}>
      {children}
    </button>
  )
}

// ─────────────────────────────────────────────
// INPUT COMPONENT
// ─────────────────────────────────────────────
const Input = ({ value, onChange, placeholder, type="text", style={}, readOnly=false }) => (
  <input value={value} onChange={e => onChange(e.target.value)} placeholder={placeholder}
    type={type} readOnly={readOnly}
    style={{
      background:B.bg, border:`1px solid ${B.border}`, borderRadius:8, color:B.white,
      padding:"8px 12px", fontSize:13, width:"100%", outline:"none", fontFamily:"inherit",
      boxSizing:"border-box", transition:"border-color 0.15s",
      ...(readOnly ? { cursor:"default", color:B.silver } : {}), ...style,
    }}
    onFocus={e  => { e.target.style.borderColor = B.blueHi }}
    onBlur={e   => { e.target.style.borderColor = B.border  }}
  />
)

// ─────────────────────────────────────────────
// SECTION CARD
// ─────────────────────────────────────────────
const Card = ({ children, style={} }) => (
  <div style={{ background:B.card, border:`1px solid ${B.border}`, borderRadius:12, padding:16, ...style }}>
    {children}
  </div>
)

const SectionTitle = ({ icon, label }) => (
  <div style={{ display:"flex", alignItems:"center", gap:8, marginBottom:12 }}>
    <svg width={14} height={14} viewBox="0 0 24 24" fill="none" stroke={B.gold} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
      <path d={icon}/>
    </svg>
    <span style={{ fontSize:11, fontWeight:700, color:B.gold, textTransform:"uppercase", letterSpacing:"0.08em" }}>{label}</span>
  </div>
)

// ─────────────────────────────────────────────
// STAT PILL
// ─────────────────────────────────────────────
const Stat = ({ label, value, color = B.blue }) => (
  <div style={{ background:B.card2, border:`1px solid ${B.border}`, borderRadius:10, padding:"10px 16px", textAlign:"center" }}>
    <div style={{ fontSize:20, fontWeight:700, color }}>{value}</div>
    <div style={{ fontSize:11, color:B.muted, marginTop:2 }}>{label}</div>
  </div>
)

// ─────────────────────────────────────────────
// TOAST NOTIFICATION
// ─────────────────────────────────────────────
const Toast = ({ msg, type="success", onClose }) => (
  <div style={{
    position:"fixed", bottom:24, right:24, zIndex:999,
    background: type === "success" ? `${B.success}22` : `${B.error}22`,
    border:`1px solid ${type === "success" ? B.success : B.error}`,
    borderRadius:10, padding:"12px 18px", display:"flex", alignItems:"center", gap:10,
    color: type === "success" ? B.success : B.error, fontSize:13, fontWeight:600,
    boxShadow:"0 8px 32px rgba(0,0,0,0.5)", animation:"slideIn 0.2s ease",
  }}>
    <svg width={16} height={16} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
      <path d={type === "success" ? icons.check : icons.x}/>
    </svg>
    {msg}
    <button onClick={onClose} style={{ background:"none", border:"none", color:"inherit", cursor:"pointer", marginLeft:4, padding:0 }}>✕</button>
  </div>
)

// ─────────────────────────────────────────────
// PROGRESS BAR
// ─────────────────────────────────────────────
const ProgressBar = ({ value }) => (
  <div style={{ height:4, background:B.border, borderRadius:4, overflow:"hidden", marginTop:8 }}>
    <div style={{ height:"100%", width:`${value}%`, background:`linear-gradient(90deg,${B.blue},${B.blueHi})`,
      borderRadius:4, transition:"width 0.3s ease", boxShadow:`0 0 8px ${B.blueGlow}` }}/>
  </div>
)

// ─────────────────────────────────────────────
// AVATAR FALLBACK
// ─────────────────────────────────────────────
const Avatar = ({ src, name, size=36 }) => {
  const [err, setErr] = useState(false)
  if (!src || err) {
    const initials = (name||"?").split(" ").map(w=>w[0]).join("").toUpperCase().slice(0,2)
    return (
      <div style={{ width:size, height:size, borderRadius:"50%", background:`linear-gradient(135deg,${B.blue},${B.blueHi})`,
        display:"flex", alignItems:"center", justifyContent:"center", fontSize:size/3, fontWeight:700, color:B.white, flexShrink:0 }}>
        {initials}
      </div>
    )
  }
  return <img src={src.replace("_normal","_bigger")} alt={name} onError={()=>setErr(true)}
    style={{ width:size, height:size, borderRadius:"50%", objectFit:"cover", flexShrink:0 }}/>
}

// ─────────────────────────────────────────────
// MAIN COMPONENT
// ─────────────────────────────────────────────
export default function NicheFinderX() {
  // Config state
  const [apiKey,        setApiKey]        = useState("")
  const [showKey,       setShowKey]       = useState(false)
  const [niche,         setNiche]         = useState("")
  const [industry,      setIndustry]      = useState("")
  const [minFollowers,  setMinFollowers]  = useState(1000)
  const [maxResults,    setMaxResults]    = useState(50)
  const [verifiedOnly,  setVerifiedOnly]  = useState(false)

  // App state
  const [savedNiches,   setSavedNiches]   = useState([
    { id:1, label:"Real Estate Investors", industry:"Real Estate",   kw:"real estate investor property", minF:5000 },
    { id:2, label:"AI Startup Founders",   industry:"Tech & AI",     kw:"AI startup founder",            minF:10000 },
    { id:3, label:"Digital Marketing",     industry:"Marketing & Growth", kw:"digital marketing agency", minF:2000 },
  ])
  const [results,       setResults]       = useState([])
  const [loading,       setLoading]       = useState(false)
  const [progress,      setProgress]      = useState(0)
  const [statusMsg,     setStatusMsg]     = useState("")
  const [error,         setError]         = useState("")
  const [sortBy,        setSortBy]        = useState("followers")
  const [toast,         setToast]         = useState(null)
  const [activeNiche,   setActiveNiche]   = useState(null)
  const [hoveredRow,    setHoveredRow]    = useState(null)
  const [showCloseModal,  setShowCloseModal]  = useState(false)
  const [autoCheckUpdates,setAutoCheckUpdates] = useState(() => {
    try { return localStorage.getItem("nfx_autocheck") !== "false" } catch { return true }
  })
  const [updateInfo,      setUpdateInfo]      = useState(null)   // { version, changelog, files }
  const [updateStatus,    setUpdateStatus]    = useState("")      // idle | checking | upToDate | available | downloading | error
  const [showUpdateModal, setShowUpdateModal] = useState(false)

  const abortRef = useRef(false)

  const showToast = (msg, type="success") => {
    setToast({ msg, type })
    setTimeout(() => setToast(null), 3500)
  }

  // ── UPDATE SYSTEM ──────────────────────────────────────────
  const CURRENT_VERSION = "1.05"
  const VERSION_URL     = "https://raw.githubusercontent.com/roughboy99/orbix-nichefinder-x/main/version.json"

  const parseVer = v => v.split(".").map(Number).reduce((a,n,i) => a + n * Math.pow(100, 2-i), 0)

  const checkForUpdates = async (silent = false) => {
    setUpdateStatus("checking")
    if (!silent) setShowUpdateModal(true)
    try {
      const res  = await fetch(VERSION_URL + "?t=" + Date.now())
      if (!res.ok) throw new Error("Could not reach update server")
      const data = await res.json()
      if (parseVer(data.version) > parseVer(CURRENT_VERSION)) {
        setUpdateInfo(data)
        setUpdateStatus("available")
        setShowUpdateModal(true)
      } else {
        setUpdateStatus("upToDate")
        if (!silent) setShowUpdateModal(true)
      }
    } catch(e) {
      setUpdateStatus("error")
      if (!silent) { setShowUpdateModal(true) }
    }
  }

  // Detect platform for platform-aware updater download
  const isWindows = navigator.platform?.toLowerCase().includes("win") ||
                    navigator.userAgent?.toLowerCase().includes("windows")

  const downloadUpdate = async () => {
    if (!updateInfo) return
    setUpdateStatus("downloading")
    try {
      // 1. Download the new JSX
      const jsxRes  = await fetch(updateInfo.files.app)
      if (!jsxRes.ok) throw new Error("Failed to download app file")
      const jsxText = await jsxRes.text()
      const jsxBlob = new Blob([jsxText], { type: "text/plain" })
      const jsxUrl  = URL.createObjectURL(jsxBlob)
      const jsxA    = document.createElement("a")
      jsxA.href     = jsxUrl
      jsxA.download = "orbix-nichefinder-x.jsx"
      jsxA.click()
      URL.revokeObjectURL(jsxUrl)
      await new Promise(r => setTimeout(r, 800))

      // 2. Download platform-correct updater
      const updaterUrl  = isWindows
        ? updateInfo.files.updaterWindows
        : updateInfo.files.updaterMacLinux
      const updaterName = isWindows ? "NicheFinderX-Update.bat" : "NicheFinderX-Update.sh"

      const updRes  = await fetch(updaterUrl || updateInfo.files.updaterWindows)
      if (!updRes.ok) throw new Error("Failed to download updater")
      const updText = await updRes.text()
      const updBlob = new Blob([updText], { type: "text/plain" })
      const updUrl  = URL.createObjectURL(updBlob)
      const updA    = document.createElement("a")
      updA.href     = updUrl
      updA.download = updaterName
      updA.click()
      URL.revokeObjectURL(updUrl)

      setUpdateStatus("done")
    } catch(e) {
      setUpdateStatus("error")
    }
  }

  // Auto-check on startup
  useEffect(() => {
    if (autoCheckUpdates) {
      setTimeout(() => checkForUpdates(true), 2500)
    }
  }, [])

  const toggleAutoCheck = () => {
    const next = !autoCheckUpdates
    setAutoCheckUpdates(next)
    try { localStorage.setItem("nfx_autocheck", String(next)) } catch {}
  }

  const buildQuery = useCallback(() => {
    const parts = [niche.trim()]
    const ind = INDUSTRIES.find(i => i.label === industry)
    if (ind?.kw) parts.push(ind.kw)
    return parts.filter(Boolean).join(" ")
  }, [niche, industry])

  const saveCurrentNiche = () => {
    if (!niche.trim()) { setError("Enter a niche keyword first"); return }
    const entry = {
      id:       Date.now(),
      label:    niche.trim(),
      industry: industry || "General",
      kw:       buildQuery(),
      minF:     minFollowers,
    }
    setSavedNiches(prev => [entry, ...prev.filter(n => n.label !== niche.trim())])
    showToast(`Niche "${niche}" saved!`)
  }

  const loadSavedNiche = n => {
    setNiche(n.label)
    setIndustry(n.industry !== "General" ? n.industry : "")
    setMinFollowers(n.minF || 1000)
    setActiveNiche(n.id)
  }

  const deleteSavedNiche = (id, e) => {
    e.stopPropagation()
    setSavedNiches(prev => prev.filter(n => n.id !== id))
    if (activeNiche === id) setActiveNiche(null)
  }

  // ── SEARCH — TwitterAPI.io direct ──
  const startSearch = async () => {
    if (!apiKey.trim()) { setError("TwitterAPI.io key is required"); return }
    if (!niche.trim())  { setError("Enter a niche keyword to search"); return }

    setError("")
    setLoading(true)
    setResults([])
    setProgress(5)
    abortRef.current = false

    const query = buildQuery()
    setStatusMsg("Connecting to TwitterAPI.io...")

    try {
      const allUsers = new Map()
      let cursor = ""
      let page   = 0
      const maxPages = Math.ceil(maxResults / 20) + 4

      while (allUsers.size < maxResults * 1.5 && page < maxPages && !abortRef.current) {
        const url = new URL("https://api.twitterapi.io/twitter/user/search")
        url.searchParams.set("query", query)
        if (cursor) url.searchParams.set("cursor", cursor)

        setStatusMsg(`Page ${page + 1} — fetching users (${allUsers.size} found so far)...`)
        setProgress(Math.min(88, 5 + (page / maxPages) * 83))

        const res = await fetch(url.toString(), {
          headers: { "X-API-Key": apiKey.trim(), "Content-Type": "application/json" }
        })

        if (res.status === 401) throw new Error("Invalid API key. Check your TwitterAPI.io credentials.")
        if (res.status === 429) throw new Error("Rate limit reached. Wait a moment and try again.")
        if (!res.ok) { const t = await res.text(); throw new Error(`API Error ${res.status}: ${t}`) }

        const data = await res.json()
        const raw  = data.users || data.data?.users || data.results || data.data || []
        const users = Array.isArray(raw) ? raw : []

        if (!users.length && page === 0) throw new Error("No users returned. Check your query or API key.")

        users.forEach(u => {
          const p = parseUser(u)
          if (!p.handle) return
          if (p.followers < minFollowers) return
          if (verifiedOnly && !p.verified && !p.blueVerified) return
          allUsers.set(p.handle.toLowerCase(), p)
        })

        cursor = data.next_cursor || data.cursor || data.meta?.next_cursor || data.next_page || ""
        page++
        if (!cursor || allUsers.size >= maxResults * 1.5) break
        await sleep(250)
      }

      if (abortRef.current) { setStatusMsg(`Search stopped — ${allUsers.size} users collected`); setLoading(false); return }

      const sorted = [...allUsers.values()]
        .sort((a, b) => b.followers - a.followers)
        .slice(0, maxResults)

      setResults(sorted)
      setProgress(100)
      setStatusMsg(`Search complete — ${sorted.length} influencers ranked`)
      showToast(`Found ${sorted.length} influencers!`)
    } catch (e) {
      setError(e.message || "Search failed. Verify API key and try again.")
      setStatusMsg("")
      setProgress(0)
    } finally {
      setLoading(false)
    }
  }

  const stopSearch = () => { abortRef.current = true }

  const sorted = [...results].sort((a, b) => {
    if (sortBy === "followers") return b.followers  - a.followers
    if (sortBy === "tweets")    return b.tweets     - a.tweets
    if (sortBy === "following") return b.following  - a.following
    return a.name.localeCompare(b.name)
  })

  const totalFollowers = results.reduce((s, u) => s + u.followers, 0)
  const avgFollowers   = results.length ? Math.round(totalFollowers / results.length) : 0

  // ─── RENDER ───
  return (
    <div style={{ fontFamily:"'Fira Sans','Inter',system-ui,sans-serif", background:B.bg,
      color:B.white, minHeight:"100vh", display:"flex", flexDirection:"column" }}>

      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Fira+Sans:wght@300;400;500;600;700&family=Fira+Code:wght@400;500&display=swap');
        * { box-sizing:border-box; }
        ::-webkit-scrollbar { width:6px; height:6px; }
        ::-webkit-scrollbar-track { background:${B.bg}; }
        ::-webkit-scrollbar-thumb { background:${B.border}; border-radius:3px; }
        ::-webkit-scrollbar-thumb:hover { background:${B.borderHi}; }
        select option { background:${B.card2}; color:${B.white}; }
        @keyframes spin { to { transform:rotate(360deg); } }
        @keyframes pulse { 0%,100%{opacity:1} 50%{opacity:0.5} }
        @keyframes slideIn { from{transform:translateX(20px);opacity:0} to{transform:translateX(0);opacity:1} }
        @keyframes fadeIn { from{opacity:0;transform:translateY(4px)} to{opacity:1;transform:translateY(0)} }
        .result-row:hover td { background:${B.card2} !important; }
        input[type=range] { -webkit-appearance:none; height:4px; background:${B.border}; border-radius:2px; outline:none; }
        input[type=range]::-webkit-slider-thumb { -webkit-appearance:none; width:16px; height:16px; border-radius:50%; background:${B.blue}; cursor:pointer; border:2px solid ${B.blueHi}; box-shadow:0 0 8px ${B.blueGlow}; }
        .tag-chip:hover { background:${B.card2} !important; border-color:${B.blueHi} !important; }
      `}</style>

      {/* ── HEADER ── */}
      <div style={{ background:B.card, borderBottom:`1px solid ${B.border}`,
        padding:"0 24px", height:58, display:"flex", alignItems:"center", justifyContent:"space-between",
        position:"sticky", top:0, zIndex:100, backdropFilter:"blur(12px)" }}>

        <div style={{ display:"flex", alignItems:"center", gap:12 }}>
          {/* Logo mark */}
          <div style={{ width:32, height:32, borderRadius:8, background:`linear-gradient(135deg,${B.blue},${B.blueHi})`,
            display:"flex", alignItems:"center", justifyContent:"center", boxShadow:`0 0 14px ${B.blueGlow}` }}>
            <svg width={18} height={18} viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <path d={icons.users}/>
            </svg>
          </div>
          <div>
            <div style={{ fontSize:15, fontWeight:700, color:B.white, lineHeight:1 }}>
              Orbix <span style={{ color:B.gold }}>NicheFinder</span>
              <span style={{ fontSize:11, marginLeft:6, background:B.blueGlow, color:B.blueHi,
                padding:"2px 6px", borderRadius:4, fontWeight:600, border:`1px solid ${B.blueHi}40` }}>X</span>
            </div>
            <div style={{ fontSize:10, color:B.muted, marginTop:1, display:"flex", alignItems:"center", gap:5 }}>
              Powered by TwitterAPI.io · Run locally or on your server
              <span style={{ color:B.border }}>·</span>
              <a href="https://www.skool.com/aimate/about?ref=ae32f0f121324efbab8e269e59106b04"
                target="_blank" rel="noopener noreferrer"
                style={{ color:B.gold, textDecoration:"none", fontWeight:600 }}
                onMouseEnter={e=>e.currentTarget.style.color=B.goldHi}
                onMouseLeave={e=>e.currentTarget.style.color=B.gold}>
                The perfect companion to Andy Hafell's Content Mate
              </a>
            </div>
          </div>
        </div>

        <div style={{ display:"flex", alignItems:"center", gap:12 }}>
          {loading && (
            <div style={{ display:"flex", alignItems:"center", gap:6, color:B.blueHi, fontSize:12, fontWeight:500 }}>
              <div style={{ width:8, height:8, borderRadius:"50%", background:B.blueHi, animation:"pulse 1s infinite" }}/>
              {statusMsg || "Searching…"}
            </div>
          )}
          {!loading && results.length > 0 && (
            <div style={{ fontSize:12, color:B.success, fontWeight:600, display:"flex", alignItems:"center", gap:5 }}>
              <svg width={14} height={14} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d={icons.check}/></svg>
              {results.length} results ready
            </div>
          )}
          <div style={{ height:20, width:1, background:B.border }}/>
          <a href="https://twitterapi.io?ref=roughboy666" target="_blank" rel="noopener noreferrer"
            style={{ fontSize:11, color:B.muted, textDecoration:"none", display:"flex", alignItems:"center", gap:4 }}
            onMouseEnter={e=>e.currentTarget.style.color=B.silver}
            onMouseLeave={e=>e.currentTarget.style.color=B.muted}>
            <svg width={12} height={12} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d={icons.link}/></svg>
            TwitterAPI.io
          </a>
          <div style={{ height:20, width:1, background:B.border }}/>
          {/* ── CLOSE BUTTON ── */}
          <button
            onClick={()=>setShowCloseModal(true)}
            title="Close NicheFinder X"
            style={{ display:"flex", alignItems:"center", gap:5, padding:"5px 11px", borderRadius:7,
              border:`1px solid ${B.error}55`, background:`${B.error}15`, color:B.error,
              cursor:"pointer", fontSize:12, fontWeight:600, fontFamily:"inherit",
              transition:"all 0.15s" }}
            onMouseEnter={e=>{ e.currentTarget.style.background=`${B.error}30`; e.currentTarget.style.borderColor=B.error }}
            onMouseLeave={e=>{ e.currentTarget.style.background=`${B.error}15`; e.currentTarget.style.borderColor=`${B.error}55` }}>
            <svg width={13} height={13} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <path d={icons.x}/>
            </svg>
            Close App
          </button>
        </div>
      </div>

      {/* ── UPDATE BANNER ── */}
      {updateStatus === "available" && !showUpdateModal && (
        <div style={{ background:`linear-gradient(90deg,${B.gold}22,${B.goldGlow})`,
          borderBottom:`1px solid ${B.gold}66`, padding:"8px 20px",
          display:"flex", alignItems:"center", justifyContent:"space-between", gap:12, flexShrink:0 }}>
          <div style={{ display:"flex", alignItems:"center", gap:8, fontSize:12 }}>
            <svg width={14} height={14} viewBox="0 0 24 24" fill="none" stroke={B.gold} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <path d="M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10zM12 8v4M12 16h.01"/>
            </svg>
            <span style={{ color:B.gold, fontWeight:600 }}>
              Update available — v{updateInfo?.version}
            </span>
            <span style={{ color:B.muted }}>You are on v{CURRENT_VERSION}</span>
          </div>
          <div style={{ display:"flex", gap:8 }}>
            <button onClick={()=>setShowUpdateModal(true)}
              style={{ padding:"4px 12px", borderRadius:6, border:`1px solid ${B.gold}`,
                background:`${B.gold}22`, color:B.gold, cursor:"pointer", fontSize:12,
                fontWeight:600, fontFamily:"inherit" }}>
              View Update
            </button>
            <button onClick={()=>setUpdateStatus("idle")}
              style={{ padding:"4px 8px", borderRadius:6, border:"none",
                background:"transparent", color:B.muted, cursor:"pointer", fontSize:12, fontFamily:"inherit" }}>
              Dismiss
            </button>
          </div>
        </div>
      )}

      {/* ── MAIN LAYOUT ── */}}
      <div style={{ display:"flex", flex:1, height:"calc(100vh - 58px)", overflow:"hidden" }}>

        {/* ── LEFT PANEL ── */}
        <div style={{ width:300, minWidth:300, borderRight:`1px solid ${B.border}`,
          overflowY:"auto", display:"flex", flexDirection:"column", gap:12, padding:16, background:B.black }}>

          {/* API KEY */}
          <Card>
            <SectionTitle icon={icons.key} label="API Configuration"/>
            <div style={{ position:"relative" }}>
              <Input value={apiKey} onChange={setApiKey} type={showKey?"text":"password"}
                placeholder="Paste your TwitterAPI.io key…" style={{ paddingRight:38 }}/>
              <button onClick={()=>setShowKey(!showKey)} title={showKey?"Hide":"Show"}
                style={{ position:"absolute", right:10, top:"50%", transform:"translateY(-50%)",
                  background:"none", border:"none", cursor:"pointer", color:B.muted, padding:0, display:"flex" }}>
                <svg width={14} height={14} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d={showKey ? icons.eyeOff : icons.eye}/>
                </svg>
              </button>
            </div>
            <div style={{ marginTop:8, padding:"8px 10px", background:`${B.warning}11`, border:`1px solid ${B.warning}44`,
              borderRadius:8, fontSize:11, color:B.warning, lineHeight:1.5 }}>
              <b>Requires TwitterAPI.io key.</b> Run locally with{" "}
              <code style={{fontFamily:"monospace",background:`${B.warning}22`,padding:"1px 4px",borderRadius:3}}>npm run dev</code>{" "}
              or deploy on your own server. Get your key at{" "}
              <a href="https://twitterapi.io?ref=roughboy666" target="_blank" rel="noopener noreferrer"
                style={{ color:B.goldHi, textDecoration:"underline" }}>twitterapi.io</a>
            </div>
          </Card>

          {/* SEARCH CONFIG */}
          <Card>
            <SectionTitle icon={icons.search} label="Search Configuration"/>
            <div style={{ display:"flex", flexDirection:"column", gap:10 }}>

              <div>
                <label style={{ fontSize:11, color:B.muted, fontWeight:600, display:"block", marginBottom:4 }}>NICHE / KEYWORD</label>
                <Input value={niche} onChange={v=>{setNiche(v);setError("")}}
                  placeholder="e.g. real estate investors, AI tools…"/>
              </div>

              <div>
                <label style={{ fontSize:11, color:B.muted, fontWeight:600, display:"block", marginBottom:4 }}>INDUSTRY PRESET</label>
                <select value={industry} onChange={e=>setIndustry(e.target.value)}
                  style={{ background:B.bg, border:`1px solid ${B.border}`, borderRadius:8, color:B.white,
                    padding:"8px 12px", fontSize:13, width:"100%", outline:"none", cursor:"pointer" }}>
                  {INDUSTRIES.map(i=>(
                    <option key={i.label} value={i.label==="— All / General —"?"":i.label}>{i.label}</option>
                  ))}
                </select>
              </div>

              <div>
                <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", marginBottom:6 }}>
                  <label style={{ fontSize:11, color:B.muted, fontWeight:600 }}>MIN FOLLOWERS</label>
                  <span style={{ fontSize:12, color:B.blueHi, fontWeight:700 }}>{fmt(minFollowers)}</span>
                </div>
                <input type="range" min={100} max={500000} step={100} value={minFollowers}
                  onChange={e=>setMinFollowers(Number(e.target.value))} style={{ width:"100%" }}/>
                <div style={{ display:"flex", justifyContent:"space-between", fontSize:10, color:B.muted, marginTop:3 }}>
                  <span>100</span><span>500K</span>
                </div>
              </div>

              <div>
                <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", marginBottom:6 }}>
                  <label style={{ fontSize:11, color:B.muted, fontWeight:600 }}>MAX RESULTS</label>
                  <span style={{ fontSize:12, color:B.blueHi, fontWeight:700 }}>{maxResults}</span>
                </div>
                <input type="range" min={10} max={100} step={5} value={maxResults}
                  onChange={e=>setMaxResults(Number(e.target.value))} style={{ width:"100%" }}/>
                <div style={{ display:"flex", justifyContent:"space-between", fontSize:10, color:B.muted, marginTop:3 }}>
                  <span>10</span><span>100</span>
                </div>
              </div>

              <div style={{ display:"flex", alignItems:"center", gap:8, cursor:"pointer" }}
                onClick={()=>setVerifiedOnly(!verifiedOnly)}>
                <div style={{ width:16, height:16, borderRadius:4, border:`2px solid ${verifiedOnly?B.blue:B.border}`,
                  background:verifiedOnly?B.blue:"transparent", display:"flex", alignItems:"center",
                  justifyContent:"center", transition:"all 0.15s", flexShrink:0 }}>
                  {verifiedOnly && <svg width={10} height={10} viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round"><path d={icons.check}/></svg>}
                </div>
                <span style={{ fontSize:12, color:B.silver }}>Verified accounts only</span>
              </div>

              {error && (
                <div style={{ padding:"8px 12px", background:`${B.error}15`, border:`1px solid ${B.error}44`,
                  borderRadius:8, fontSize:12, color:B.error }}>
                  {error}
                </div>
              )}

              {/* ACTION BUTTONS */}
              <div style={{ display:"flex", gap:8, marginTop:4 }}>
                <Btn onClick={saveCurrentNiche} variant="ghost" size="sm" style={{ flex:"none" }}>
                  <svg width={13} height={13} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d={icons.save}/></svg>
                  Save Niche
                </Btn>
                {loading
                  ? <Btn onClick={stopSearch} variant="danger" size="sm" style={{ flex:1 }}>
                      <svg width={13} height={13} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d={icons.stop}/></svg>
                      Stop
                    </Btn>
                  : <Btn onClick={startSearch} variant="primary" size="sm" style={{ flex:1 }}>
                      <svg width={13} height={13} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d={icons.search}/></svg>
                      Search X
                    </Btn>
                }
              </div>

              {loading && <ProgressBar value={progress}/>}
            </div>
          </Card>

          {/* SAVED NICHES */}
          <Card>
            <SectionTitle icon={icons.tag} label="Saved Niches"/>
            {savedNiches.length === 0 ? (
              <div style={{ textAlign:"center", color:B.muted, fontSize:12, padding:"16px 0" }}>
                No saved niches yet. Fill in a search and click <b style={{color:B.silver}}>Save Niche</b>.
              </div>
            ) : (
              <div style={{ display:"flex", flexDirection:"column", gap:6 }}>
                {savedNiches.map(n => (
                  <div key={n.id} className="tag-chip" onClick={()=>loadSavedNiche(n)}
                    style={{ display:"flex", alignItems:"center", justifyContent:"space-between",
                      background: activeNiche===n.id ? `${B.blue}22` : B.bg,
                      border:`1px solid ${activeNiche===n.id ? B.blue : B.border}`,
                      borderRadius:8, padding:"7px 10px", cursor:"pointer", transition:"all 0.15s" }}>
                    <div style={{ flex:1, minWidth:0 }}>
                      <div style={{ fontSize:12, fontWeight:600, color:B.white, whiteSpace:"nowrap", overflow:"hidden", textOverflow:"ellipsis" }}>
                        {n.label}
                      </div>
                      <div style={{ fontSize:10, color:B.muted, marginTop:1 }}>
                        {n.industry} · {fmt(n.minF)}+ followers
                      </div>
                    </div>
                    <button onClick={e=>deleteSavedNiche(n.id,e)}
                      style={{ background:"none", border:"none", cursor:"pointer", color:B.muted, padding:"2px 4px",
                        display:"flex", borderRadius:4, flexShrink:0 }}
                      onMouseEnter={e=>e.currentTarget.style.color=B.error}
                      onMouseLeave={e=>e.currentTarget.style.color=B.muted}>
                      <svg width={13} height={13} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d={icons.x}/></svg>
                    </button>
                  </div>
                ))}
              </div>
            )}
          </Card>

          {/* ── UPDATES CARD ── */}
          <Card>
            <SectionTitle icon={icons.star} label="Updates"/>
            <div style={{ display:"flex", flexDirection:"column", gap:8 }}>

              {/* Auto-check toggle */}
              <div style={{ display:"flex", alignItems:"center", justifyContent:"space-between",
                padding:"8px 10px", background:B.bg, border:`1px solid ${B.border}`, borderRadius:8 }}>
                <div>
                  <div style={{ fontSize:12, fontWeight:600, color:B.silver }}>Check at startup</div>
                  <div style={{ fontSize:10, color:B.muted, marginTop:1 }}>Auto-check GitHub on launch</div>
                </div>
                <div onClick={toggleAutoCheck}
                  style={{ width:36, height:20, borderRadius:10,
                    background:autoCheckUpdates?B.success:B.border,
                    cursor:"pointer", position:"relative", transition:"background 0.2s", flexShrink:0 }}>
                  <div style={{ position:"absolute", top:3, left:autoCheckUpdates?18:3,
                    width:14, height:14, borderRadius:"50%", background:B.white, transition:"left 0.2s" }}/>
                </div>
              </div>

              {/* Status */}
              {updateStatus === "checking" && (
                <div style={{ fontSize:11, color:B.blueHi, display:"flex", alignItems:"center", gap:6 }}>
                  <div style={{ width:8, height:8, borderRadius:"50%", background:B.blueHi, animation:"pulse 1s infinite" }}/>
                  Checking for updates...
                </div>
              )}
              {updateStatus === "upToDate" && (
                <div style={{ fontSize:11, color:B.success, display:"flex", alignItems:"center", gap:6 }}>
                  <svg width={12} height={12} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d={icons.check}/></svg>
                  Up to date — v{CURRENT_VERSION}
                </div>
              )}
              {updateStatus === "available" && (
                <div style={{ fontSize:11, color:B.gold, display:"flex", alignItems:"center", gap:6 }}>
                  <svg width={12} height={12} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10zM12 8v4M12 16h.01"/></svg>
                  v{updateInfo?.version} available!
                </div>
              )}
              {updateStatus === "error" && (
                <div style={{ fontSize:11, color:B.error, display:"flex", alignItems:"center", gap:6 }}>
                  <svg width={12} height={12} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d={icons.x}/></svg>
                  Could not reach update server
                </div>
              )}

              <Btn onClick={()=>checkForUpdates(false)}
                variant={updateStatus==="available"?"gold":"ghost"} size="sm"
                disabled={updateStatus==="checking"}>
                <svg width={13} height={13} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M23 4v6h-6M1 20v-6h6M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/>
                </svg>
                {updateStatus==="available" ? `Install v${updateInfo?.version}` : "Check for Updates"}
              </Btn>
            </div>
          </Card>
        </div>

        {/* ── RIGHT PANEL ── */}
        <div style={{ flex:1, overflowY:"auto", display:"flex", flexDirection:"column" }}>
          {results.length === 0 && !loading ? (
            /* EMPTY STATE */
            <div style={{ flex:1, display:"flex", flexDirection:"column", alignItems:"center", justifyContent:"center",
              padding:40, textAlign:"center", gap:20 }}>
              <div style={{ width:80, height:80, borderRadius:20, background:B.card,
                border:`1px solid ${B.border}`, display:"flex", alignItems:"center", justifyContent:"center",
                boxShadow:`0 0 40px ${B.blueGlow}` }}>
                <svg width={40} height={40} viewBox="0 0 24 24" fill="none" stroke={B.blue} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                  <path d={icons.users}/>
                </svg>
              </div>
              <div>
                <div style={{ fontSize:20, fontWeight:700, color:B.white, marginBottom:8 }}>Find Niche Influencers on X</div>
                <div style={{ fontSize:14, color:B.muted, maxWidth:380, lineHeight:1.7 }}>
                  Enter a niche keyword, select an industry preset, configure your filters,
                  then hit <b style={{color:B.blueHi}}>Search X</b> to discover the top influencers.
                </div>
              </div>
              <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr 1fr", gap:12, maxWidth:420, width:"100%" }}>
                {[
                  { step:"1", label:"Configure", desc:"Set API key & niche" },
                  { step:"2", label:"Search",    desc:"Fetch top accounts" },
                  { step:"3", label:"Export",    desc:"Download CSV list"  },
                ].map(s => (
                  <div key={s.step} style={{ background:B.card, border:`1px solid ${B.border}`,
                    borderRadius:12, padding:16, textAlign:"center" }}>
                    <div style={{ width:28, height:28, borderRadius:"50%", background:`linear-gradient(135deg,${B.blue},${B.blueHi})`,
                      margin:"0 auto 8px", display:"flex", alignItems:"center", justifyContent:"center",
                      fontSize:13, fontWeight:700, color:B.white }}>{s.step}</div>
                    <div style={{ fontSize:13, fontWeight:600, color:B.white }}>{s.label}</div>
                    <div style={{ fontSize:11, color:B.muted, marginTop:3 }}>{s.desc}</div>
                  </div>
                ))}
              </div>
            </div>
          ) : (
            <>
              {/* STATS BAR */}
              {results.length > 0 && (
                <div style={{ padding:"16px 20px", borderBottom:`1px solid ${B.border}`,
                  display:"grid", gridTemplateColumns:"repeat(4,1fr)", gap:12 }}>
                  <Stat label="Influencers Found"  value={results.length}     color={B.blueHi}  />
                  <Stat label="Total Reach"        value={fmt(totalFollowers)} color={B.gold}    />
                  <Stat label="Avg Followers"      value={fmt(avgFollowers)}   color={B.silver}  />
                  <Stat label="Niche"              value={niche || "—"}        color={B.success} />
                </div>
              )}

              {/* TOOLBAR */}
              <div style={{ padding:"12px 20px", borderBottom:`1px solid ${B.border}`,
                display:"flex", alignItems:"center", gap:10, flexWrap:"wrap", background:B.card }}>
                <div style={{ display:"flex", alignItems:"center", gap:6, fontSize:12, color:B.muted }}>
                  <svg width={13} height={13} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d={icons.sort}/></svg>
                  Sort:
                </div>
                {[["followers","Followers"],["tweets","Tweets"],["following","Following"],["name","Name"]].map(([k,l])=>(
                  <button key={k} onClick={()=>setSortBy(k)}
                    style={{ padding:"5px 12px", borderRadius:6, border:`1px solid ${sortBy===k?B.blue:B.border}`,
                      background:sortBy===k?`${B.blue}22`:"transparent", color:sortBy===k?B.blueHi:B.silver,
                      fontSize:12, cursor:"pointer", fontWeight:sortBy===k?600:400, fontFamily:"inherit",
                      transition:"all 0.15s" }}>
                    {l}
                  </button>
                ))}
                <div style={{ flex:1 }}/>
                <Btn onClick={()=>{ const h=results.map(u=>`@${u.handle}`).join("\n"); navigator.clipboard.writeText(h); showToast("Handles copied!") }}
                  variant="ghost" size="sm">
                  <svg width={13} height={13} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d={icons.copy}/></svg>
                  Copy Handles
                </Btn>
                <Btn onClick={()=>exportCSV(sorted, niche)} variant="gold" size="sm" disabled={!results.length}>
                  <svg width={13} height={13} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d={icons.csv}/></svg>
                  Export CSV
                </Btn>
              </div>

              {/* LOADING ROWS */}
              {loading && results.length === 0 && (
                <div style={{ padding:40, textAlign:"center" }}>
                  <div style={{ width:40, height:40, border:`3px solid ${B.border}`, borderTopColor:B.blue,
                    borderRadius:"50%", animation:"spin 0.8s linear infinite", margin:"0 auto 16px" }}/>
                  <div style={{ color:B.silver, fontSize:14 }}>{statusMsg}</div>
                  <ProgressBar value={progress}/>
                </div>
              )}

              {/* RESULTS TABLE */}
              {sorted.length > 0 && (
                <div style={{ flex:1, overflowY:"auto" }}>
                  <table style={{ width:"100%", borderCollapse:"collapse", fontSize:13 }}>
                    <thead>
                      <tr style={{ background:B.card, position:"sticky", top:0, zIndex:10 }}>
                        {["#","User","Handle","Followers","Following","Tweets","Verified","Location"].map(h=>(
                          <th key={h} style={{ padding:"10px 14px", textAlign:h==="#"||h==="Followers"||h==="Following"||h==="Tweets"?"center":"left",
                            fontSize:10, fontWeight:700, color:B.muted, textTransform:"uppercase",
                            letterSpacing:"0.07em", borderBottom:`1px solid ${B.border}`, whiteSpace:"nowrap" }}>
                            {h}
                          </th>
                        ))}
                        <th style={{ padding:"10px 14px", fontSize:10, fontWeight:700, color:B.muted,
                          textTransform:"uppercase", letterSpacing:"0.07em", borderBottom:`1px solid ${B.border}` }}>Action</th>
                      </tr>
                    </thead>
                    <tbody>
                      {sorted.map((u, i) => (
                        <tr key={u.handle} className="result-row"
                          onMouseEnter={()=>setHoveredRow(u.handle)}
                          onMouseLeave={()=>setHoveredRow(null)}
                          style={{ borderBottom:`1px solid ${B.border}`, animation:"fadeIn 0.2s ease",
                            background: hoveredRow===u.handle ? B.card2 : "transparent",
                            transition:"background 0.12s" }}>
                          <td style={{ padding:"10px 14px", textAlign:"center", color:B.muted, fontWeight:700, fontSize:12,
                            ...(i<3?{color:[B.gold,B.silver,"#CD7F32"][i],fontSize:13}:{}) }}>
                            {i+1}
                          </td>
                          <td style={{ padding:"10px 14px" }}>
                            <div style={{ display:"flex", alignItems:"center", gap:10 }}>
                              <Avatar src={u.avatar} name={u.name} size={34}/>
                              <div style={{ minWidth:0 }}>
                                <div style={{ fontWeight:600, color:B.white, whiteSpace:"nowrap", overflow:"hidden", textOverflow:"ellipsis", maxWidth:160, display:"flex", alignItems:"center", gap:4 }}>
                                  {u.name}
                                  {(u.verified||u.blueVerified) && (
                                    <svg width={13} height={13} viewBox="0 0 24 24" fill={B.blue} stroke="none">
                                      <path d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z"/>
                                    </svg>
                                  )}
                                </div>
                                {u.bio && (
                                  <div style={{ fontSize:11, color:B.muted, whiteSpace:"nowrap", overflow:"hidden",
                                    textOverflow:"ellipsis", maxWidth:180, marginTop:1 }}>
                                    {u.bio}
                                  </div>
                                )}
                              </div>
                            </div>
                          </td>
                          <td style={{ padding:"10px 14px" }}>
                            <a href={`https://x.com/${u.handle}`} target="_blank" rel="noopener noreferrer"
                              style={{ color:B.blueHi, textDecoration:"none", fontFamily:"'Fira Code',monospace",
                                fontSize:12, fontWeight:500 }}
                              onMouseEnter={e=>e.currentTarget.style.color=B.goldHi}
                              onMouseLeave={e=>e.currentTarget.style.color=B.blueHi}>
                              @{u.handle}
                            </a>
                          </td>
                          <td style={{ padding:"10px 14px", textAlign:"center", fontWeight:700,
                            color: u.followers>=1_000_000?B.gold:u.followers>=100_000?B.blueHi:B.white }}>
                            {fmt(u.followers)}
                          </td>
                          <td style={{ padding:"10px 14px", textAlign:"center", color:B.silver }}>{fmt(u.following)}</td>
                          <td style={{ padding:"10px 14px", textAlign:"center", color:B.silver }}>{fmt(u.tweets)}</td>
                          <td style={{ padding:"10px 14px", textAlign:"center" }}>
                            {u.verified||u.blueVerified
                              ? <span style={{ color:B.blue, fontSize:11, fontWeight:700 }}>✓ Yes</span>
                              : <span style={{ color:B.muted, fontSize:11 }}>—</span>}
                          </td>
                          <td style={{ padding:"10px 14px", color:B.muted, fontSize:12, maxWidth:120,
                            whiteSpace:"nowrap", overflow:"hidden", textOverflow:"ellipsis" }}>
                            {u.location || "—"}
                          </td>
                          <td style={{ padding:"10px 14px" }}>
                            <a href={`https://x.com/${u.handle}`} target="_blank" rel="noopener noreferrer"
                              title="Open profile on X"
                              style={{ display:"inline-flex", alignItems:"center", gap:4, fontSize:11, color:B.muted,
                                textDecoration:"none", padding:"4px 8px", borderRadius:6, border:`1px solid ${B.border}`,
                                transition:"all 0.15s", whiteSpace:"nowrap" }}
                              onMouseEnter={e=>{e.currentTarget.style.borderColor=B.blue;e.currentTarget.style.color=B.blueHi;e.currentTarget.style.background=`${B.blue}15`}}
                              onMouseLeave={e=>{e.currentTarget.style.borderColor=B.border;e.currentTarget.style.color=B.muted;e.currentTarget.style.background="transparent"}}>
                              <svg width={11} height={11} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d={icons.link}/></svg>
                              View
                            </a>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>

                  {/* CSV FOOTER */}
                  <div style={{ padding:"14px 20px", borderTop:`1px solid ${B.border}`, display:"flex",
                    justifyContent:"space-between", alignItems:"center", background:B.black }}>
                    <span style={{ fontSize:12, color:B.muted }}>
                      Showing <b style={{color:B.white}}>{sorted.length}</b> influencers for <b style={{color:B.blueHi}}>"{niche}"</b>
                    </span>
                    <Btn onClick={()=>exportCSV(sorted,niche)} variant="gold" size="sm">
                      <svg width={13} height={13} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d={icons.csv}/></svg>
                      Download CSV ({sorted.length} rows)
                    </Btn>
                  </div>
                </div>
              )}
            </>
          )}
        </div>
      </div>

      {/* ── UPDATE MODAL ── */}
      {showUpdateModal && (
        <div style={{ position:"fixed", inset:0, background:"rgba(1,4,9,0.85)", zIndex:1000,
          display:"flex", alignItems:"center", justifyContent:"center", backdropFilter:"blur(6px)" }}
          onClick={()=>{ if(updateStatus!=="downloading") setShowUpdateModal(false) }}>
          <div onClick={e=>e.stopPropagation()}
            style={{ background:B.card, border:`1px solid ${B.border}`, borderRadius:16,
              padding:28, width:420, boxShadow:"0 24px 64px rgba(0,0,0,0.7)" }}>

            {/* Header */}
            <div style={{ display:"flex", alignItems:"center", gap:12, marginBottom:18 }}>
              <div style={{ width:42, height:42, borderRadius:10, flexShrink:0,
                background: updateStatus==="available"||updateStatus==="downloading"||updateStatus==="done"
                  ? `${B.gold}18` : updateStatus==="upToDate" ? `${B.success}18` : `${B.error}18`,
                border:`1px solid ${
                  updateStatus==="available"||updateStatus==="downloading"||updateStatus==="done"
                  ? B.gold+"44" : updateStatus==="upToDate" ? B.success+"44" : B.error+"44"}`,
                display:"flex", alignItems:"center", justifyContent:"center" }}>
                {updateStatus==="upToDate"
                  ? <svg width={22} height={22} viewBox="0 0 24 24" fill="none" stroke={B.success} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d={icons.check}/></svg>
                  : updateStatus==="error"
                  ? <svg width={22} height={22} viewBox="0 0 24 24" fill="none" stroke={B.error} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d={icons.x}/></svg>
                  : <svg width={22} height={22} viewBox="0 0 24 24" fill="none" stroke={B.gold} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M23 4v6h-6M1 20v-6h6M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/></svg>
                }
              </div>
              <div>
                <div style={{ fontSize:16, fontWeight:700, color:B.white }}>
                  {updateStatus==="checking"   && "Checking for updates..."}
                  {updateStatus==="upToDate"   && "You're up to date!"}
                  {updateStatus==="available"  && `Update Available — v${updateInfo?.version}`}
                  {updateStatus==="downloading" && "Downloading update..."}
                  {updateStatus==="done"       && "Download complete!"}
                  {updateStatus==="error"      && "Update check failed"}
                </div>
                <div style={{ fontSize:12, color:B.muted, marginTop:2 }}>
                  Current version: v{CURRENT_VERSION}
                  {updateInfo && updateStatus !== "upToDate" && ` · Latest: v${updateInfo.version}`}
                </div>
              </div>
            </div>

            {/* Checking spinner */}
            {updateStatus === "checking" && (
              <div style={{ textAlign:"center", padding:"20px 0" }}>
                <div style={{ width:32, height:32, border:`3px solid ${B.border}`, borderTopColor:B.blueHi,
                  borderRadius:"50%", animation:"spin 0.8s linear infinite", margin:"0 auto 12px" }}/>
                <div style={{ fontSize:12, color:B.muted }}>Connecting to GitHub...</div>
              </div>
            )}

            {/* Up to date */}
            {updateStatus === "upToDate" && (
              <div style={{ padding:"12px 14px", background:`${B.success}12`,
                border:`1px solid ${B.success}33`, borderRadius:10, fontSize:13,
                color:B.success, marginBottom:16, textAlign:"center" }}>
                NicheFinder X v{CURRENT_VERSION} is the latest version.
              </div>
            )}

            {/* Available — show changelog */}
            {(updateStatus === "available" || updateStatus === "downloading" || updateStatus === "done") && updateInfo && (
              <div style={{ marginBottom:16 }}>
                <div style={{ fontSize:11, fontWeight:700, color:B.muted, textTransform:"uppercase",
                  letterSpacing:"0.07em", marginBottom:8 }}>What's new in v{updateInfo.version}</div>
                <div style={{ background:B.card2, border:`1px solid ${B.border}`, borderRadius:10,
                  padding:"12px 14px", maxHeight:140, overflowY:"auto" }}>
                  {(updateInfo.changelog || []).map((c,i) => (
                    <div key={i} style={{ display:"flex", gap:8, marginBottom:6, fontSize:12, color:B.silver }}>
                      <span style={{ color:B.gold, flexShrink:0 }}>→</span> {c}
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Download complete instructions */}
            {updateStatus === "done" && (
              <div style={{ background:B.card2, border:`1px solid ${B.border}`, borderRadius:10,
                padding:"14px 16px", marginBottom:16 }}>
                <div style={{ fontSize:12, fontWeight:700, color:B.silver, marginBottom:10 }}>
                  Two files downloaded to your Downloads folder:
                </div>
                {[
                  ["orbix-nichefinder-x.jsx",
                   "The updated app file"],
                  [isWindows ? "NicheFinderX-Update.bat" : "NicheFinderX-Update.sh",
                   "Auto-installer — run this next"],
                ].map(([f,d],i) => (
                  <div key={i} style={{ display:"flex", alignItems:"center", gap:8, marginBottom:6 }}>
                    <span style={{ width:18, height:18, borderRadius:"50%", background:B.blue,
                      display:"inline-flex", alignItems:"center", justifyContent:"center",
                      fontSize:10, fontWeight:700, color:B.white, flexShrink:0 }}>{i+1}</span>
                    <div>
                      <div style={{ fontFamily:"'Fira Code',monospace", fontSize:11, color:B.white }}>{f}</div>
                      <div style={{ fontSize:10, color:B.muted }}>{d}</div>
                    </div>
                  </div>
                ))}
                <div style={{ marginTop:12, padding:"10px 12px", background:`${B.gold}11`,
                  border:`1px solid ${B.gold}44`, borderRadius:8, fontSize:11, color:B.gold, lineHeight:1.6 }}>
                  {isWindows ? (
                    <><b>To install:</b> Double-click <code style={{fontFamily:"monospace"}}>NicheFinderX-Update.bat</code> in your Downloads folder.</>
                  ) : (
                    <><b>To install:</b> Open Terminal, run: <code style={{fontFamily:"monospace"}}>chmod +x ~/Downloads/NicheFinderX-Update.sh && ~/Downloads/NicheFinderX-Update.sh</code></>
                  )}
                  {" "}It will replace the app file and restart the server automatically.
                </div>
              </div>
            )}

            {/* Error */}
            {updateStatus === "error" && (
              <div style={{ padding:"12px 14px", background:`${B.error}12`,
                border:`1px solid ${B.error}33`, borderRadius:10, fontSize:12,
                color:B.error, marginBottom:16, lineHeight:1.6 }}>
                Could not connect to the update server. Check your internet connection and try again.
                <br/>You can also check manually at{" "}
                <a href="https://github.com/roughboy99/orbix-nichefinder-x/releases" target="_blank"
                  rel="noopener noreferrer" style={{ color:B.blueHi }}>
                  github.com/roughboy99/orbix-nichefinder-x
                </a>
              </div>
            )}

            {/* Action buttons */}
            <div style={{ display:"flex", gap:8, flexDirection:"column" }}>
              {updateStatus === "available" && (
                <Btn onClick={downloadUpdate} variant="gold" style={{ width:"100%", justifyContent:"center" }}>
                  <svg width={14} height={14} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3"/>
                  </svg>
                  Download & Install v{updateInfo?.version}
                </Btn>
              )}
              {updateStatus === "downloading" && (
                <div style={{ textAlign:"center", padding:"8px 0" }}>
                  <div style={{ width:24, height:24, border:`3px solid ${B.border}`, borderTopColor:B.gold,
                    borderRadius:"50%", animation:"spin 0.8s linear infinite", margin:"0 auto 8px" }}/>
                  <div style={{ fontSize:12, color:B.gold }}>Downloading files...</div>
                </div>
              )}
              {(updateStatus !== "downloading" && updateStatus !== "checking") && (
                <button onClick={()=>setShowUpdateModal(false)}
                  style={{ width:"100%", padding:"9px 0", borderRadius:8, border:`1px solid ${B.border}`,
                    background:"transparent", color:B.silver, cursor:"pointer", fontSize:13,
                    fontFamily:"inherit", transition:"all 0.15s" }}
                  onMouseEnter={e=>{ e.currentTarget.style.background=B.card2; e.currentTarget.style.color=B.white }}
                  onMouseLeave={e=>{ e.currentTarget.style.background="transparent"; e.currentTarget.style.color=B.silver }}>
                  {updateStatus === "done" ? "Close" : "Dismiss"}
                </button>
              )}
            </div>
          </div>
        </div>
      )}

      {/* ── CLOSE MODAL ── */}}
      {showCloseModal && (
        <div style={{ position:"fixed", inset:0, background:"rgba(1,4,9,0.85)", zIndex:1000,
          display:"flex", alignItems:"center", justifyContent:"center", backdropFilter:"blur(6px)" }}
          onClick={()=>setShowCloseModal(false)}>
          <div onClick={e=>e.stopPropagation()}
            style={{ background:B.card, border:`1px solid ${B.error}66`, borderRadius:16,
              padding:28, width:380, boxShadow:`0 24px 64px rgba(0,0,0,0.7), 0 0 0 1px ${B.error}22` }}>

            {/* Icon */}
            <div style={{ display:"flex", alignItems:"center", gap:12, marginBottom:16 }}>
              <div style={{ width:42, height:42, borderRadius:10, background:`${B.error}18`,
                border:`1px solid ${B.error}44`, display:"flex", alignItems:"center", justifyContent:"center", flexShrink:0 }}>
                <svg width={22} height={22} viewBox="0 0 24 24" fill="none" stroke={B.error} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d={icons.stop}/>
                </svg>
              </div>
              <div>
                <div style={{ fontSize:16, fontWeight:700, color:B.white }}>Close NicheFinder X</div>
                <div style={{ fontSize:12, color:B.muted, marginTop:2 }}>Two steps to fully shut down</div>
              </div>
            </div>

            {/* Step 1 */}
            <div style={{ background:B.card2, border:`1px solid ${B.border}`, borderRadius:10,
              padding:"12px 14px", marginBottom:10 }}>
              <div style={{ fontSize:12, fontWeight:700, color:B.silver, marginBottom:4, display:"flex", alignItems:"center", gap:6 }}>
                <span style={{ width:18, height:18, borderRadius:"50%", background:B.blue, display:"inline-flex",
                  alignItems:"center", justifyContent:"center", fontSize:10, fontWeight:700, color:B.white, flexShrink:0 }}>1</span>
                Close this browser window
              </div>
              <div style={{ fontSize:12, color:B.muted, lineHeight:1.6, marginBottom:10, paddingLeft:24 }}>
                Closes the NicheFinder X tab in your browser.
              </div>
              <button
                onClick={()=>{ setShowCloseModal(false); try{ window.close() }catch(e){} }}
                style={{ width:"100%", padding:"9px 0", borderRadius:8, border:`1px solid ${B.error}66`,
                  background:`${B.error}18`, color:B.error, cursor:"pointer", fontSize:13,
                  fontWeight:600, fontFamily:"inherit", transition:"all 0.15s" }}
                onMouseEnter={e=>{ e.currentTarget.style.background=`${B.error}30`; e.currentTarget.style.borderColor=B.error }}
                onMouseLeave={e=>{ e.currentTarget.style.background=`${B.error}18`; e.currentTarget.style.borderColor=`${B.error}66` }}>
                Close Browser Window
              </button>
            </div>

            {/* Step 2 */}
            <div style={{ background:B.card2, border:`1px solid ${B.border}`, borderRadius:10,
              padding:"12px 14px", marginBottom:18 }}>
              <div style={{ fontSize:12, fontWeight:700, color:B.silver, marginBottom:4, display:"flex", alignItems:"center", gap:6 }}>
                <span style={{ width:18, height:18, borderRadius:"50%", background:B.gold, display:"inline-flex",
                  alignItems:"center", justifyContent:"center", fontSize:10, fontWeight:700, color:B.black, flexShrink:0 }}>2</span>
                Stop the local server
              </div>
              <div style={{ paddingLeft:24 }}>
                <div style={{ fontSize:12, color:B.muted, lineHeight:1.6, marginBottom:8 }}>
                  In the terminal window that opened when you launched the app, press:
                </div>
                <div style={{ background:B.bg, border:`1px solid ${B.border}`, borderRadius:7,
                  padding:"8px 14px", fontFamily:"'Fira Code',monospace", fontSize:14,
                  color:B.white, textAlign:"center", letterSpacing:"0.08em" }}>
                  Ctrl + C
                </div>
                <div style={{ fontSize:11, color:B.muted, marginTop:6, lineHeight:1.5 }}>
                  This stops the Vite/Node.js server completely and frees the port.
                </div>
              </div>
            </div>

            {/* Cancel */}
            <button onClick={()=>setShowCloseModal(false)}
              style={{ width:"100%", padding:"9px 0", borderRadius:8, border:`1px solid ${B.border}`,
                background:"transparent", color:B.silver, cursor:"pointer", fontSize:13,
                fontFamily:"inherit", transition:"all 0.15s" }}
              onMouseEnter={e=>{ e.currentTarget.style.background=B.card2; e.currentTarget.style.color=B.white }}
              onMouseLeave={e=>{ e.currentTarget.style.background="transparent"; e.currentTarget.style.color=B.silver }}>
              Cancel — Keep Running
            </button>
          </div>
        </div>
      )}

      {/* TOAST */}
      {toast && <Toast msg={toast.msg} type={toast.type} onClose={()=>setToast(null)}/>}

      {/* ── GLOBAL FOOTER ── */}
      <div style={{ borderTop:`1px solid ${B.border}`, background:B.black,
        padding:"10px 24px", display:"flex", alignItems:"center", justifyContent:"space-between",
        flexWrap:"wrap", gap:8, flexShrink:0 }}>

        {/* Affiliate Disclosure */}
        <div style={{ display:"flex", alignItems:"center", gap:6, fontSize:11, color:B.muted, lineHeight:1.5 }}>
          <svg width={12} height={12} viewBox="0 0 24 24" fill="none" stroke={B.muted} strokeWidth="2"
            strokeLinecap="round" strokeLinejoin="round" style={{ flexShrink:0 }}>
            <path d={icons.info}/>
          </svg>
          <span>
            <b style={{ color:B.silver }}>Affiliate Disclosure:</b>{" "}
            Links to{" "}
            <a href="https://twitterapi.io?ref=roughboy666" target="_blank" rel="noopener noreferrer"
              style={{ color:B.blueHi, textDecoration:"underline" }}>TwitterAPI.io</a>{" "}
            and{" "}
            <a href="https://www.skool.com/aimate/about?ref=ae32f0f121324efbab8e269e59106b04" target="_blank" rel="noopener noreferrer"
              style={{ color:B.gold, textDecoration:"underline" }}>Andy Hafell's Content Mate</a>{" "}
            on this page are affiliate links. I may earn a commission at no extra cost to you if you sign up through these links.
          </span>
        </div>

        {/* Right side: branding + version */}
        <div style={{ display:"flex", alignItems:"center", gap:12, flexShrink:0 }}>
          <span style={{ fontSize:11, color:B.muted }}>
            <span style={{ color:B.silver, fontWeight:600 }}>Orbix</span>{" "}
            <span style={{ color:B.gold, fontWeight:600 }}>NicheFinder X</span>
          </span>
          <div style={{ height:12, width:1, background:B.border }}/>
          <span style={{ fontSize:11, color:B.muted, fontFamily:"'Fira Code',monospace" }}>
            v<span style={{ color:B.blueHi, fontWeight:600 }}>1.05</span>
          </span>
          <div style={{ height:12, width:1, background:B.border }}/>
          <a href="https://getorbix.com" target="_blank" rel="noopener noreferrer"
            style={{ fontSize:11, color:B.muted, textDecoration:"none" }}
            onMouseEnter={e=>e.currentTarget.style.color=B.silver}
            onMouseLeave={e=>e.currentTarget.style.color=B.muted}>
            getorbix.com
          </a>
        </div>
      </div>
    </div>
  )
}
