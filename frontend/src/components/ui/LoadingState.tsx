"use client";

import { Loader2 } from "lucide-react";

type LoadingStateProps = {
  message?: string;
  className?: string;
};

export default function LoadingState({
  message = "Loading...",
  className = "",
}: LoadingStateProps) {
  return (
    <div
      className={`flex min-h-[280px] items-center justify-center ${className}`}
    >
      <div className="flex items-center gap-2 text-sm text-slate-500">
        <Loader2 size={20} className="animate-spin" />
        <span>{message}</span>
      </div>
    </div>
  );
}