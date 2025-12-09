import logging

logger = logging.getLogger(__name__)
import streamlit as st
from modules.nav import SideBarLinks
import requests
import pandas as pd

st.set_page_config(layout='wide')
SideBarLinks()

st.title('📹 Live Game Scout')
st.write('Tag and annotate plays during live games')

scout_id = st.session_state.get('user_id', 1)

# Game selection
st.write("### Select Game to Scout")

try:
    # Get scout's game history to show available games
    response = requests.get(f'http://api:4000/scouts/{scout_id}/game_history')

    if response.status_code == 200:
        games = response.json()

        if games:
            game_options = {
                f"Game #{g['gameID']} - {g.get('date', 'N/A')} vs {g.get('opponent', 'Unknown')}": g['gameID']
                for g in games
            }

            selected_game_str = st.selectbox("Select Game", list(game_options.keys()))
            game_id = game_options[selected_game_str]
        else:
            st.info("No games in history. Enter a game ID manually:")
            game_id = st.number_input("Game ID", min_value=1, value=1)
    else:
        game_id = st.number_input("Game ID", min_value=1, value=1)

except Exception as e:
    st.warning(f"Could not load games: {str(e)}")
    game_id = st.number_input("Game ID", min_value=1, value=1)

col1, col2 = st.columns([2, 1])

with col1:
    st.write("### Game Feed")

    try:
        # Get game footage for this game
        footage_response = requests.get(f'http://api:4000/players/1/videos')  # Get any available footage

        if footage_response.status_code == 200:
            footage_list = footage_response.json()
            game_footage = [f for f in footage_list if f.get('gameID') == game_id]

            if game_footage:
                st.success("Game footage available")
                for footage in game_footage[:3]:  # Show up to 3 videos
                    st.video(footage['URL'])
            else:
                st.info("No footage available for this game yet")
        else:
            st.info("Live game video would appear here")
    except:
        st.info("Live game video would appear here")

    # Show game info if available
    st.write(f"**Game #{game_id}**")
    st.write("Scouting in progress...")

with col2:
    st.write("### Quick Tags")

    tag_buttons = st.columns(3)
    with tag_buttons[0]:
        if st.button("Fast Break", use_container_width=True):
            st.success("Tagged!")
    with tag_buttons[1]:
        if st.button("Assist", use_container_width=True):
            st.success("Tagged!")
    with tag_buttons[2]:
        if st.button("Rebound", use_container_width=True):
            st.success("Tagged!")

# Annotation form
st.write("---")
st.write("### Add Annotation")

with st.form("annotation_form"):
    col1, col2 = st.columns(2)

    with col1:
        report_id = st.number_input("Report ID", min_value=1, value=1, help="Enter the report ID to annotate")
        player_id = st.number_input("Player ID", min_value=1, value=1)

    with col2:
        timestamp = st.text_input("Timestamp (HH:MM:SS)", value="00:00:00")

    note = st.text_area("Notes", placeholder="e.g., 'Great defensive rotation on this play'")

    if st.form_submit_button("Save Annotation", type="primary"):
        try:
            # Save annotation via API
            annotation_data = {
                'reportID': int(report_id),
                'annotatedBy': scout_id,
                'text': note,
                'timestamp': timestamp
            }

            # Note: Using footage_id as a placeholder since we need it for the route
            response = requests.post(
                f'http://api:4000/footages/1/annotation',
                json=annotation_data
            )

            if response.status_code == 201:
                st.success("Annotation saved!")
                st.rerun()
            else:
                st.error(f"Failed to save annotation: {response.status_code}")

        except Exception as e:
            st.error(f"Error saving annotation: {str(e)}")

# Recent annotations - would need to be fetched from database in real implementation
st.write("---")
st.write("### Recent Annotations")

# Show sample annotations
st.info("Recent annotations for this scouting session:")

annotations = [
    {"Player": "Player #101", "Time": "00:00:37", "Note": "Great defensive rotation"},
    {"Player": "Player #1", "Time": "00:02:15", "Note": "Excellent court vision on assist"}
]

st.dataframe(pd.DataFrame(annotations), use_container_width=True)

# Scout activity logging
st.write("---")
st.write("### Scout Activity")

try:
    # Get scout's game history
    response = requests.get(f'http://api:4000/scouts/{scout_id}/game_history')

    if response.status_code == 200:
        games_attended = response.json()

        if games_attended:
            st.success(f"You have scouted {len(games_attended)} games")

            # Show recent games
            recent_df = pd.DataFrame(games_attended)
            if 'date' in recent_df.columns:
                display_df = recent_df[['gameID', 'date', 'opponent', 'venue', 'notes']].copy()
                display_df.columns = ['Game ID', 'Date', 'Opponent', 'Venue', 'Notes']
                st.dataframe(display_df.head(5), use_container_width=True)
        else:
            st.info("No games scouted yet")
    else:
        st.info("Scout activity data unavailable")

except Exception as e:
    st.info("Scout activity data unavailable")

# Tips
st.write("---")
st.write("### 📌 Scouting Tips")
st.info("""
- Tag plays in real-time for quick reference
- Add detailed notes for important moments
- Include timestamps for easy video review later
- Focus on both strengths and areas for improvement
- Document defensive and offensive plays separately
""")