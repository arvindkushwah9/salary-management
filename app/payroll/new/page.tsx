"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { ArrowLeft, Loader2, Save } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";

import AppShell from "@/components/layout/AppShell";
import { apiFetch } from "@/lib/api";
import {
  PayrollRunResponse,
} from "@/lib/types";

const CURRENCIES = [
  { code: "USD", name: "US Dollar" },
  { code: "GBP", name: "British Pound" },
  { code: "INR", name: "Indian Rupee" },
  { code: "EUR", name: "Euro" },
  { code: "CAD", name: "Canadian Dollar" },
  { code: "AUD", name: "Australian Dollar" },
  { code: "SGD", name: "Singapore Dollar" },
  { code: "NZD", name: "New Zealand Dollar" },
] as const;

const schema = z.object({
  payroll_period: z
    .string()
    .min(1, "Payroll period is required")
    .regex(
      /^\d{4}-(0[1-9]|1[0-2])$/,
      "Select a valid payroll month"
    ),

  currency: z
    .string()
    .length(3, "Currency is required"),
});

type FormValues = z.infer<typeof schema>;

export default function NewPayrollRunPage() {
  const router = useRouter();

  const [submitError, setSubmitError] = useState("");

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: {
      payroll_period: "",
      currency: "USD",
    },
  });

  const onSubmit = async (values: FormValues) => {
    try {
      setSubmitError("");

      const response = await apiFetch<PayrollRunResponse>(
        "/payroll_runs",
        {
          method: "POST",
          body: JSON.stringify({
            payroll_run: {
              payroll_period: values.payroll_period,
              currency: values.currency,
            },
          }),
        }
      );

      router.push(`/payroll/${response.data.id}`);
    } catch (error) {
      setSubmitError(
        error instanceof Error
          ? error.message
          : "Failed to create payroll run"
      );
    }
  };

  return (
    <AppShell>
      <div className="mx-auto max-w-3xl space-y-6">
        {/* Header */}
        <div>
          <Link
            href="/payroll"
            className="mb-4 inline-flex items-center gap-2 text-sm font-medium text-slate-500 hover:text-slate-900"
          >
            <ArrowLeft size={16} />
            Back to Payroll
          </Link>

          <h1 className="text-2xl font-semibold text-slate-900">
            Create Payroll Run
          </h1>

          <p className="mt-1 text-sm text-slate-500">
            Create a payroll run for a specific month and currency.
          </p>
        </div>

        {/* Form */}
        <form
          onSubmit={handleSubmit(onSubmit)}
          className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm"
        >
          {submitError && (
            <div className="mb-6 rounded-lg border border-red-200 bg-red-50 p-4 text-sm text-red-700">
              {submitError}
            </div>
          )}

          <div className="grid gap-6 sm:grid-cols-2">
            {/* Payroll Period */}
            <div>
              <label
                htmlFor="payroll_period"
                className="mb-2 block text-sm font-medium text-slate-700"
              >
                Payroll Period
              </label>

              <input
                id="payroll_period"
                type="month"
                {...register("payroll_period")}
                className="w-full rounded-lg border border-slate-300 px-3 py-2.5 text-sm outline-none transition focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100"
              />

              {errors.payroll_period && (
                <p className="mt-1.5 text-sm text-red-600">
                  {errors.payroll_period.message}
                </p>
              )}
            </div>

            {/* Currency */}
            <div>
              <label
                htmlFor="currency"
                className="mb-2 block text-sm font-medium text-slate-700"
              >
                Currency
              </label>

              <select
                id="currency"
                {...register("currency")}
                className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2.5 text-sm outline-none transition focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100"
              >
                {CURRENCIES.map((currency) => (
                  <option
                    key={currency.code}
                    value={currency.code}
                  >
                    {currency.code} — {currency.name}
                  </option>
                ))}
              </select>

              {errors.currency && (
                <p className="mt-1.5 text-sm text-red-600">
                  {errors.currency.message}
                </p>
              )}
            </div>
          </div>

          {/* Information */}
          <div className="mt-6 rounded-lg border border-indigo-100 bg-indigo-50 p-4">
            <p className="text-sm font-medium text-indigo-900">
              Payroll currency
            </p>

            <p className="mt-1 text-sm text-indigo-700">
              This payroll run will include active employees whose
              current salary structure uses the selected currency.
            </p>
          </div>

          {/* Actions */}
          <div className="mt-8 flex items-center justify-end gap-3 border-t border-slate-100 pt-6">
            <Link
              href="/payroll"
              className="rounded-lg border border-slate-300 px-4 py-2.5 text-sm font-medium text-slate-700 hover:bg-slate-50"
            >
              Cancel
            </Link>

            <button
              type="submit"
              disabled={isSubmitting}
              className="inline-flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2.5 text-sm font-medium text-white transition hover:bg-indigo-700 disabled:cursor-not-allowed disabled:opacity-60"
            >
              {isSubmitting ? (
                <>
                  <Loader2
                    size={17}
                    className="animate-spin"
                  />
                  Creating...
                </>
              ) : (
                <>
                  <Save size={17} />
                  Create Payroll Run
                </>
              )}
            </button>
          </div>
        </form>
      </div>
    </AppShell>
  );
}