# streamlit_app.py

import hmac
import hvac
import streamlit as st
import json
import os

print("checking start")

client = hvac.Client(url=os.environ["VAULT_ADDR"])

try:
    if client.is_authenticated():
        print("vault available at ", os.environ["VAULT_ADDR"])
    else:
        st.write("connection to Vault failed: url=", os.environ["VAULT_ADDR"])
        st.stop()
except Exception as e:
    st.write("connection to Vault failed: ", e.message)
    st.stop()

def check_password():
    """Returns `True` if the user had a correct password."""

    def login_form():
        """Form with widgets to collect user information"""
        with st.form("Credentials"):
            st.text_input("Username", key="username")
            st.text_input("Password", type="password", key="password")
            st.form_submit_button("Log in", on_click=password_entered)

    def password_entered():
        """Checks against vault if a password entered by the user is correct."""
        if client.auth.userpass.login(st.session_state["username"], st.session_state["password"]):
            st.session_state["password_correct"] = True
            del st.session_state["password"]  # don't store username or password.
            del st.session_state["username"]
        else:
            st.session_state["password_correct"] = False

    # Return True if the username + password is validated.
    if st.session_state.get("password_correct", False):
        return True

    # Show inputs for username + password.
    login_form()
    if "password_correct" in st.session_state:
        st.error("😕 User not known or password incorrect")
    return False

if not check_password():
    print("checking pasword")
    st.stop()

st.write("Successfull login!")
if st.button("click me!"):
    st.video("https://www.youtube.com/watch?v=dQw4w9WgXcQ", autoplay=True)