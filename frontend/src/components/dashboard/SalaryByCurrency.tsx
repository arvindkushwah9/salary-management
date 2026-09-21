import { DashboardData } from "@/lib/types";

type Props = {
  data: DashboardData["salary"]["statistics_by_currency"];
};

const formatter = new Intl.NumberFormat("en-US", {
  maximumFractionDigits: 0,
});

export default function SalaryByCurrency({ data }: Props) {
  return (
    <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
      <div className="mb-5">
        <h2 className="font-semibold text-slate-900">
          Salary Statistics
        </h2>

        <p className="mt-1 text-sm text-slate-500">
          Salary ranges are shown within each currency
        </p>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-slate-200 text-left text-xs uppercase tracking-wider text-slate-400">
              <th className="pb-3 font-medium">Currency</th>
              <th className="pb-3 font-medium">Minimum</th>
              <th className="pb-3 font-medium">Average</th>
              <th className="pb-3 font-medium">Maximum</th>
            </tr>
          </thead>

          <tbody>
            {data.map((item) => (
              <tr
                key={item.currency}
                className="border-b border-slate-100 last:border-0"
              >
                <td className="py-3 font-semibold text-slate-800">
                  {item.currency}
                </td>

                <td className="py-3 text-slate-600">
                  {formatter.format(item.minimum)}
                </td>

                <td className="py-3 font-medium text-slate-900">
                  {formatter.format(item.average)}
                </td>

                <td className="py-3 text-slate-600">
                  {formatter.format(item.maximum)}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}