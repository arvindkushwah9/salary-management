"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import {
  Plus,
  Eye,
  WalletCards,
  CircleAlert,
} from "lucide-react";

import AppShell from "@/components/layout/AppShell";
import { apiFetch } from "@/lib/api";
import { PayrollRun, PayrollRunListResponse } from "@/lib/types";
import { formatCurrency, formatDate } from "@/lib/formatters";
import TableState from "@/components/ui/TableState";

const statusStyles: Record<string, string> = {
  draft: "bg-slate-100 text-slate-700",
  processing: "bg-blue-100 text-blue-700",
  approved: "bg-emerald-100 text-emerald-700",
  disbursed: "bg-purple-100 text-purple-700",
};

export default function PayrollPage() {
  const [payrollRuns, setPayrollRuns] = useState<PayrollRun[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const loadPayrollRuns = async () => {
    try {
      setLoading(true);
      setError("");

      const response = await apiFetch<PayrollRunListResponse>(
        "/payroll_runs"
      );

      setPayrollRuns(response.data);
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : "Failed to load payroll runs"
      );
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadPayrollRuns();
  }, []);

  return (
    <AppShell>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <div className="flex items-center gap-3">
              <div className="rounded-lg bg-indigo-100 p-2 text-indigo-600">
                <WalletCards size={22} />
              </div>

              <div>
                <h1 className="text-2xl font-semibold text-slate-900">
                  Payroll
                </h1>

                <p className="text-sm text-slate-500">
                  Manage monthly payroll runs and employee payslips.
                </p>
              </div>
            </div>
          </div>

          <Link
            href="/payroll/new"
            className="inline-flex items-center justify-center gap-2 rounded-lg bg-indigo-600 px-4 py-2.5 text-sm font-medium text-white transition hover:bg-indigo-700"
          >
            <Plus size={18} />
            Create Payroll Run
          </Link>
        </div>

        {/* Table */}
        <div className="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-slate-200">
              <thead className="bg-slate-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-slate-500">
                    Period
                  </th>

                  <th className="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-slate-500">
                    Currency
                  </th>

                  <th className="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-slate-500">
                    Status
                  </th>

                  <th className="px-6 py-3 text-right text-xs font-semibold uppercase tracking-wide text-slate-500">
                    Gross
                  </th>

                  <th className="px-6 py-3 text-right text-xs font-semibold uppercase tracking-wide text-slate-500">
                    Deductions
                  </th>

                  <th className="px-6 py-3 text-right text-xs font-semibold uppercase tracking-wide text-slate-500">
                    Net
                  </th>

                  <th className="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-slate-500">
                    Created
                  </th>

                  <th className="px-6 py-3 text-right text-xs font-semibold uppercase tracking-wide text-slate-500">
                    Actions
                  </th>
                </tr>
              </thead>

              <tbody className="divide-y divide-slate-100">
                {loading ? (
                  <TableState
                    colSpan={8}
                    loading
                    loadingMessage="Loading payroll runs..."
                  />
                ) : error ? (
                  <tr>
                    <td colSpan={8} className="px-6 py-12 text-center">
                      <div className="flex flex-col items-center">
                        <div className="rounded-full bg-red-50 p-3 text-red-500">
                          <CircleAlert size={22} />
                        </div>

                        <p className="mt-3 text-sm font-medium text-slate-700">
                          Unable to load payroll runs
                        </p>

                        <p className="mt-1 max-w-md text-sm text-slate-500">
                          {error}
                        </p>

                        <button
                          type="button"
                          onClick={loadPayrollRuns}
                          className="mt-4 rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-medium text-slate-700 shadow-sm transition hover:bg-slate-50"
                        >
                          Try again
                        </button>
                      </div>
                    </td>
                  </tr>
                ) : payrollRuns.length === 0 ? (
                  <TableState
                    colSpan={8}
                    emptyMessage="No payroll runs found."
                  />
                ) : (
                  payrollRuns.map((payroll) => (
                    <tr
                      key={payroll.id}
                      className="hover:bg-slate-50"
                    >
                      <td className="whitespace-nowrap px-6 py-4 text-sm font-medium text-slate-900">
                        {payroll.payroll_period}
                      </td>

                      <td className="px-6 py-4">
                        <span className="rounded-md bg-slate-100 px-2.5 py-1 text-xs font-semibold text-slate-700">
                          {payroll.currency}
                        </span>
                      </td>

                      <td className="px-6 py-4">
                        <span
                          className={`inline-flex rounded-full px-2.5 py-1 text-xs font-medium ${
                            statusStyles[payroll.status] ??
                            "bg-slate-100 text-slate-700"
                          }`}
                        >
                          {payroll.status
                            .replace("_", " ")
                            .replace(/\b\w/g, (char) =>
                              char.toUpperCase()
                            )}
                        </span>
                      </td>

                      <td className="whitespace-nowrap px-6 py-4 text-right text-sm text-slate-700">
                        {formatCurrency(
                          payroll.total_gross,
                          payroll.currency
                        )}
                      </td>

                      <td className="whitespace-nowrap px-6 py-4 text-right text-sm text-slate-700">
                        {formatCurrency(
                          payroll.total_deductions,
                          payroll.currency
                        )}
                      </td>

                      <td className="whitespace-nowrap px-6 py-4 text-right text-sm font-medium text-slate-900">
                        {formatCurrency(
                          payroll.total_net,
                          payroll.currency
                        )}
                      </td>

                      <td className="whitespace-nowrap px-6 py-4 text-sm text-slate-500">
                        {formatDate(payroll.created_at)}
                      </td>

                      <td className="px-6 py-4 text-right">
                        <Link
                          href={`/payroll/${payroll.id}`}
                          className="inline-flex items-center gap-1.5 rounded-lg border border-slate-200 px-3 py-1.5 text-sm font-medium text-slate-700 hover:bg-slate-50"
                        >
                          <Eye size={16} />
                          View
                        </Link>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </AppShell>
  );
}