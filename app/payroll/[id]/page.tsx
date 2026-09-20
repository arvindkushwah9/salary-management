"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useParams, useRouter } from "next/navigation";
import {
  ArrowLeft,
  CheckCircle2,
  CircleDollarSign,
  Eye,
  Loader2,
  Play,
  Users,
  WalletCards,
} from "lucide-react";

import AppShell from "@/components/layout/AppShell";
import { apiFetch } from "@/lib/api";
import {
  PayrollRun,
  PayrollRunResponse,
  Payslip,
  PayslipListResponse,
} from "@/lib/types";
import {
  formatCurrency,
  formatDate,
} from "@/lib/formatters";

import {
  Download,
  FileSpreadsheet,
  FileText,
} from "lucide-react";

import { downloadFile } from "@/lib/api";

const statusStyles: Record<string, string> = {
  draft: "bg-slate-100 text-slate-700",
  processing: "bg-blue-100 text-blue-700",
  approved: "bg-emerald-100 text-emerald-700",
  disbursed: "bg-purple-100 text-purple-700",
};

const paymentStatusStyles: Record<string, string> = {
  pending: "bg-amber-100 text-amber-700",
  paid: "bg-emerald-100 text-emerald-700",
  failed: "bg-red-100 text-red-700",
};

export default function PayrollRunDetailsPage() {
  const params = useParams();
  const router = useRouter();

  const id = params.id as string;

  const [payrollRun, setPayrollRun] = useState<PayrollRun | null>(
    null
  );
  const [payslips, setPayslips] = useState<Payslip[]>([]);

  const [loading, setLoading] = useState(true);
  const [processing, setProcessing] = useState(false);
  const [approving, setApproving] = useState(false);

  const [error, setError] = useState("");
  const [actionError, setActionError] = useState("");

  const [exporting, setExporting] = useState<string | null>(null);

 const handleExport = async (
      type: "csv" | "xlsx"
    ) => {
      try {
        setExporting(type);

        const extension = type;

        await downloadFile(
          `/payroll_runs/${id}/export?format=${type}`,
          `payroll-${payrollRun?.payroll_period}.${extension}`
        );
      } catch (err) {
        setActionError(
          err instanceof Error
            ? err.message
            : "Export failed"
        );
      } finally {
        setExporting(null);
      }
    };
  const loadPayrollRun = async () => {
    try {
      setLoading(true);
      setError("");

      const [payrollResponse, payslipResponse] = await Promise.all([
        apiFetch<PayrollRunResponse>(`/payroll_runs/${id}`),
        apiFetch<PayslipListResponse>(
          `/payroll_runs/${id}/payslips`
        ),
      ]);

      setPayrollRun(payrollResponse.data);
      setPayslips(payslipResponse.data);
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : "Failed to load payroll run"
      );
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (id) {
      loadPayrollRun();
    }
  }, [id]);

  const processPayroll = async () => {
    if (!payrollRun) return;

    const confirmed = window.confirm(
      `Process payroll for ${payrollRun.payroll_period} (${payrollRun.currency})? This will create payslips for eligible active employees.`
    );

    if (!confirmed) return;

    try {
      setProcessing(true);
      setActionError("");

      const response = await apiFetch<PayrollRunResponse>(
        `/payroll_runs/${id}/process`,
        {
          method: "POST",
          body: JSON.stringify({}),
        }
      );

      setPayrollRun(response.data);

      const payslipResponse =
        await apiFetch<PayslipListResponse>(
          `/payroll_runs/${id}/payslips`
        );

      setPayslips(payslipResponse.data);
    } catch (err) {
      setActionError(
        err instanceof Error
          ? err.message
          : "Failed to process payroll"
      );
    } finally {
      setProcessing(false);
    }
  };

  const approvePayroll = async () => {
    if (!payrollRun) return;

    const confirmed = window.confirm(
      `Approve payroll for ${payrollRun.payroll_period} (${payrollRun.currency})?`
    );

    if (!confirmed) return;

    try {
      setApproving(true);
      setActionError("");

      const response = await apiFetch<PayrollRunResponse>(
        `/payroll_runs/${id}/approve`,
        {
          method: "POST",
          body: JSON.stringify({}),
        }
      );

      setPayrollRun(response.data);
    } catch (err) {
      setActionError(
        err instanceof Error
          ? err.message
          : "Failed to approve payroll"
      );
    } finally {
      setApproving(false);
    }
  };

  if (loading) {
    return (
      <AppShell>
        <div className="flex min-h-[400px] items-center justify-center">
          <div className="flex items-center gap-2 text-sm text-slate-500">
            <Loader2
              size={20}
              className="animate-spin"
            />
            Loading payroll run...
          </div>
        </div>
      </AppShell>
    );
  }

  if (error || !payrollRun) {
    return (
      <AppShell>
        <div className="space-y-4">
          <Link
            href="/payroll"
            className="inline-flex items-center gap-2 text-sm font-medium text-slate-500 hover:text-slate-900"
          >
            <ArrowLeft size={16} />
            Back to Payroll
          </Link>

          <div className="rounded-xl border border-red-200 bg-red-50 p-5 text-sm text-red-700">
            {error || "Payroll run not found."}
          </div>
        </div>
      </AppShell>
    );
  }

  const statusLabel = payrollRun.status
    .replace("_", " ")
    .replace(/\b\w/g, (char) => char.toUpperCase());

  return (
    <AppShell>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
          <div>
            <Link
              href="/payroll"
              className="mb-4 inline-flex items-center gap-2 text-sm font-medium text-slate-500 hover:text-slate-900"
            >
              <ArrowLeft size={16} />
              Back to Payroll
            </Link>

            <div className="flex items-center gap-3">
              <div className="rounded-lg bg-indigo-100 p-2 text-indigo-600">
                <WalletCards size={22} />
              </div>

              <div>
                <h1 className="text-2xl font-semibold text-slate-900">
                  Payroll {payrollRun.payroll_period}
                </h1>

                <p className="mt-1 text-sm text-slate-500">
                  Payroll run details and employee payslips.
                </p>
              </div>
            </div>
          </div>

          <div className="flex flex-wrap items-center gap-3">
            <span
              className={`inline-flex rounded-full px-3 py-1.5 text-sm font-medium ${
                statusStyles[payrollRun.status] ??
                "bg-slate-100 text-slate-700"
              }`}
            >
              {statusLabel}
            </span>

            {payrollRun.status === "draft" && (
              <button
                type="button"
                onClick={processPayroll}
                disabled={processing}
                className="inline-flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2.5 text-sm font-medium text-white hover:bg-indigo-700 disabled:cursor-not-allowed disabled:opacity-60"
              >
                {processing ? (
                  <>
                    <Loader2
                      size={17}
                      className="animate-spin"
                    />
                    Processing...
                  </>
                ) : (
                  <>
                    <Play size={17} />
                    Process Payroll
                  </>
                )}
              </button>
            )}

            {payrollRun.status === "processing" && (
              <button
                type="button"
                onClick={approvePayroll}
                disabled={approving}
                className="inline-flex items-center gap-2 rounded-lg bg-emerald-600 px-4 py-2.5 text-sm font-medium text-white hover:bg-emerald-700 disabled:cursor-not-allowed disabled:opacity-60"
              >
                {approving ? (
                  <>
                    <Loader2
                      size={17}
                      className="animate-spin"
                    />
                    Approving...
                  </>
                ) : (
                  <>
                    <CheckCircle2 size={17} />
                    Approve Payroll
                  </>
                )}
              </button>
            )}

            <div className="flex flex-wrap items-center gap-2">
              <button
                type="button"
                onClick={() => handleExport("csv")}
                disabled={!!exporting}
                className="inline-flex items-center gap-2 rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50 disabled:opacity-50"
              >
                {exporting === "csv" ? (
                  <Loader2 size={16} className="animate-spin" />
                ) : (
                  <FileText size={16} />
                )}
                CSV
              </button>

              <button
                type="button"
                onClick={() => handleExport("xlsx")}
                disabled={!!exporting}
                className="inline-flex items-center gap-2 rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50 disabled:opacity-50"
              >
                {exporting === "xlsx" ? (
                  <Loader2 size={16} className="animate-spin" />
                ) : (
                  <FileSpreadsheet size={16} />
                )}
                Excel
              </button>
            </div>
          </div>
        </div>

        {/* Action error */}
        {actionError && (
          <div className="rounded-lg border border-red-200 bg-red-50 p-4 text-sm text-red-700">
            {actionError}
          </div>
        )}

        {/* Summary */}
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
          <SummaryCard
            label="Currency"
            value={payrollRun.currency}
            icon={<CircleDollarSign size={20} />}
          />

          <SummaryCard
            label="Employees"
            value={payslips.length.toLocaleString()}
            icon={<Users size={20} />}
          />

          <SummaryCard
            label="Gross"
            value={formatCurrency(
              payrollRun.total_gross,
              payrollRun.currency
            )}
            icon={<WalletCards size={20} />}
          />

          <SummaryCard
            label="Net Pay"
            value={formatCurrency(
              payrollRun.total_net,
              payrollRun.currency
            )}
            icon={<CircleDollarSign size={20} />}
          />
        </div>

        {/* Payroll information */}
        <div className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
          <h2 className="text-lg font-semibold text-slate-900">
            Payroll Summary
          </h2>

          <div className="mt-5 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            <InfoItem
              label="Payroll Period"
              value={payrollRun.payroll_period}
            />

            <InfoItem
              label="Currency"
              value={payrollRun.currency}
            />

            <InfoItem
              label="Total Gross"
              value={formatCurrency(
                payrollRun.total_gross,
                payrollRun.currency
              )}
            />

            <InfoItem
              label="Total Deductions"
              value={formatCurrency(
                payrollRun.total_deductions,
                payrollRun.currency
              )}
            />

            <InfoItem
              label="Total Net"
              value={formatCurrency(
                payrollRun.total_net,
                payrollRun.currency
              )}
            />

            <InfoItem
              label="Created"
              value={formatDate(payrollRun.created_at)}
            />

            <InfoItem
              label="Approved"
              value={
                payrollRun.approved_at
                  ? formatDate(payrollRun.approved_at)
                  : "Not approved"
              }
            />
          </div>
        </div>

        {/* Payslips */}
        <div className="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
          <div className="border-b border-slate-200 px-6 py-4">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-lg font-semibold text-slate-900">
                  Payslips
                </h2>

                <p className="mt-1 text-sm text-slate-500">
                  {payslips.length.toLocaleString()} payslip
                  {payslips.length === 1 ? "" : "s"} generated.
                </p>
              </div>
            </div>
          </div>

          {payslips.length === 0 ? (
            <div className="px-6 py-12 text-center">
              <Users
                size={32}
                className="mx-auto text-slate-300"
              />

              <p className="mt-3 text-sm font-medium text-slate-700">
                No payslips yet
              </p>

              <p className="mt-1 text-sm text-slate-500">
                Process this payroll run to generate payslips.
              </p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-slate-200">
                <thead className="bg-slate-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-slate-500">
                      Employee
                    </th>

                    <th className="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-slate-500">
                      Working Days
                    </th>

                    <th className="px-6 py-3 text-right text-xs font-semibold uppercase tracking-wide text-slate-500">
                      Gross
                    </th>

                    <th className="px-6 py-3 text-right text-xs font-semibold uppercase tracking-wide text-slate-500">
                      Deductions
                    </th>

                    <th className="px-6 py-3 text-right text-xs font-semibold uppercase tracking-wide text-slate-500">
                      Net Pay
                    </th>

                    <th className="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-slate-500">
                      Status
                    </th>

                    <th className="px-6 py-3 text-right text-xs font-semibold uppercase tracking-wide text-slate-500">
                      Action
                    </th>
                  </tr>
                </thead>

                <tbody className="divide-y divide-slate-100">
                  {payslips.map((payslip) => (
                    <tr
                      key={payslip.id}
                      className="hover:bg-slate-50"
                    >
                      <td className="px-6 py-4">
                        <div>
                          <div className="text-sm font-medium text-slate-900">
                            {payslip.employee.full_name}
                          </div>

                          <div className="mt-0.5 text-xs text-slate-500">
                            {payslip.employee.employee_code}
                          </div>
                        </div>
                      </td>

                      <td className="px-6 py-4 text-sm text-slate-600">
                        {payslip.paid_days} /{" "}
                        {payslip.working_days}
                      </td>

                      <td className="whitespace-nowrap px-6 py-4 text-right text-sm text-slate-700">
                        {formatCurrency(
                          payslip.gross_earnings,
                          payrollRun.currency
                        )}
                      </td>

                      <td className="whitespace-nowrap px-6 py-4 text-right text-sm text-slate-700">
                        {formatCurrency(
                          payslip.total_deductions,
                          payrollRun.currency
                        )}
                      </td>

                      <td className="whitespace-nowrap px-6 py-4 text-right text-sm font-medium text-slate-900">
                        {formatCurrency(
                          payslip.net_pay,
                          payrollRun.currency
                        )}
                      </td>

                      <td className="px-6 py-4">
                        <span
                          className={`inline-flex rounded-full px-2.5 py-1 text-xs font-medium ${
                            paymentStatusStyles[
                              payslip.payment_status
                            ] ??
                            "bg-slate-100 text-slate-700"
                          }`}
                        >
                          {payslip.payment_status
                            .replace("_", " ")
                            .replace(/\b\w/g, (char) =>
                              char.toUpperCase()
                            )}
                        </span>
                      </td>

                      <td className="px-6 py-4 text-right">
                        <Link
                          href={`/payslips/${payslip.id}`}
                          className="inline-flex items-center gap-1.5 rounded-lg border border-slate-200 px-3 py-1.5 text-sm font-medium text-slate-700 hover:bg-slate-50"
                        >
                          <Eye size={16} />
                          View
                        </Link>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </AppShell>
  );
}

function SummaryCard({
  label,
  value,
  icon,
}: {
  label: string;
  value: string;
  icon: React.ReactNode;
}) {
  return (
    <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
      <div className="flex items-center justify-between">
        <p className="text-sm font-medium text-slate-500">
          {label}
        </p>

        <div className="rounded-lg bg-slate-100 p-2 text-slate-600">
          {icon}
        </div>
      </div>

      <p className="mt-4 text-2xl font-semibold text-slate-900">
        {value}
      </p>
    </div>
  );
}

function InfoItem({
  label,
  value,
}: {
  label: string;
  value: string;
}) {
  return (
    <div>
      <p className="text-xs font-medium uppercase tracking-wide text-slate-500">
        {label}
      </p>

      <p className="mt-1 text-sm font-medium text-slate-900">
        {value}
      </p>
    </div>
  );
}