// app.js
// Vanilla JS + Supabase client. Designed to run on GitHub Pages as a static SPA.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

  // ===================== Supabase =====================
const SUPABASE_URL = "https://rnatxpcjqszgjlvznhwd.supabase.co";
const SUPABASE_ANON_KEY =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJuYXR4cGNqcXN6Z2psdnpuaHdkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUzMTA4OTEsImV4cCI6MjA4MDg4Njg5MX0.rwuFyq0XdXDG822d2lUqdxHvTq4OAIUtdXebh0aXCCc";
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

  
// Local user id (anonymous, per-device)
const LOCAL_PROFILE_KEY = "tyl_profile_id";

let currentProfile = null;
let habitsCache = [];
let todayCheckin = null;

// Utility: today's date (YYYY-MM-DD)
function todayISO() {
  return new Date().toISOString().slice(0, 10);
}

// ---------- ON LOAD ----------

document.addEventListener("DOMContentLoaded", () => {
  wireOnboarding();
  wireNav();
  wireToday();
  wireJourneys();
  wireJournal();
  wireStats();
  wireSettings();

  init();
});

async function init() {
  const profileId = window.localStorage.getItem(LOCAL_PROFILE_KEY);
  if (!profileId) {
    // show onboarding
    showPanel("onboarding");
    return;
  }

  const { data, error } = await supabase
    .from("profiles")
    .select("*")
    .eq("id", profileId)
    .maybeSingle();

  if (error || !data) {
    console.warn("Profile missing or error, starting fresh:", error);
    window.localStorage.removeItem(LOCAL_PROFILE_KEY);
    showPanel("onboarding");
    return;
  }

  currentProfile = data;
  showMainApp();
}

// ---------- UI HELPERS ----------

function showPanel(panelId) {
  const onboarding = document.getElementById("onboarding");
  const appMain = document.getElementById("app-main");
  const nav = document.getElementById("main-nav");

  if (panelId === "onboarding") {
    onboarding.classList.add("active");
    onboarding.classList.remove("hidden");
    appMain.classList.add("hidden");
    appMain.classList.remove("active");
    nav.classList.add("hidden");
  } else {
    onboarding.classList.add("hidden");
    onboarding.classList.remove("active");
    appMain.classList.add("active");
    appMain.classList.remove("hidden");
    nav.classList.remove("hidden");
  }
}

function showMainApp() {
  showPanel("app-main");
  updateIdentityUI();
  loadHabits();
  loadTodayCheckin();
  loadRecentJournalEntries();
  loadStatsSummary();
}

function updateIdentityUI() {
  if (!currentProfile) return;
  const identityLine = document.getElementById("identity-line");
  const valuesLine = document.getElementById("values-line");

  identityLine.textContent =
    currentProfile.identity_statement ||
    "You are a person in progress, not defined by your past.";

  if (currentProfile.values && currentProfile.values.trim().length > 0) {
    valuesLine.textContent = `Values you chose: ${currentProfile.values}`;
  } else {
    valuesLine.textContent =
      "You can add or update your values anytime in Settings.";
  }

  // Settings form defaults
  const settingsForm = document.getElementById("settings-form");
  if (settingsForm) {
    settingsForm.identity_statement.value = currentProfile.identity_statement || "";
    settingsForm.values.value = currentProfile.values || "";
  }
}

// ---------- NAVIGATION ----------

function wireNav() {
  const nav = document.getElementById("main-nav");
  if (!nav) return;

  nav.addEventListener("click", (e) => {
    const btn = e.target.closest("button[data-view]");
    if (!btn) return;
    const targetView = btn.dataset.view;

    document
      .querySelectorAll(".nav-btn")
      .forEach((b) => b.classList.remove("nav-btn-active"));
    btn.classList.add("nav-btn-active");

    document.querySelectorAll(".view").forEach((v) => v.classList.add("hidden"));
    document.getElementById(`view-${targetView}`).classList.remove("hidden");
    document.getElementById(`view-${targetView}`).classList.add("active");

    if (targetView === "stats") {
      loadStatsSummary();
    } else if (targetView === "journal") {
      loadRecentJournalEntries();
    } else if (targetView === "journeys") {
      renderPathsFromProfile();
      renderHabitsList(); // show habits in that view too
    }
  });
}

// ---------- ONBOARDING FLOW ----------

function wireOnboarding() {
  const form = document.getElementById("onboarding-form");
  if (!form) return;

  const steps = Array.from(form.querySelectorAll(".onboarding-step"));
  const nextBtn = document.getElementById("onboarding-next");
  const backBtn = document.getElementById("onboarding-back");
  const finishBtn = document.getElementById("onboarding-finish");
  let currentStepIndex = 0;

  function updateStepVisibility() {
    steps.forEach((step, idx) => {
      step.classList.toggle("hidden", idx !== currentStepIndex);
    });

    backBtn.classList.toggle("hidden", currentStepIndex === 0);
    if (currentStepIndex === steps.length - 1) {
      nextBtn.classList.add("hidden");
      finishBtn.classList.remove("hidden");
    } else {
      nextBtn.classList.remove("hidden");
      finishBtn.classList.add("hidden");
    }
  }

  nextBtn.addEventListener("click", () => {
    if (!validateCurrentOnboardingStep(steps[currentStepIndex])) return;
    currentStepIndex = Math.min(currentStepIndex + 1, steps.length - 1);
    updateStepVisibility();
  });

  backBtn.addEventListener("click", () => {
    currentStepIndex = Math.max(currentStepIndex - 1, 0);
    updateStepVisibility();
  });

  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    if (!validateCurrentOnboardingStep(steps[currentStepIndex])) return;
    await createProfileFromOnboarding(form);
  });

  updateStepVisibility();
}

function validateCurrentOnboardingStep(stepEl) {
  // simple validation: just check required inputs in this step
  const requiredInputs = Array.from(
    stepEl.querySelectorAll("input[required], select[required]")
  );
  for (const input of requiredInputs) {
    if (!input.value || (input.type === "radio" && !stepEl.querySelector(`input[name="${input.name}"]:checked`))) {
      input.focus();
      return false;
    }
  }

  // extra: ensure at least 1 path in step 2
  if (stepEl.dataset.step === "2") {
    const checked = stepEl.querySelectorAll('input[name="paths"]:checked');
    if (checked.length === 0) {
      alert("Please choose at least one area you care about.");
      return false;
    }
  }

  return true;
}

async function createProfileFromOnboarding(form) {
  const formData = new FormData(form);
  const primary_focus = formData.get("primary_focus");
  const paths = formData.getAll("paths");
  const identity_statement = formData.get("identity_statement") || "";
  const values = formData.get("values") || "";
  const tiny_habit = formData.get("tiny_habit") || "";
  const tiny_habit_path = formData.get("tiny_habit_path") || null;

  const { data, error } = await supabase
    .from("profiles")
    .insert({
      primary_focus,
      paths,
      identity_statement,
      values,
    })
    .select("*")
    .single();

  if (error) {
    console.error("Error creating profile:", error);
    alert("There was a problem saving your profile. Please try again.");
    return;
  }

  currentProfile = data;
  window.localStorage.setItem(LOCAL_PROFILE_KEY, currentProfile.id);

  // Insert initial tiny habit
  if (tiny_habit.trim().length > 0) {
    await supabase.from("habits").insert({
      user_id: currentProfile.id,
      name: tiny_habit.trim(),
      path: tiny_habit_path || null,
      is_active: true,
    });
  }

  showMainApp();
}

// ---------- TODAY VIEW ----------

function wireToday() {
  const checkinForm = document.getElementById("checkin-form");
  const lifestyleForm = document.getElementById("lifestyle-form");
  const quickJournalForm = document.getElementById("quick-journal-form");
  const addHabitBtn = document.getElementById("add-habit-btn");

  if (checkinForm) {
    checkinForm.addEventListener("submit", async (e) => {
      e.preventDefault();
      await saveDailyCheckin(new FormData(checkinForm));
    });
  }

  if (lifestyleForm) {
    lifestyleForm.addEventListener("submit", async (e) => {
      e.preventDefault();
      await saveLifestyle(new FormData(lifestyleForm));
    });
  }

  if (quickJournalForm) {
    quickJournalForm.addEventListener("submit", async (e) => {
      e.preventDefault();
      await saveQuickJournal(new FormData(quickJournalForm));
    });
  }

  if (addHabitBtn) {
    addHabitBtn.addEventListener("click", () => {
      // Switch to Journeys tab + scroll to habit form
      document.querySelector('button[data-view="journeys"]').click();
      document.getElementById("add-habit-form").scrollIntoView({ behavior: "smooth" });
    });
  }
}

async function loadHabits() {
  if (!currentProfile) return;
  const { data, error } = await supabase
    .from("habits")
    .select("*")
    .eq("user_id", currentProfile.id)
    .eq("is_active", true)
    .order("created_at", { ascending: true });

  if (error) {
    console.error("Error loading habits:", error);
    return;
  }

  habitsCache = data || [];
  renderHabitsList();
}

function renderHabitsList() {
  const list = document.getElementById("habits-list");
  if (!list) return;
  list.innerHTML = "";

  if (!habitsCache || habitsCache.length === 0) {
    const li = document.createElement("li");
    li.className = "habit-item";
    li.textContent =
      "No tiny habits yet. Start with just one action so small it’s almost impossible to skip.";
    list.appendChild(li);
    return;
  }

  const completedIds = todayCheckin?.completed_habit_ids || [];

  habitsCache.forEach((habit) => {
    const li = document.createElement("li");
    li.className = "habit-item";

    const checkbox = document.createElement("input");
    checkbox.type = "checkbox";
    checkbox.checked = completedIds.includes(habit.id);

    checkbox.addEventListener("change", () => {
      toggleHabitCompletionForToday(habit.id, checkbox.checked);
    });

    const text = document.createElement("div");
    text.className = "habit-text";
    text.textContent = habit.name;

    const meta = document.createElement("div");
    meta.className = "habit-meta";
    meta.textContent = habit.path ? `Path: ${prettyPath(habit.path)}` : "";

    li.appendChild(checkbox);
    const textWrapper = document.createElement("div");
    textWrapper.appendChild(text);
    textWrapper.appendChild(meta);
    li.appendChild(textWrapper);
    list.appendChild(li);
  });
}

function prettyPath(path) {
  const map = {
    body: "Body",
    mind: "Mind",
    heart: "Heart",
    spirit: "Spirit",
    relationships: "Relationships",
    purpose: "Purpose",
  };
  return map[path] || path;
}

async function loadTodayCheckin() {
  if (!currentProfile) return;

  const { data, error } = await supabase
    .from("daily_checkins")
    .select("*")
    .eq("user_id", currentProfile.id)
    .eq("date", todayISO())
    .maybeSingle();

  if (error && error.code !== "PGRST116") {
    console.error("Error loading checkin:", error);
  }

  todayCheckin = data || null;
  populateCheckinFormFromData();
  renderHabitsList(); // to sync checked state
}

function populateCheckinFormFromData() {
  const form = document.getElementById("checkin-form");
  if (!form || !todayCheckin) return;

  if (todayCheckin.mood) form.mood.value = String(todayCheckin.mood);
  if (todayCheckin.urge_level) form.urge_level.value = todayCheckin.urge_level;
  form.slip.checked = todayCheckin.slip || false;
  form.notes.value = todayCheckin.notes || "";

  const halt = todayCheckin.halt || {};
  form.halt_hungry.checked = !!halt.hungry;
  form.halt_angry.checked = !!halt.angry;
  form.halt_lonely.checked = !!halt.lonely;
  form.halt_tired.checked = !!halt.tired;
}

async function saveDailyCheckin(formData) {
  if (!currentProfile) return;
  const statusEl = document.getElementById("checkin-status");
  statusEl.textContent = "Saving...";
  statusEl.className = "status-line";

  const mood = formData.get("mood");
  const urge_level = formData.get("urge_level") || null;
  const slip = formData.get("slip") === "on";
  const notes = formData.get("notes") || "";
  const halt = {
    hungry: formData.get("halt_hungry") === "on",
    angry: formData.get("halt_angry") === "on",
    lonely: formData.get("halt_lonely") === "on",
    tired: formData.get("halt_tired") === "on",
  };

  const payload = {
    user_id: currentProfile.id,
    date: todayISO(),
    mood: mood ? Number(mood) : null,
    urge_level,
    slip,
    notes,
    halt,
    completed_habit_ids: todayCheckin?.completed_habit_ids || [],
    lifestyle: todayCheckin?.lifestyle || {},
  };

  const { data, error } = await supabase
    .from("daily_checkins")
    .upsert(payload, { onConflict: "user_id,date" })
    .select("*")
    .single();

  if (error) {
    console.error("Error saving checkin:", error);
    statusEl.textContent = "Could not save. Please try again.";
    statusEl.classList.add("error");
    return;
  }

  todayCheckin = data;

  if (slip) {
    statusEl.textContent =
      "Saved. A slip is data, not doom. You’re still the kind of person who learns and continues.";
  } else {
    statusEl.textContent = "Saved. Every honest check-in is a vote for your future self.";
  }
  statusEl.classList.add("ok");
  loadStatsSummary(); // update big picture
}

async function toggleHabitCompletionForToday(habitId, isCompleted) {
  if (!currentProfile) return;

  const current = todayCheckin?.completed_habit_ids || [];
  let newIds;
  if (isCompleted) {
    if (!current.includes(habitId)) {
      newIds = [...current, habitId];
    } else newIds = current;
  } else {
    newIds = current.filter((id) => id !== habitId);
  }

  const base = todayCheckin || {
    user_id: currentProfile.id,
    date: todayISO(),
  };

  const payload = {
    ...base,
    completed_habit_ids: newIds,
  };

  const { data, error } = await supabase
    .from("daily_checkins")
    .upsert(payload, { onConflict: "user_id,date" })
    .select("*")
    .single();

  if (error) {
    console.error("Error updating habit completion:", error);
    return;
  }

  todayCheckin = data;
  const statusEl = document.getElementById("checkin-status");
  statusEl.textContent = "Tiny habit saved. Consistency beats intensity.";
  statusEl.className = "status-line ok";

  loadStatsSummary();
}

async function saveLifestyle(formData) {
  if (!currentProfile) return;
  const statusEl = document.getElementById("lifestyle-status");
  statusEl.textContent = "Saving...";
  statusEl.className = "status-line";

  const lifestyle = {
    sleep_ok: formData.get("sleep_ok") === "on",
    moved_body: formData.get("moved_body") === "on",
    ate_ok: formData.get("ate_ok") === "on",
    connected: formData.get("connected") === "on",
  };

  const base = todayCheckin || {
    user_id: currentProfile.id,
    date: todayISO(),
  };

  const payload = {
    ...base,
    lifestyle,
    completed_habit_ids: todayCheckin?.completed_habit_ids || [],
    mood: base.mood ?? null,
    urge_level: base.urge_level ?? null,
    slip: base.slip ?? false,
    notes: base.notes ?? "",
    halt: base.halt || {},
  };

  const { data, error } = await supabase
    .from("daily_checkins")
    .upsert(payload, { onConflict: "user_id,date" })
    .select("*")
    .single();

  if (error) {
    console.error("Error saving lifestyle:", error);
    statusEl.textContent = "Could not save. Please try again.";
    statusEl.classList.add("error");
    return;
  }

  todayCheckin = data;
  statusEl.textContent = "Saved. A stronger body makes self-control easier.";
  statusEl.classList.add("ok");
  loadStatsSummary();
}

async function saveQuickJournal(formData) {
  if (!currentProfile) return;
  const statusEl = document.getElementById("quick-journal-status");
  statusEl.textContent = "Saving...";
  statusEl.className = "status-line";

  const content = (formData.get("entry") || "").trim();
  if (!content) {
    statusEl.textContent = "Write at least a sentence.";
    statusEl.classList.add("error");
    return;
  }

  const { error } = await supabase.from("journal_entries").insert({
    user_id: currentProfile.id,
    title: "Daily reflection",
    content,
  });

  if (error) {
    console.error("Error saving quick journal:", error);
    statusEl.textContent = "Could not save. Please try again.";
    statusEl.classList.add("error");
    return;
  }

  statusEl.textContent = "Saved. Naming your growth and gratitude rewires your story.";
  statusEl.classList.add("ok");
  document.getElementById("quick-journal-form").reset();
  loadRecentJournalEntries();
}

// ---------- JOURNEYS (PATHS & HABITS) ----------

function wireJourneys() {
  const form = document.getElementById("add-habit-form");
  if (form) {
    form.addEventListener("submit", async (e) => {
      e.preventDefault();
      await addNewHabit(new FormData(form));
    });
  }
}

function renderPathsFromProfile() {
  const container = document.getElementById("paths-list");
  if (!container) return;
  container.innerHTML = "";

  const paths = currentProfile?.paths || [];
  if (!paths.length) {
    container.textContent =
      "No paths selected yet. You can add areas like Body, Mind, Relationships in Settings.";
    return;
  }

  paths.forEach((p) => {
    const label = document.createElement("span");
    label.className = "pill";
    const pretty = prettyPath(p);
    label.innerHTML = `<span>${pretty}</span>`;
    container.appendChild(label);
  });
}

async function addNewHabit(formData) {
  if (!currentProfile) return;
  const statusEl = document.getElementById("add-habit-status");
  statusEl.textContent = "Saving...";
  statusEl.className = "status-line";

  const name = (formData.get("habit_name") || "").trim();
  const path = formData.get("habit_path") || null;

  if (!name) {
    statusEl.textContent = "Please describe the tiny habit.";
    statusEl.classList.add("error");
    return;
  }

  const { error } = await supabase.from("habits").insert({
    user_id: currentProfile.id,
    name,
    path,
    is_active: true,
  });

  if (error) {
    console.error("Error adding habit:", error);
    statusEl.textContent = "Could not save. Please try again.";
    statusEl.classList.add("error");
    return;
  }

  statusEl.textContent = "Saved. Keep it tiny enough that even on bad days you can still do it.";
  statusEl.classList.add("ok");
  document.getElementById("add-habit-form").reset();
  loadHabits();
}

// ---------- JOURNAL FULL VIEW ----------

function wireJournal() {
  const form = document.getElementById("journal-form");
  if (form) {
    form.addEventListener("submit", async (e) => {
      e.preventDefault();
      await saveJournalEntry(new FormData(form));
    });
  }
}

async function saveJournalEntry(formData) {
  if (!currentProfile) return;
  const statusEl = document.getElementById("journal-status");
  statusEl.textContent = "Saving...";
  statusEl.className = "status-line";

  const title = (formData.get("title") || "").trim() || "Untitled";
  const content = (formData.get("content") || "").trim();

  if (!content) {
    statusEl.textContent = "Write something, even if just a few words.";
    statusEl.classList.add("error");
    return;
  }

  const { error } = await supabase.from("journal_entries").insert({
    user_id: currentProfile.id,
    title,
    content,
  });

  if (error) {
    console.error("Error saving journal entry:", error);
    statusEl.textContent = "Could not save. Please try again.";
    statusEl.classList.add("error");
    return;
  }

  statusEl.textContent = "Saved. Your story is being rewritten, one entry at a time.";
  statusEl.classList.add("ok");
  document.getElementById("journal-form").reset();
  loadRecentJournalEntries();
}

async function loadRecentJournalEntries() {
  if (!currentProfile) return;
  const list = document.getElementById("journal-list");
  if (!list) return;

  list.innerHTML = "Loading...";

  const { data, error } = await supabase
    .from("journal_entries")
    .select("*")
    .eq("user_id", currentProfile.id)
    .order("created_at", { ascending: false })
    .limit(20);

  if (error) {
    console.error("Error loading journal entries:", error);
    list.textContent = "Could not load entries.";
    return;
  }

  if (!data || data.length === 0) {
    list.textContent = "No entries yet. Start with just a sentence.";
    return;
  }

  list.innerHTML = "";
  data.forEach((entry) => {
    const li = document.createElement("li");
    li.className = "journal-item";

    const titleEl = document.createElement("div");
    titleEl.className = "journal-item-title";
    titleEl.textContent = entry.title || "Untitled";

    const meta = document.createElement("div");
    meta.className = "journal-item-meta";
    const dateStr = new Date(entry.created_at).toLocaleString();
    meta.textContent = dateStr;

    const body = document.createElement("div");
    body.className = "journal-item-body";
    body.textContent = entry.content;

    li.appendChild(titleEl);
    li.appendChild(meta);
    li.appendChild(body);
    list.appendChild(li);
  });
}

// ---------- STATS VIEW ----------

function wireStats() {
  // nothing to wire yet, we just load on view
}

async function loadStatsSummary() {
  if (!currentProfile) return;
  const box = document.getElementById("stats-summary");
  if (!box) return;

  box.textContent = "Calculating...";

  const { data, error } = await supabase
    .from("daily_checkins")
    .select("date, slip, completed_habit_ids")
    .eq("user_id", currentProfile.id)
    .order("date", { ascending: true });

  if (error) {
    console.error("Error loading stats:", error);
    box.textContent = "Could not load stats.";
    return;
  }

  if (!data || data.length === 0) {
    box.textContent =
      "No history yet. As you check in, you’ll see big-picture trends here. Remember: progress, not perfection.";
    return;
  }

  const totalDays = data.length;
  const slipDays = data.filter((d) => d.slip).length;
  const noSlipDays = totalDays - slipDays;
  const totalHabitCompletions = data.reduce(
    (acc, d) => acc + (d.completed_habit_ids?.length || 0),
    0
  );

  // current effort streak = consecutive days (from latest backwards) with any check-in
  let effortStreak = 0;
  const today = todayISO();
  const seenDates = new Set(data.map((d) => d.date));
  let cursor = today;
  while (seenDates.has(cursor)) {
    effortStreak += 1;
    const prev = new Date(cursor);
    prev.setDate(prev.getDate() - 1);
    cursor = prev.toISOString().slice(0, 10);
  }

  // days since last slip
  const lastSlip = [...data].reverse().find((d) => d.slip);
  let daysSinceLastSlip = null;
  if (lastSlip) {
    const last = new Date(lastSlip.date);
    const now = new Date(today);
    const diffMs = now - last;
    daysSinceLastSlip = Math.floor(diffMs / (1000 * 60 * 60 * 24));
  }

  box.innerHTML = `
    <p><strong>Total days you showed up:</strong> ${totalDays}</p>
    <p><strong>Days without a slip (total, not necessarily in a row):</strong> ${noSlipDays}</p>
    <p><strong>Current "effort streak":</strong> ${effortStreak} day(s) of showing up in a row.</p>
    <p><strong>Total tiny habit completions logged:</strong> ${totalHabitCompletions}</p>
    ${
      daysSinceLastSlip === null
        ? "<p>You haven’t logged any slip here yet, or you haven’t used that checkbox. Either way, this space is here to help, not judge.</p>"
        : `<p><strong>Days since last slip (approx):</strong> ${daysSinceLastSlip} day(s).</p>`
    }
    <p>
      Remember: one bad day doesn’t erase growth. We look at trends.  
      Each day you show up here is evidence that you care about your future.
    </p>
  `;
}

// ---------- SETTINGS / PROFILE ----------

function wireSettings() {
  const form = document.getElementById("settings-form");
  const resetBtn = document.getElementById("reset-local-btn");

  if (form) {
    form.addEventListener("submit", async (e) => {
      e.preventDefault();
      await saveSettings(new FormData(form));
    });
  }

  if (resetBtn) {
    resetBtn.addEventListener("click", () => {
      if (
        confirm(
          "This will forget your anonymous ID on this device. You'll go through onboarding again next time. Continue?"
        )
      ) {
        window.localStorage.removeItem(LOCAL_PROFILE_KEY);
        window.location.reload();
      }
    });
  }
}

async function saveSettings(formData) {
  if (!currentProfile) return;
  const statusEl = document.getElementById("settings-status");
  statusEl.textContent = "Saving...";
  statusEl.className = "status-line";

  const identity_statement = (formData.get("identity_statement") || "").trim();
  const values = (formData.get("values") || "").trim();

  const { data, error } = await supabase
    .from("profiles")
    .update({ identity_statement, values })
    .eq("id", currentProfile.id)
    .select("*")
    .single();

  if (error) {
    console.error("Error updating profile:", error);
    statusEl.textContent = "Could not save. Please try again.";
    statusEl.classList.add("error");
    return;
  }

  currentProfile = data;
  updateIdentityUI();
  statusEl.textContent = "Saved. Your identity and values are your compass, not this app.";
  statusEl.classList.add("ok");
}
