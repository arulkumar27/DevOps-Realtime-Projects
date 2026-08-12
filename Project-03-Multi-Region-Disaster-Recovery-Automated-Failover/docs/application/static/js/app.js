"use strict";

const state = {
  tracks: [],
  selectedTrack: null,
  playing: false,
  progress: 0,
  progressTimer: null,
  likedTracks: new Set()
};

const elements = {
  searchInput: document.querySelector("#searchInput"),
  heroPlayButton: document.querySelector("#heroPlayButton"),
  mainPlayButton: document.querySelector("#mainPlayButton"),
  playerTitle: document.querySelector("#playerTitle"),
  playerArtist: document.querySelector("#playerArtist"),
  playerCover: document.querySelector("#playerCover"),
  currentTime: document.querySelector("#currentTime"),
  totalTime: document.querySelector("#totalTime"),
  progressFill: document.querySelector("#progressFill"),
  playerLikeButton: document.querySelector("#playerLikeButton"),
  viewAllButton: document.querySelector("#viewAllButton"),
  toast: document.querySelector("#toast")
};

function showToast(message) {
  elements.toast.textContent = message;
  elements.toast.classList.add("visible");

  window.clearTimeout(showToast.timeout);

  showToast.timeout = window.setTimeout(() => {
    elements.toast.classList.remove("visible");
  }, 2600);
}

function parseDuration(duration) {
  const [minutes, seconds] = duration.split(":").map(Number);
  return (minutes * 60) + seconds;
}

function formatTime(totalSeconds) {
  const seconds = Math.max(0, Math.floor(totalSeconds));
  const minutes = Math.floor(seconds / 60);
  const remainder = String(seconds % 60).padStart(2, "0");

  return `${minutes}:${remainder}`;
}

async function fetchTracks() {
  try {
    const response = await fetch("/api/tracks");

    if (!response.ok) {
      throw new Error(`Track API returned ${response.status}`);
    }

    const payload = await response.json();
    state.tracks = payload.tracks;
  } catch (error) {
    console.error("Unable to load catalogue:", error);
    showToast("Catalogue API is temporarily unavailable.");
  }
}

async function sendPlaybackEvent(eventType, trackId) {
  try {
    await fetch("/api/events", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        event_type: eventType,
        track_id: trackId,
        client_region: window.BLACKTUNES_CONFIG?.region
      })
    });
  } catch (error) {
    console.warn("Event telemetry failed:", error);
  }
}

function findTrack(trackId) {
  return state.tracks.find(
    track => Number(track.id) === Number(trackId)
  );
}

function resetProgress() {
  state.progress = 0;
  elements.progressFill.style.width = "0%";
  elements.currentTime.textContent = "0:00";
}

function selectTrack(trackId, autoplay = true) {
  const track = findTrack(trackId);

  if (!track) {
    showToast("Track information is unavailable.");
    return;
  }

  state.selectedTrack = track;
  resetProgress();

  elements.playerTitle.textContent = track.title;
  elements.playerArtist.textContent = track.artist;
  elements.totalTime.textContent = track.duration;
  elements.playerCover.style.background =
    `linear-gradient(135deg, ${track.accent}, #171720)`;

  updateLikeControls(track.id);

  if (autoplay) {
    startPlayback();
  }

  sendPlaybackEvent("track_selected", track.id);
}

function startPlayback() {
  if (!state.selectedTrack) {
    if (state.tracks.length > 0) {
      selectTrack(state.tracks[0].id, false);
    } else {
      return;
    }
  }

  state.playing = true;
  elements.mainPlayButton.textContent = "Ⅱ";
  elements.heroPlayButton.innerHTML = "<span>Ⅱ</span> Now playing";

  window.clearInterval(state.progressTimer);

  const totalSeconds = parseDuration(state.selectedTrack.duration);

  state.progressTimer = window.setInterval(() => {
    state.progress += 1;

    if (state.progress >= totalSeconds) {
      state.progress = 0;
      stopPlayback(false);
      playNextTrack();
      return;
    }

    const percentage = (state.progress / totalSeconds) * 100;

    elements.progressFill.style.width = `${percentage}%`;
    elements.currentTime.textContent = formatTime(state.progress);
  }, 1000);

  sendPlaybackEvent("play", state.selectedTrack.id);

  showToast(
    `Playing ${state.selectedTrack.title} · ${state.selectedTrack.artist}`
  );
}

function stopPlayback(showMessage = true) {
  state.playing = false;

  window.clearInterval(state.progressTimer);

  elements.mainPlayButton.textContent = "▶";
  elements.heroPlayButton.innerHTML = "<span>▶</span> Start listening";

  if (showMessage && state.selectedTrack) {
    showToast(`Paused ${state.selectedTrack.title}`);
  }

  if (state.selectedTrack) {
    sendPlaybackEvent("pause", state.selectedTrack.id);
  }
}

function togglePlayback() {
  if (state.playing) {
    stopPlayback();
  } else {
    startPlayback();
  }
}

function playNextTrack() {
  if (state.tracks.length === 0) {
    return;
  }

  const currentIndex = state.selectedTrack
    ? state.tracks.findIndex(
        track => track.id === state.selectedTrack.id
      )
    : -1;

  const nextIndex = (currentIndex + 1) % state.tracks.length;

  selectTrack(state.tracks[nextIndex].id);
}

function toggleLike(trackId) {
  const normalizedId = Number(trackId);

  if (state.likedTracks.has(normalizedId)) {
    state.likedTracks.delete(normalizedId);
    showToast("Removed from liked songs.");
  } else {
    state.likedTracks.add(normalizedId);
    showToast("Added to liked songs.");
    sendPlaybackEvent("track_liked", normalizedId);
  }

  updateLikeControls(normalizedId);
}

function updateLikeControls(trackId) {
  document
    .querySelectorAll(
      `[data-track-id="${trackId}"] .like-button,
       [data-track-id="${trackId}"] .row-like-button`
    )
    .forEach(button => {
      const liked = state.likedTracks.has(Number(trackId));

      button.classList.toggle("liked", liked);
      button.textContent = liked ? "♥" : "♡";
    });

  if (
    state.selectedTrack &&
    Number(state.selectedTrack.id) === Number(trackId)
  ) {
    const liked = state.likedTracks.has(Number(trackId));

    elements.playerLikeButton.textContent = liked ? "♥" : "♡";
    elements.playerLikeButton.style.color =
      liked ? "#ec4899" : "";
  }
}

function filterCatalogue(searchTerm) {
  const normalizedTerm = searchTerm.trim().toLowerCase();

  const searchableElements = document.querySelectorAll(
    ".track-card, .track-row"
  );

  searchableElements.forEach(element => {
    const content = element.dataset.search || "";
    const matches = content.includes(normalizedTerm);

    element.classList.toggle("hidden-by-search", !matches);
  });

  const visibleCards = document.querySelectorAll(
    ".track-card:not(.hidden-by-search)"
  ).length;

  if (normalizedTerm && visibleCards === 0) {
    showToast("No tracks matched your search.");
  }
}

function configureTrackControls() {
  document
    .querySelectorAll(".card-play-button, .row-play-button")
    .forEach(button => {
      button.addEventListener("click", event => {
        const container = event.currentTarget.closest(
          "[data-track-id]"
        );

        selectTrack(container.dataset.trackId);
      });
    });

  document
    .querySelectorAll(".like-button, .row-like-button")
    .forEach(button => {
      button.addEventListener("click", event => {
        const container = event.currentTarget.closest(
          "[data-track-id]"
        );

        toggleLike(container.dataset.trackId);
      });
    });
}

function configureNavigation() {
  document.querySelectorAll(".nav-item").forEach(item => {
    item.addEventListener("click", () => {
      document
        .querySelectorAll(".nav-item")
        .forEach(navItem => navItem.classList.remove("active"));

      item.classList.add("active");
      showToast(`${item.textContent.trim()} selected`);
    });
  });
}

function configurePlayerControls() {
  const controlButtons = document.querySelectorAll(
    ".control-buttons button"
  );

  if (controlButtons.length >= 5) {
    controlButtons[1].addEventListener("click", () => {
      if (state.tracks.length === 0) {
        return;
      }

      const currentIndex = state.selectedTrack
        ? state.tracks.findIndex(
            track => track.id === state.selectedTrack.id
          )
        : 0;

      const previousIndex =
        (currentIndex - 1 + state.tracks.length) %
        state.tracks.length;

      selectTrack(state.tracks[previousIndex].id);
    });

    controlButtons[3].addEventListener("click", playNextTrack);

    controlButtons[0].addEventListener("click", () => {
      if (state.tracks.length === 0) {
        return;
      }

      const randomIndex = Math.floor(
        Math.random() * state.tracks.length
      );

      selectTrack(state.tracks[randomIndex].id);
    });

    controlButtons[4].addEventListener("click", () => {
      resetProgress();
      startPlayback();
    });
  }
}

function configureKeyboardShortcuts() {
  document.addEventListener("keydown", event => {
    const targetIsInput =
      event.target instanceof HTMLInputElement ||
      event.target instanceof HTMLTextAreaElement;

    if ((event.ctrlKey || event.metaKey) && event.key === "k") {
      event.preventDefault();
      elements.searchInput?.focus();
    }

    if (event.code === "Space" && !targetIsInput) {
      event.preventDefault();
      togglePlayback();
    }
  });
}

async function initializeApplication() {
  await fetchTracks();

  configureTrackControls();
  configureNavigation();
  configurePlayerControls();
  configureKeyboardShortcuts();

  elements.searchInput?.addEventListener("input", event => {
    filterCatalogue(event.target.value);
  });

  elements.heroPlayButton?.addEventListener(
    "click",
    togglePlayback
  );

  elements.mainPlayButton?.addEventListener(
    "click",
    togglePlayback
  );

  elements.playerLikeButton?.addEventListener("click", () => {
    if (state.selectedTrack) {
      toggleLike(state.selectedTrack.id);
    }
  });

  elements.viewAllButton?.addEventListener("click", () => {
    document
      .querySelector(".track-list")
      ?.scrollIntoView({ behavior: "smooth" });
  });

  if (state.tracks.length > 0) {
    selectTrack(state.tracks[0].id, false);
  }

  showToast(
    `BlackTunes online · ${window.BLACKTUNES_CONFIG.region}`
  );
}

document.addEventListener(
  "DOMContentLoaded",
  initializeApplication
);
