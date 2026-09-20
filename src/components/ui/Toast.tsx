"use client";

import {
  CheckCircle2,
  CircleAlert,
  Info,
  X,
  XCircle,
} from "lucide-react";

export type ToastType = "success" | "error" | "info" | "warning";

export type ToastData = {
  id: string;
  type: ToastType;
  message: string;
};

type ToastProps = {
  toast: ToastData;
  onClose: (id: string) => void;
};

const styles: Record<
  ToastType,
  {
    container: string;
    icon: React.ReactNode;
  }
> = {
  success: {
    container: "border-emerald-200 bg-emerald-50 text-emerald-800",
    icon: <CheckCircle2 size={18} />,
  },
  error: {
    container: "border-red-200 bg-red-50 text-red-800",
    icon: <XCircle size={18} />,
  },
  info: {
    container: "border-blue-200 bg-blue-50 text-blue-800",
    icon: <Info size={18} />,
  },
  warning: {
    container: "border-amber-200 bg-amber-50 text-amber-800",
    icon: <CircleAlert size={18} />,
  },
};

export default function Toast({
  toast,
  onClose,
}: ToastProps) {
  const style = styles[toast.type];

  return (
    <div
      className={`flex min-w-[320px] max-w-md items-start gap-3 rounded-lg border px-4 py-3 shadow-lg ${style.container}`}
      role="alert"
    >
      <div className="mt-0.5 shrink-0">
        {style.icon}
      </div>

      <p className="flex-1 text-sm font-medium">
        {toast.message}
      </p>

      <button
        type="button"
        onClick={() => onClose(toast.id)}
        className="shrink-0 rounded p-0.5 opacity-60 hover:bg-black/5 hover:opacity-100"
        aria-label="Close notification"
      >
        <X size={16} />
      </button>
    </div>
  );
}