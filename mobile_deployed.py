import streamlit as st

# 1. Page Config (सबसे ऊपर होना अनिवार्य है)
st.set_page_config(
    page_title="MarkeTGyan PRO",
    page_icon="📈",
    layout="wide"
)

# 2. अन्य इम्पोर्ट्स
import yfinance as yf
from datetime import datetime
import json
import os
import hashlib
import pandas as pd
import urllib.request
import time

# 3. फोल्डर सेटअप
if not os.path.exists("userdata"):
    os.makedirs("userdata")

# 4. CSS स्टाइल
st.markdown("""
<style>
html, body, [class*="css"]{ background:#05070d; color:white; font-family:'Segoe UI'; }
.stApp{ background: radial-gradient(circle at top left,#102040 0%,#05070d 40%), radial-gradient(circle at bottom right,#071522 0%,#05070d 40%); }
.main-title{ text-align:center; font-size:30px; font-weight:900; background:linear-gradient(90deg,#00ffd5,#00bfff,#00ff66); -webkit-background-clip:text; -webkit-text-fill-color:transparent; }
.metric-box{ background:linear-gradient(145deg,#111827,#0d1526); border-radius:10px; padding:10px; text-align:center; border:1px solid rgba(255,255,255,0.05); margin-bottom: 10px; }
.metric-value{ font-size:18px; font-weight:900; }
.stButton > button{ width:100%; border-radius:8px; font-weight:bold; }
@media (max-width: 600px) {
    .main-title { font-size: 22px !important; }
}
</style>
""", unsafe_allow_html=True)

# 5. मुख्य लॉजिक (Helper Functions)
def hash_password(password): return hashlib.sha256(password.encode()).hexdigest()
def clean_symbol(x): return x.replace(".NS", "")

def load_user_data(username):
    path = f"userdata/{username}.json"
    if os.path.exists(path):
        with open(path, "r") as f: data = json.load(f)
        st.session_state.update(data)

# 6. सेशन स्टेट इनिशियलाइजेशन
if "logged_in" not in st.session_state:
    st.session_state.update({
        "logged_in": False, "username": "", "full_name": "", 
        "watchlist": ["RELIANCE.NS", "TCS.NS"], "portfolio": {}, 
        "positions": {}, "orders": [], "margin": 100000
    })

# 7. साइडबार - लॉगिन
with st.sidebar:
    st.title("🔐 LOGIN")
    auth_mode = st.radio("SELECT", ["LOGIN", "SIGNUP"])
    username = st.text_input("EMAIL").strip().lower()
    password = st.text_input("PASSWORD", type="password")
    if st.button("PROCEED"):
        users = {}
        if os.path.exists("users.json"):
            with open("users.json", "r") as f: users = json.load(f)
        if auth_mode == "SIGNUP":
            users[username] = {"password": hash_password(password), "name": username.split('@')[0]}
            with open("users.json", "w") as f: json.dump(users, f)
            st.success("ACCOUNT CREATED")
        elif username in users and users[username]["password"] == hash_password(password):
            st.session_state.update({"logged_in": True, "username": username})
            load_user_data(username); st.rerun()

if not st.session_state.logged_in:
    st.warning("PLEASE LOGIN TO ACCESS TERMINAL")
    st.stop()

# 8. मुख्य स्क्रीन
st.markdown("<div class='main-title'>🚀 MarkeTGyan PRO</div>", unsafe_allow_html=True)

m1, m2, m3 = st.columns(3)
m1.markdown(f"<div class='metric-box'><div class='metric-value'>₹ {round(st.session_state.margin, 2)}</div><div style='font-size:10px'>MARGIN</div></div>", unsafe_allow_html=True)
m2.markdown(f"<div class='metric-box'><div class='metric-value'>{len(st.session_state.positions)}</div><div style='font-size:10px'>POSITIONS</div></div>", unsafe_allow_html=True)
if m3.button("LOGOUT"): st.session_state.logged_in = False; st.rerun()

col1, col2 = st.columns([1, 1])

with col1:
    st.subheader("📊 WATCHLIST")
    for stock in st.session_state.watchlist:
        st.write(f"✅ {clean_symbol(stock)}")

with col2:
    st.subheader("📈 PORTFOLIO")
    if not st.session_state.positions:
        st.info("NO ACTIVE POSITIONS")
    else:
        for stock, pos in st.session_state.positions.items():
            st.write(f"🔹 {clean_symbol(stock)} | Qty: {pos['qty']}")
