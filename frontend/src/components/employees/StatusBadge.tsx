type Props = {
  status: "active" | "terminated" | "on_leave";
};

const styles = {
  active: "bg-emerald-50 text-emerald-700 ring-emerald-600/20",
  terminated: "bg-red-50 text-red-700 ring-red-600/20",
  on_leave: "bg-amber-50 text-amber-700 ring-amber-600/20",
};

const labels = {
  active: "Active",
  terminated: "Terminated",
  on_leave: "On leave",
};

export default function StatusBadge({ status }: Props) {
  return (
    <span
      className={`inline-flex rounded-full px-2.5 py-1 text-xs font-medium ring-1 ring-inset ${styles[status]}`}
    >
      {labels[status]}
    </span>
  );
}