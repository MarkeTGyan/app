# =========================================================
# PAGE CONFIG (MOBILE RESPONSIVE IMPROVEMENT)
# =========================================================
import streamlit.components.v1 as components

# यह चेक करेगा कि क्या स्क्रीन छोटी है और उसी अनुसार लेआउट सेट करेगा
st.set_page_config(
    page_title="MarkeTGyan PRO",
    page_icon="📈",
    layout="centered" # इसे wide से centered करने पर मोबाइल पर कंटेंट सही से दिखेगा
)

# मोबाइल के लिए अतिरिक्त CSS ताकि टेबल और कॉलम सही दिखें
st.markdown("""
<style>
    /* मोबाइल के लिए टेबल और फोंट को छोटा करना */
    @media (max-width: 600px) {
        .main-title { font-size: 24px !important; }
        .metric-value { font-size: 16px !important; }
        .stColumn { width: 100% !important; }
        .table-header-custom { font-size: 9px !important; }
    }
    /* स्क्रीन के बाहर जाने से रोकने के लिए */
    .stApp { overflow-x: hidden; }
</style>
""", unsafe_allow_html=True)
