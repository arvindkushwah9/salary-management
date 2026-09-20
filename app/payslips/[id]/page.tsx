"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useParams } from "next/navigation";
import {
  ArrowLeft,
  CalendarDays,
  CircleDollarSign,
  FileText,
  Loader2,
  Plus,
  Trash2,
  User,
  WalletCards,
  Download,
} from "lucide-react";

import AppShell from "@/components/layout/AppShell";
import { apiFetch } from "@/lib/api";
import {
  Payslip,
  PayslipItem,
  PayslipItemListResponse,
  PayslipResponse,
} from "@/lib/types";
import {
  formatCurrency,
  formatDate,
} from "@/lib/formatters";

import { downloadFile } from "@/lib/api";
import { useToast } from "@/components/ui/ToastProvider";
import LoadingState from "@/components/ui/LoadingState";
import ErrorState from "@/components/ui/ErrorState";

const paymentStatusStyles: Record<string, string> = {
  pending: "bg-amber-100 text-amber-700",
  paid: "bg-emerald-100 text-emerald-700",
  failed: "bg-red-100 text-red-700",
};

const itemTypeStyles: Record<string, string> = {
  earning: "bg-emerald-100 text-emerald-700",
  deduction: "bg-red-100 text-red-700",
  statutory: "bg-blue-100 text-blue-700",
};

export default function PayslipDetailsPage() {
  const params = useParams();
  const id = params.id as string;

  const [payslip, setPayslip] = useState<Payslip | null>(null);
  const [items, setItems] = useState<PayslipItem[]>([]);

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const [downloadingPdf, setDownloadingPdf] = useState(false);
  const { showToast } = useToast();

  const [showDeductionForm, setShowDeductionForm] = useState(false);
  const [savingDeduction, setSavingDeduction] = useState(false);
  const [deletingItemId, setDeletingItemId] = useState<string | null>(null);

  const [deductionForm, setDeductionForm] = useState({
    item_type: "deduction",
    code: "",
    description: "",
    amount: "",
  });
  const downloadPdf = async () => {
    if (!payslip) return;

    try {
      setDownloadingPdf(true);

      await downloadFile(
        `/payslips/${payslip.id}/export?format=pdf`,
        `payslip-${payslip.employee?.employee_code ?? payslip.id}.pdf`
      );

      showToast(
        "Payslip PDF downloaded successfully.",
        "success"
      );
    } catch (err) {
      showToast(
        err instanceof Error
          ? err.message
          : "Failed to download payslip.",
        "error"
      );
    } finally {
      setDownloadingPdf(false);
    }
  };

  const loadPayslip = async () => {
    if (!id) return;

    try {
      setLoading(true);
      setError("");

      const [payslipResponse, itemsResponse] =
        await Promise.all([
          apiFetch<PayslipResponse>(`/payslips/${id}`),
          apiFetch<PayslipItemListResponse>(
            `/payslips/${id}/payslip_items`
          ),
        ]);

      setPayslip(payslipResponse.data);
      setItems(itemsResponse.data);
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : "Failed to load payslip"
      );
    } finally {
      setLoading(false);
    }
  };


  const handleAddDeduction = async (
      event: React.FormEvent<HTMLFormElement>
    ) => {
      event.preventDefault();

      const amount = Number(deductionForm.amount);

      if (!deductionForm.code.trim()) {
        showToast("Deduction code is required.", "error");
        return;
      }

      if (!amount || amount <= 0) {
        showToast("Deduction amount must be greater than 0.", "error");
        return;
      }

      try {
        setSavingDeduction(true);

        await apiFetch(`/payslips/${id}/payslip_items`, {
          method: "POST",
          body: JSON.stringify({
            payslip_item: {
              item_type: deductionForm.item_type,
              code: deductionForm.code.trim(),
              description: deductionForm.description.trim() || null,
              amount,
            },
          }),
        });

        setDeductionForm({
          item_type: "deduction",
          code: "",
          description: "",
          amount: "",
        });

        setShowDeductionForm(false);

        await loadPayslip();

        showToast(
          "Deduction added successfully.",
          "success"
        );
      } catch (err) {
        showToast(
          err instanceof Error
            ? err.message
            : "Failed to add deduction.",
          "error"
        );
      } finally {
        setSavingDeduction(false);
      }
    };


    const handleDeleteItem = async (item: PayslipItem) => {
      const confirmed = window.confirm(
        `Remove ${item.code} from this payslip?`
      );

      if (!confirmed) return;

      try {
        setDeletingItemId(item.id);

        await apiFetch(
          `/payslips/${id}/payslip_items/${item.id}`,
          {
            method: "DELETE",
          }
        );

        await loadPayslip();

        showToast(
          "Payslip item removed successfully.",
          "success"
        );
      } catch (err) {
        showToast(
          err instanceof Error
            ? err.message
            : "Failed to remove payslip item.",
          "error"
        );
      } finally {
        setDeletingItemId(null);
      }
    };

  useEffect(() => {
    if (!id) return;

    loadPayslip();
  }, [id]);



  if (loading) {
    return (
      <AppShell>
        <LoadingState message="Loading payslip..." />
      </AppShell>
    );
  }

  if (error || !payslip) {
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

          <ErrorState
              message={error || "Payslip not found."}
              onRetry={loadPayslip}
            />
        </div>
      </AppShell>
    );
  }

  const currency = payslip.currency || "USD";

  const statusLabel = payslip.payment_status
    .replace("_", " ")
    .replace(/\b\w/g, (char) => char.toUpperCase());

  const earnings = items.filter(
    (item) => item.item_type === "earning"
  );

  const deductions = items.filter(
    (item) =>
      item.item_type === "deduction" ||
      item.item_type === "statutory"
  );

  return (
    <AppShell>
      <div className="space-y-6">
        {/* Header */}
        <div>
          <Link
            href={`/payroll/${payslip.payroll_run_id}`}
            className="mb-4 inline-flex items-center gap-2 text-sm font-medium text-slate-500 hover:text-slate-900"
          >
            <ArrowLeft size={16} />
            Back to Payroll Run
          </Link>

          <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
            <div className="flex items-center gap-3">
              <div className="rounded-lg bg-indigo-100 p-2 text-indigo-600">
                <FileText size={22} />
              </div>

              <div>
                <h1 className="text-2xl font-semibold text-slate-900">
                  Payslip
                </h1>

                <p className="mt-1 text-sm text-slate-500">
                  Employee salary statement for this payroll period.
                </p>
              </div>
            </div>

            <span
              className={`inline-flex w-fit rounded-full px-3 py-1.5 text-sm font-medium ${
                paymentStatusStyles[payslip.payment_status] ??
                "bg-slate-100 text-slate-700"
              }`}
            >
              {statusLabel}
            </span>

              <div className="flex flex-wrap items-center gap-3">
                <span
                  className={`inline-flex rounded-full px-3 py-1.5 text-sm font-medium ${
                    paymentStatusStyles[payslip.payment_status] ??
                    "bg-slate-100 text-slate-700"
                  }`}
                >
                  {statusLabel}
                </span>

                <button
                  type="button"
                  onClick={downloadPdf}
                  disabled={downloadingPdf}
                  className="inline-flex items-center gap-2 rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50 disabled:opacity-50"
                >
                  {downloadingPdf ? (
                    <Loader2 size={16} className="animate-spin" />
                  ) : (
                    <Download size={16} />
                  )}
                  Download PDF
                </button>
              </div>
          </div>
        </div>

        {/* Employee */}
        <div className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex items-start gap-4">
            <div className="rounded-full bg-slate-100 p-3 text-slate-600">
              <User size={24} />
            </div>

            <div>
              <h2 className="text-lg font-semibold text-slate-900">
                {payslip.employee?.full_name ??
                  payslip.employee_id}
              </h2>

              <div className="mt-1 flex flex-wrap gap-x-4 gap-y-1 text-sm text-slate-500">
                <span>
                  {payslip.employee?.employee_code ?? "—"}
                </span>

                {payslip.employee?.email && (
                  <span>{payslip.employee.email}</span>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Summary cards */}
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
          <SummaryCard
            label="Gross Earnings"
            value={formatCurrency(payslip.gross_earnings, currency)}
            icon={<WalletCards size={20} />}
          />

          <SummaryCard
            label="Deductions"
            value={formatCurrency(payslip.total_deductions,currency)}
            icon={<CircleDollarSign size={20} />}
          />

          <SummaryCard
            label="Net Pay"
            value={formatCurrency(payslip.net_pay,currency)}
            icon={<CircleDollarSign size={20} />}
          />

          <SummaryCard
            label="Paid Days"
            value={`${payslip.paid_days} / ${payslip.working_days}`}
            icon={<CalendarDays size={20} />}
          />
        </div>

        {/* Payroll information */}
        <div className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
          <h2 className="text-lg font-semibold text-slate-900">
            Payroll Information
          </h2>

          <div className="mt-5 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            <InfoItem
              label="Payroll Run"
              value={payslip.payroll_run_id}
            />

            <InfoItem
              label="Working Days"
              value={payslip.working_days.toString()}
            />

            <InfoItem
              label="Paid Days"
              value={payslip.paid_days.toString()}
            />

            <InfoItem
              label="Created"
              value={formatDate(payslip.created_at)}
            />
          </div>
        </div>

        {/* Earnings */}
        <ItemSection
          title="Earnings"
          items={earnings}
          currency={currency}
          emptyMessage="No earning items."
        />

        {/* Deductions */}
        <DeductionSection
            items={deductions}
            currency={currency}
            showForm={showDeductionForm}
            onToggleForm={() =>
              setShowDeductionForm((current) => !current)
            }
            form={deductionForm}
            setForm={setDeductionForm}
            onSubmit={handleAddDeduction}
            saving={savingDeduction}
            deletingItemId={deletingItemId}
            onDelete={handleDeleteItem}
          />

        {/* Net pay */}
        <div className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <p className="text-sm font-medium text-slate-500">
                Net Pay
              </p>

              <p className="mt-1 text-sm text-slate-500">
                Final amount payable to the employee.
              </p>
            </div>

            <p className="text-2xl font-bold text-slate-900">
              {formatCurrency(payslip.net_pay, currency)}
            </p>
          </div>
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

      <p className="mt-1 break-all text-sm font-medium text-slate-900">
        {value}
      </p>
    </div>
  );
}

function ItemSection({
  title,
  items,
  currency,
  emptyMessage,
}: {
  title: string;
  items: PayslipItem[];
  currency: string;
  emptyMessage: string;
}) {
  return (
    <div className="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
      <div className="border-b border-slate-200 px-6 py-4">
        <h2 className="text-lg font-semibold text-slate-900">
          {title}
        </h2>
      </div>

      {items.length === 0 ? (
        <div className="px-6 py-8 text-sm text-slate-500">
          {emptyMessage}
        </div>
      ) : (
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-slate-200">
            <thead className="bg-slate-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-slate-500">
                  Code
                </th>

                <th className="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-slate-500">
                  Description
                </th>

                <th className="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-slate-500">
                  Type
                </th>

                <th className="px-6 py-3 text-right text-xs font-semibold uppercase tracking-wide text-slate-500">
                  Amount
                </th>
              </tr>
            </thead>

            <tbody className="divide-y divide-slate-100">
              {items.map((item) => (
                <tr key={item.id}>
                  <td className="px-6 py-4 text-sm font-medium text-slate-900">
                    {item.code}
                  </td>

                  <td className="px-6 py-4 text-sm text-slate-600">
                    {item.description || "—"}
                  </td>

                  <td className="px-6 py-4">
                    <span
                      className={`inline-flex rounded-full px-2.5 py-1 text-xs font-medium ${
                        itemTypeStyles[item.item_type] ??
                        "bg-slate-100 text-slate-700"
                      }`}
                    >
                      {item.item_type
                        .replace("_", " ")
                        .replace(/\b\w/g, (char) =>
                          char.toUpperCase()
                        )}
                    </span>
                  </td>

                  <td className="whitespace-nowrap px-6 py-4 text-right text-sm font-medium text-slate-900">
                    {formatCurrency(item.amount, currency)}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function DeductionSection({
  items,
  currency,
  showForm,
  onToggleForm,
  form,
  setForm,
  onSubmit,
  saving,
  deletingItemId,
  onDelete,
}: {
  items: PayslipItem[];
  currency: string;
  showForm: boolean;
  onToggleForm: () => void;
  form: {
    item_type: string;
    code: string;
    description: string;
    amount: string;
  };
  setForm: React.Dispatch<
    React.SetStateAction<{
      item_type: string;
      code: string;
      description: string;
      amount: string;
    }>
  >;
  onSubmit: (event: React.FormEvent<HTMLFormElement>) => void;
  saving: boolean;
  deletingItemId: string | null;
  onDelete: (item: PayslipItem) => void;
}) {
  return (
    <div className="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
      <div className="flex flex-col gap-3 border-b border-slate-200 px-6 py-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h2 className="text-lg font-semibold text-slate-900">
            Deductions & Statutory
          </h2>

          <p className="mt-1 text-sm text-slate-500">
            Payroll deductions and statutory items.
          </p>
        </div>

        <button
          type="button"
          onClick={onToggleForm}
          className="inline-flex items-center justify-center gap-2 rounded-lg bg-indigo-600 px-3.5 py-2 text-sm font-medium text-white transition hover:bg-indigo-700"
        >
          <Plus size={16} />

          {showForm
            ? "Cancel"
            : "Add Deduction"}
        </button>
      </div>

      {showForm && (
        <form
          onSubmit={onSubmit}
          className="border-b border-slate-200 bg-slate-50 p-6"
        >
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
            <div>
              <label className="mb-1.5 block text-sm font-medium text-slate-700">
                Type
              </label>

              <select
                value={form.item_type}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    item_type: event.target.value,
                  }))
                }
                className="h-10 w-full rounded-lg border border-slate-200 bg-white px-3 text-sm outline-none focus:border-indigo-400 focus:ring-2 focus:ring-indigo-100"
              >
                <option value="deduction">
                  Deduction
                </option>

                <option value="statutory">
                  Statutory
                </option>
              </select>
            </div>

            <div>
              <label className="mb-1.5 block text-sm font-medium text-slate-700">
                Code
              </label>

              <input
                type="text"
                value={form.code}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    code: event.target.value,
                  }))
                }
                placeholder="e.g. TAX"
                maxLength={30}
                className="h-10 w-full rounded-lg border border-slate-200 bg-white px-3 text-sm outline-none focus:border-indigo-400 focus:ring-2 focus:ring-indigo-100"
              />
            </div>

            <div>
              <label className="mb-1.5 block text-sm font-medium text-slate-700">
                Description
              </label>

              <input
                type="text"
                value={form.description}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    description: event.target.value,
                  }))
                }
                placeholder="e.g. Income tax"
                maxLength={100}
                className="h-10 w-full rounded-lg border border-slate-200 bg-white px-3 text-sm outline-none focus:border-indigo-400 focus:ring-2 focus:ring-indigo-100"
              />
            </div>

            <div>
              <label className="mb-1.5 block text-sm font-medium text-slate-700">
                Amount
              </label>

              <input
                type="number"
                min="0.01"
                step="0.01"
                value={form.amount}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    amount: event.target.value,
                  }))
                }
                placeholder="0.00"
                className="h-10 w-full rounded-lg border border-slate-200 bg-white px-3 text-sm outline-none focus:border-indigo-400 focus:ring-2 focus:ring-indigo-100"
              />
            </div>
          </div>

          <div className="mt-4 flex justify-end">
            <button
              type="submit"
              disabled={saving}
              className="inline-flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2.5 text-sm font-medium text-white transition hover:bg-indigo-700 disabled:cursor-not-allowed disabled:opacity-50"
            >
              {saving && (
                <Loader2
                  size={16}
                  className="animate-spin"
                />
              )}

              {saving
                ? "Adding..."
                : "Add Deduction"}
            </button>
          </div>
        </form>
      )}

      {items.length === 0 ? (
        <div className="flex min-h-[160px] flex-col items-center justify-center px-6 text-center">
          <div className="rounded-full bg-slate-100 p-3 text-slate-400">
            <CircleDollarSign size={22} />
          </div>

          <p className="mt-3 text-sm font-medium text-slate-700">
            No deductions
          </p>

          <p className="mt-1 text-sm text-slate-500">
            Add a deduction or statutory item to this payslip.
          </p>
        </div>
      ) : (
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-slate-200">
            <thead className="bg-slate-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-slate-500">
                  Code
                </th>

                <th className="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-slate-500">
                  Description
                </th>

                <th className="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-slate-500">
                  Type
                </th>

                <th className="px-6 py-3 text-right text-xs font-semibold uppercase tracking-wide text-slate-500">
                  Amount
                </th>

                <th className="px-6 py-3 text-right text-xs font-semibold uppercase tracking-wide text-slate-500">
                  Actions
                </th>
              </tr>
            </thead>

            <tbody className="divide-y divide-slate-100">
              {items.map((item) => (
                <tr key={item.id}>
                  <td className="px-6 py-4 text-sm font-medium text-slate-900">
                    {item.code}
                  </td>

                  <td className="px-6 py-4 text-sm text-slate-600">
                    {item.description || "—"}
                  </td>

                  <td className="px-6 py-4">
                    <span
                      className={`inline-flex rounded-full px-2.5 py-1 text-xs font-medium ${
                        itemTypeStyles[item.item_type] ??
                        "bg-slate-100 text-slate-700"
                      }`}
                    >
                      {item.item_type
                        .replace("_", " ")
                        .replace(/\b\w/g, (char) =>
                          char.toUpperCase()
                        )}
                    </span>
                  </td>

                  <td className="whitespace-nowrap px-6 py-4 text-right text-sm font-medium text-slate-900">
                    {formatCurrency(
                      item.amount,
                      currency
                    )}
                  </td>

                  <td className="px-6 py-4 text-right">
                    <button
                      type="button"
                      onClick={() =>
                        onDelete(item)
                      }
                      disabled={
                        deletingItemId === item.id
                      }
                      className="inline-flex items-center gap-1.5 rounded-lg border border-red-200 px-3 py-1.5 text-sm font-medium text-red-600 transition hover:bg-red-50 disabled:cursor-not-allowed disabled:opacity-50"
                    >
                      {deletingItemId === item.id ? (
                        <Loader2
                          size={15}
                          className="animate-spin"
                        />
                      ) : (
                        <Trash2 size={15} />
                      )}

                      Delete
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}