# =========================================================
# 🚀 MarkeTGyan PRO Trading Terminal
# MOBILE RESPONSIVE VERSION
# =========================================================

import streamlit as st
import yfinance as yf
from datetime import datetime
import json
import os
import hashlib
import pandas as pd
import urllib.request
import time

# =========================================================
# PAGE CONFIG - Optimized for Mobile & Desktop
# =========================================================
st.set_page_config(
    page_title="MarkeTGyan PRO",
    page_icon="📈",
    layout="wide"
)

# =========================================================
# FOLDERS & DIRECTORIES
# =========================================================
if not os.path.exists("userdata"):
    os.makedirs("userdata")

# =========================================================
# CSS STYLE (Updated for Mobile Responsiveness)
# =========================================================
st.markdown("""
<style>
html, body, [class*="css"]{ background:#05070d; color:white; font-family:'Segoe UI'; }
.stApp{ background: radial-gradient(circle at top left,#102040 0%,#05070d 40%), radial-gradient(circle at bottom right,#071522 0%,#05070d 40%); }
.main-title{ text-align:center; font-size:40px; font-weight:900; background:linear-gradient(90deg,#00ffd5,#00bfff,#00ff66); -webkit-background-clip:text; -webkit-text-fill-color:transparent; }
.sub-title{ color:#9fb4d1; font-size:13px; }
.userbar{ background:#0f172a; padding:12px; border-radius:14px; border:1px solid rgba(255,255,255,0.05); margin-bottom:15px; }
.metric-box{ background:linear-gradient(145deg,#111827,#0d1526); border-radius:15px; padding:10px; text-align:center; min-height:75px; border:1px solid rgba(255,255,255,0.05); margin-bottom: 5px; }
.metric-title{ color:#9fb4d1; font-size:10px; font-weight:700; }
.metric-value{ font-size:20px; font-weight:900; }
.pro-card{ background:linear-gradient(145deg,#0d1526,#111b31); border-radius:18px; padding:20px; border:1px solid rgba(255,255,255,0.05); margin-bottom:15px; }
.section-title{ color:#00ffd5; font-size:22px; font-weight:800; margin-bottom:15px; border-bottom: 2px solid rgba(0,255,213,0.2); padding-bottom:5px; }
.table-header-custom { color: #9fb4d1; font-size: 11px; font-weight: 700; text-transform: uppercase; border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 8px; }
.watch-row{ padding-top:10px; padding-bottom:10px; border-bottom:1px solid rgba(255,255,255,0.06); }
.trade-popup{ background:linear-gradient(145deg,#0f172a,#111827); padding:20px; min-width:300px; border-radius:18px; border:1px solid rgba(255,255,255,0.06); }
.trade-stock{ color:#00ffd5; font-size:24px; font-weight:900; }
.trade-price{ color:white; font-size:22px; font-weight:900; }
.trade-label{ color:#9fb4d1; font-size:11px; }
.mode-box{ background:#0d1526; padding:10px; border-radius:12px; text-align:center; border:1px solid rgba(255,255,255,0.05); }
.green{ color:#00ff88; font-weight:700; }
.red{ color:#ff4d6d; font-weight:700; }
.orange{ color:orange; font-weight:700; }
.stButton > button{ width:100%; border:none; border-radius:10px; height:36px; font-weight:bold; }
.buy-btn button{ background:linear-gradient(135deg,#00c853,#00e676)!important; color:white!important; }
.sell-btn button{ background:linear-gradient(135deg,#ff1744,#ff5252)!important; color:white!important; }
.scan-btn button{ background: linear-gradient(90deg, #00ffd5 0%, #00bfff 100%) !important; color: #05070d !important; font-size: 16px !important; font-weight: 800 !important; }
/* Mobile Adjustment */
@media (max-width: 768px) {
    .main-title { font-size: 28px !important; }
    .metric-value { font-size: 16px !important; }
}
</style>
""", unsafe_allow_html=True)

# =========================================================
# HELPER FUNCTIONS & DATA PERSISTENCE
# =========================================================
def hash_password(password): return hashlib.sha256(password.encode()).hexdigest()
def make_symbol(x): x = x.strip().upper(); return x if x.endswith(".NS") or x == "" else x + ".NS"
def clean_symbol(x): return x.replace(".NS", "")

def save_user_data(username):
    data = {"watchlist": st.session_state.watchlist, "portfolio": st.session_state.portfolio, "positions": st.session_state.positions, "orders": st.session_state.orders, "history": st.session_state.history, "margin": st.session_state.margin, "name": st.session_state.full_name, "scan_results": st.session_state.get("scan_results", None)}
    with open(f"userdata/{username}.json", "w") as f: json.dump(data, f)

def load_user_data(username):
    path = f"userdata/{username}.json"
    if os.path.exists(path):
        with open(path, "r") as f: data = json.load(f)
        st.session_state.update({"watchlist": data.get("watchlist", ["RELIANCE.NS", "TCS.NS"]), "portfolio": data.get("portfolio", {}), "positions": data.get("positions", {}), "orders": data.get("orders", []), "history": data.get("history", []), "margin": data.get("margin", 100000), "full_name": data.get("name", username), "scan_results": data.get("scan_results", None)})

# =========================================================
# INITIALIZE STATE
# =========================================================
if "logged_in" not in st.session_state:
    st.session_state.update({"logged_in": False, "username": "", "full_name": "", "watchlist": ["RELIANCE.NS", "TCS.NS"], "portfolio": {}, "positions": {}, "orders": [], "history": [], "margin": 100000, "scan_results": None})

# =========================================================
# CORE FUNCTIONS
# =========================================================
def get_stock_data(symbol):
    try:
        ticker_obj = yf.Ticker(symbol)
        df = ticker_obj.history(period="5d", interval="1d")
        if df.empty or len(df) < 2: return {"price": 150.0, "change": 0.0, "pct": 0.0}
        curr, prev = round(float(df["Close"].iloc[-1]), 2), round(float(df["Close"].iloc[-2]), 2)
        change = round(curr - prev, 2)
        return {"price": curr, "change": change, "pct": round((change / prev) * 100, 2) if prev != 0 else 0.0}
    except: return {"price": 150.0, "change": 0.0, "pct": 0.0}

def get_all_nse_tickers():
    try:
        url = "https://archives.nseindia.com/content/equities/EQUITY_L.csv"
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response: df = pd.read_csv(response)
        return [str(sym).strip() + ".NS" for sym in df['SYMBOL'].unique() if pd.notna(sym) and sym != 'SYMBOL']
    except: return ["RELIANCE.NS", "TCS.NS", "INFY.NS"]

def scan_all_nse_50_chunks():
    all_tickers = get_all_nse_tickers()
    scanned_list = []
    chunk_size = 50
    total_chunks = (len(all_tickers) + chunk_size - 1) // chunk_size
    progress_bar = st.progress(0)
    for chunk_idx in range(min(total_chunks, 5)): # Limited for performance
        chunk = all_tickers[chunk_idx * chunk_size : (chunk_idx + 1) * chunk_size]
        data_df = yf.download(chunk, period="6y", progress=False, group_by='ticker')
        for ticker in chunk:
            try:
                sub_df = data_df[ticker].dropna() if isinstance(data_df.columns, pd.MultiIndex) else data_df.dropna()
                if len(sub_df) < 1000: continue
                if sub_df['High'].iloc
