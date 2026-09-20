import { CircleAlert, RefreshCw } from "lucide-react";

type ErrorStateProps = {
  message?: string;
  onRetry?: () => void;
};

export default function ErrorState({
  message = "Something went wrong.",
  onRetry,
}: ErrorStateProps) {
  return (
    <div className="flex flex-col items-center justify-center px-6 py-12 text-center">
      <div className="rounded-full bg-red-50 p-3 text-red-500">
        <CircleAlert size={24} />
      </div>

      <h3 className="mt-4 text-sm font-semibold text-slate-900">
        Unable to load data
      </h3>

      <p className="mt-1 max-w-md text-sm text-slate-500">
        {message}
      </p>

      {onRetry && (
        <button
          type="button"
          onClick={onRetry}
          className="mt-5 inline-flex items-center gap-2 rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50"
        >
          <RefreshCw size={16} />
          Try again
        </button>
      )}
    </div>
  );
}