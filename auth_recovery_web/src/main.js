import { createClient } from "@supabase/supabase-js";
import "./styles.css";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

const statusBox = document.getElementById("status");
const resetForm = document.getElementById("reset-form");
const successView = document.getElementById("success-view");
const submitButton = document.getElementById("submit-button");
const passwordInput = document.getElementById("password");
const confirmPasswordInput = document.getElementById("confirm-password");

function showStatus(message, type = "info") {
  statusBox.textContent = message;
  statusBox.className = `status ${type}`;
}

function hideStatus() {
  statusBox.textContent = "";
  statusBox.className = "status hidden";
}

function showForm() {
  resetForm.classList.remove("hidden");
}

function hideForm() {
  resetForm.classList.add("hidden");
}

function showSuccess() {
  successView.classList.remove("hidden");
}

function getUrlParam(name) {
  const searchParams = new URLSearchParams(window.location.search);
  const hashParams = new URLSearchParams(
    window.location.hash.replace(/^#/, ""),
  );

  return searchParams.get(name) || hashParams.get(name);
}

function clearUrlParams() {
  window.history.replaceState({}, document.title, window.location.pathname);
}

if (!supabaseUrl || !supabaseAnonKey) {
  showStatus(
    "Missing Supabase configuration. Please contact Mina System support.",
    "error",
  );
  hideForm();
} else {
  const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    auth: {
      flowType: "pkce",
      detectSessionInUrl: false,
      persistSession: true,
      autoRefreshToken: true,
    },
  });

  initializeRecoverySession(supabase);

  resetForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    hideStatus();

    const password = passwordInput.value.trim();
    const confirmPassword = confirmPasswordInput.value.trim();

    if (password.length < 6) {
      showStatus("Password must be at least 6 characters.", "error");
      return;
    }

    if (password !== confirmPassword) {
      showStatus("Passwords do not match.", "error");
      return;
    }

    submitButton.disabled = true;
    submitButton.textContent = "Updating...";

    const { error } = await supabase.auth.updateUser({
      password,
    });

    if (error) {
      showStatus(error.message || "Password update failed.", "error");
      submitButton.disabled = false;
      submitButton.textContent = "Update Password";
      return;
    }

    await supabase.auth.signOut();

    hideForm();
    hideStatus();
    showSuccess();
  });
}

async function initializeRecoverySession(supabase) {
  showStatus("Validating password reset link...", "info");

  const errorDescription = getUrlParam("error_description");
  const errorCode = getUrlParam("error_code") || getUrlParam("error");

  if (errorCode || errorDescription) {
    showStatus(
      errorDescription ||
        "This password reset link is invalid or expired. Please request a new link.",
      "error",
    );
    hideForm();
    return;
  }

  const code = getUrlParam("code");
  const accessToken = getUrlParam("access_token");
  const refreshToken = getUrlParam("refresh_token");

  try {
    if (code) {
      const { error } = await supabase.auth.exchangeCodeForSession(code);

      if (error) {
        showStatus(
          error.message ||
            "This password reset link is invalid or expired. Please request a new link.",
          "error",
        );
        hideForm();
        return;
      }

      clearUrlParams();
      hideStatus();
      showForm();
      return;
    }

    if (accessToken && refreshToken) {
      const { error } = await supabase.auth.setSession({
        access_token: accessToken,
        refresh_token: refreshToken,
      });

      if (error) {
        showStatus(
          error.message ||
            "This password reset link is invalid or expired. Please request a new link.",
          "error",
        );
        hideForm();
        return;
      }

      clearUrlParams();
      hideStatus();
      showForm();
      return;
    }

    const { data } = await supabase.auth.getSession();

    if (data.session) {
      hideStatus();
      showForm();
      return;
    }

    showStatus(
      "No active password recovery session found. Please open the reset link from your email again.",
      "error",
    );
    hideForm();
  } catch (error) {
    showStatus(
      error?.message || "Something went wrong while validating the reset link.",
      "error",
    );
    hideForm();
  }
}
