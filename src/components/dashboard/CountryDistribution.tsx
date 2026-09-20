"use client";

import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";

type Props = {
  data: Record<string, number>;
};

export default function CountryDistribution({ data }: Props) {
  const chartData = Object.entries(data).map(([country, employees]) => ({
    country,
    employees,
  }));

  return (
    <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
      <div className="mb-5">
        <h2 className="font-semibold text-slate-900">
          Employees by Country
        </h2>

        <p className="mt-1 text-sm text-slate-500">
          Workforce distribution across countries
        </p>
      </div>

      <div className="h-72">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={chartData}>
            <CartesianGrid strokeDasharray="3 3" vertical={false} />

            <XAxis dataKey="country" />

            <YAxis />

            <Tooltip />

            <Bar
              dataKey="employees"
              radius={[5, 5, 0, 0]}
            />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}