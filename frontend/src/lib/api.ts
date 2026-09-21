const API_URL =
  process.env.NEXT_PUBLIC_API_URL || "http://localhost:3001/api/v1";

type ApiOptions = RequestInit & {
  auth?: boolean;
};

export async function apiFetch<T>(
  endpoint: string,
  options: ApiOptions = {}
): Promise<T> {
  const { auth = true, headers, ...fetchOptions } = options;

  const requestHeaders = new Headers(headers);

  requestHeaders.set("Content-Type", "application/json");

  if (auth && typeof window !== "undefined") {
    const token = localStorage.getItem("auth_token");

    if (token) {
      requestHeaders.set("Authorization", `Bearer ${token}`);
    }
  }

  const response = await fetch(`${API_URL}${endpoint}`, {
    ...fetchOptions,
    headers: requestHeaders,
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));

    throw new Error(
      error?.error?.message || "Something went wrong"
    );
  }

  return response.json();
}

export async function downloadFile(
  endpoint: string,
  filename: string
) {
  const response = await fetch(`${API_URL}${endpoint}`, {
    headers: getAuthHeaders(),
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));

    throw new Error(
      error?.error?.message || "Download failed"
    );
  }

  const blob = await response.blob();

  const url = window.URL.createObjectURL(blob);

  const link = document.createElement("a");
  link.href = url;
  link.download = filename;

  document.body.appendChild(link);
  link.click();

  link.remove();
  window.URL.revokeObjectURL(url);
}

function getAuthHeaders() {
  const headers: Record<string, string> = {};

  if (typeof window !== "undefined") {
    const token = localStorage.getItem("auth_token");

    if (token) {
      headers.Authorization = `Bearer ${token}`;
    }
  }

  return headers;
}