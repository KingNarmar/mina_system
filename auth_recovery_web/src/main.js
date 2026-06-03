import { createClient } from "@supabase/supabase-js";
import "./styles.css";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

const brandBadge = document.getElementById("brand-badge");

const resetPasswordView = document.getElementById("reset-password-view");
const emailConfirmedView = document.getElementById("email-confirmed-view");
const notFoundView = document.getElementById("not-found-view");

const statusBox = document.getElementById("status");
const resetForm = document.getElementById("reset-form");
const successView = document.getElementById("success-view");
const submitButton = document.getElementById("submit-button");
const passwordInput = document.getElementById("password");
const confirmPasswordInput = document.getElementById("confirm-password");

const confirmationStatus = document.getElementById("confirmation-status");
const confirmationSuccess = document.getElementById("confirmation-success");

function showElement(element) {
  element.classList.remove("hidden");
}

function hideElement(element) {
  element.classList.add("hidden");
}

function showStatus(message, type = "info") {
  statusBox.textContent = message;
  statusBox.className = `status ${type}`;
}

function hideStatus() {
  statusBox.textContent = "";
  statusBox.className = "status hidden";
}

function showConfirmationStatus(message, type = "info") {
  confirmationStatus.textContent = message;
  confirmationStatus.className = `status ${type}`;
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

function getPageType() {
  const pathname = window.location.pathname;

  if (pathname.endsWith("/reset-password")) {
    return "reset-password";
  }

  if (pathname.endsWith("/email-confirmed")) {
    return "email-confirmed";
  }

  if (pathname.endsWith("/mina_system/") || pathname.endsWith("/mina_system")) {
    return "email-confirmed";
  }

  return "not-found";
}

function hasAuthError() {
  return (
    getUrlParam("error") ||
    getUrlParam("error_code") ||
    getUrlParam("error_description")
  );
}

function getAuthErrorMessage() {
  return (
    getUrlParam("error_description") ||
    getUrlParam("error_code") ||
    getUrlParam("error") ||
    "This link is invalid or expired. Please request a new link."
  );
}

async function verifyTokenHashSession(supabase, fallbackType) {
  const tokenHash = getUrlParam("token_hash");
  const type = getUrlParam("type") || fallbackType;

  if (!tokenHash || !type) {
    return { handled: false, error: null };
  }

  const { data, error } = await supabase.auth.verifyOtp({
    token_hash: tokenHash,
    type,
  });

  if (error) {
    return { handled: true, error };
  }

  if (!data.session) {
    return {
      handled: true,
      error: new Error(
        "The link was verified, but no active session was returned.",
      ),
    };
  }

  return { handled: true, error: null };
}

if (!supabaseUrl || !supabaseAnonKey) {
  hideElement(resetPasswordView);
  hideElement(emailConfirmedView);
  showElement(notFoundView);
} else {
  const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    auth: {
      flowType: "pkce",
      detectSessionInUrl: false,
      persistSession: true,
      autoRefreshToken: true,
    },
  });

  const pageType = getPageType();

  if (pageType === "reset-password") {
    brandBadge.textContent = "Secure account recovery";
    showElement(resetPasswordView);
    initializeRecoverySession(supabase);
  } else if (pageType === "email-confirmed") {
    brandBadge.textContent = "Secure account confirmation";
    showElement(emailConfirmedView);
    initializeEmailConfirmation(supabase);
  } else {
    showElement(notFoundView);
  }

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

    hideElement(resetForm);
    hideStatus();
    showElement(successView);
  });
}

async function initializeRecoverySession(supabase) {
  showStatus("Validating password reset link...", "info");

  if (hasAuthError()) {
    showStatus(getAuthErrorMessage(), "error");
    hideElement(resetForm);
    return;
  }

  try {
    const tokenHashResult = await verifyTokenHashSession(supabase, "recovery");

    if (tokenHashResult.handled) {
      if (tokenHashResult.error) {
        showStatus(
          tokenHashResult.error.message ||
            "This password reset link is invalid or expired. Please request a new link.",
          "error",
        );
        hideElement(resetForm);
        return;
      }

      clearUrlParams();
      hideStatus();
      showElement(resetForm);
      return;
    }

    const accessToken = getUrlParam("access_token");
    const refreshToken = getUrlParam("refresh_token");

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
        hideElement(resetForm);
        return;
      }

      clearUrlParams();
      hideStatus();
      showElement(resetForm);
      return;
    }

    const code = getUrlParam("code");

    if (code) {
      showStatus(
        "This reset link uses the old PKCE format and cannot be completed in this browser page. Please request a new reset link after updating the Supabase email template.",
        "error",
      );
      hideElement(resetForm);
      return;
    }

    showStatus(
      "No active password recovery session found. Please open the reset link from your email again.",
      "error",
    );
    hideElement(resetForm);
  } catch (error) {
    showStatus(
      error?.message || "Something went wrong while validating the reset link.",
      "error",
    );
    hideElement(resetForm);
  }
}

async function initializeEmailConfirmation(supabase) {
  if (hasAuthError()) {
    showConfirmationStatus(getAuthErrorMessage(), "error");
    return;
  }

  try {
    const tokenHashResult = await verifyTokenHashSession(supabase, "email");

    if (tokenHashResult.handled) {
      if (tokenHashResult.error) {
        showConfirmationStatus(
          tokenHashResult.error.message ||
            "This confirmation link is invalid or expired. Please request a new confirmation email.",
          "error",
        );
        return;
      }

      await supabase.auth.signOut();

      clearUrlParams();
      hideElement(confirmationStatus);
      showElement(confirmationSuccess);
      return;
    }

    const accessToken = getUrlParam("access_token");
    const refreshToken = getUrlParam("refresh_token");

    if (accessToken && refreshToken) {
      const { error } = await supabase.auth.setSession({
        access_token: accessToken,
        refresh_token: refreshToken,
      });

      if (error) {
        showConfirmationStatus(
          error.message ||
            "This confirmation link is invalid or expired. Please request a new confirmation email.",
          "error",
        );
        return;
      }

      await supabase.auth.signOut();

      clearUrlParams();
      hideElement(confirmationStatus);
      showElement(confirmationSuccess);
      return;
    }

    const code = getUrlParam("code");

    if (code) {
      showConfirmationStatus(
        "This confirmation link uses the old PKCE format and cannot be completed in this browser page. Please request a new confirmation email after updating the Supabase email template.",
        "error",
      );
      return;
    }

    showConfirmationStatus(
      "No confirmation session found. Please open the confirmation link from your email again.",
      "error",
    );
  } catch (error) {
    showConfirmationStatus(
      error?.message || "Something went wrong while confirming your account.",
      "error",
    );
  }
}
