export type AuthUser = {
  id: string;
  email: string;
  role: string;
};

export function getToken(): string | null {
  if (typeof window === "undefined") {
    return null;
  }

  return localStorage.getItem("auth_token");
}

export function getUser(): AuthUser | null {
  if (typeof window === "undefined") {
    return null;
  }

  const user = localStorage.getItem("auth_user");

  return user ? JSON.parse(user) : null;
}

export function setAuth(token: string, user: AuthUser) {
  localStorage.setItem("auth_token", token);
  localStorage.setItem("auth_user", JSON.stringify(user));
}

export function clearAuth() {
  localStorage.removeItem("auth_token");
  localStorage.removeItem("auth_user");
}

export function isAuthenticated() {
  return Boolean(getToken());
}