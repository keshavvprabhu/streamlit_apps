import streamlit as st
from streamlit import session_state as state


def main():
    st.title("Streamlit App with Session State")

    if "counter" not in state:
        state.counter = 0

    st.write(f"Counter: {state.counter}")

    if st.button("Increment"):
        state.counter += 1
        st.write(f"Counter incremented to: {state.counter}")

    if st.button("Reset"):
        state.counter = 0
        st.write("Counter reset to 0")


if __name__ == "__main__":
    pass
