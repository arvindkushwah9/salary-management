import { Inbox, Loader2 } from "lucide-react";

type TableStateProps = {
  colSpan: number;
  loading?: boolean;
  loadingMessage?: string;
  emptyMessage?: string;
};

export default function TableState({
  colSpan,
  loading = false,
  loadingMessage = "Loading...",
  emptyMessage = "No records found.",
}: TableStateProps) {
  return (
    <tr>
      <td
        colSpan={colSpan}
        className="px-6 py-12 text-center"
      >
        {loading ? (
          <div className="flex items-center justify-center gap-2 text-sm text-slate-500">
            <Loader2
              size={18}
              className="animate-spin"
            />
            {loadingMessage}
          </div>
        ) : (
          <div className="flex flex-col items-center justify-center">
            <div className="rounded-full bg-slate-100 p-3 text-slate-400">
              <Inbox size={22} />
            </div>

            <p className="mt-3 text-sm font-medium text-slate-700">
              {emptyMessage}
            </p>
          </div>
        )}
      </td>
    </tr>
  );
}