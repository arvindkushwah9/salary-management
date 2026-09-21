"use client";

import { useEffect, useMemo, useState } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import {
  ArrowLeft,
  Calculator,
  Loader2,
  Save,
  Wallet,
} from "lucide-react";
import { useRouter } from "next/navigation";

import { apiFetch } from "@/lib/api";
import { formatCurrency } from "@/lib/formatters";
import type {
  Employee,
  SalaryStructure,
  SalaryStructureResponse,
} from "@/lib/types";

const salarySchema = z
  .object({
    base_salary: z
      .string()
      .min(1, "Base salary is required")
      .refine(
        (value) => Number.isFinite(Number(value)),
        "Enter a valid amount"
      )
      .refine(
        (value) => Number(value) >= 0,
        "Amount cannot be negative"
      ),

    housing_allowance: z
      .string()
      .min(1, "Housing allowance is required")
      .refine(
        (value) => Number.isFinite(Number(value)),
        "Enter a valid amount"
      )
      .refine(
        (value) => Number(value) >= 0,
        "Amount cannot be negative"
      ),

    conveyance_allowance: z
      .string()
      .min(1, "Conveyance allowance is required")
      .refine(
        (value) => Number.isFinite(Number(value)),
        "Enter a valid amount"
      )
      .refine(
        (value) => Number(value) >= 0,
        "Amount cannot be negative"
      ),

    special_allowance: z
      .string()
      .min(1, "Special allowance is required")
      .refine(
        (value) => Number.isFinite(Number(value)),
        "Enter a valid amount"
      )
      .refine(
        (value) => Number(value) >= 0,
        "Amount cannot be negative"
      ),

    currency: z
      .string()
      .length(3, "Select a currency"),

    effective_from: z
      .string()
      .min(1, "Effective from date is required"),

    effective_to: z.string().optional(),
  })
  .refine(
    (values) => {
      if (!values.effective_to) return true;

      return (
        values.effective_to >= values.effective_from
      );
    },
    {
      message:
        "Effective to must be on or after effective from",
      path: ["effective_to"],
    }
  );

type SalaryFormValues = z.infer<typeof salarySchema>;

type SalaryFormProps = {
  employee: Employee;
  salary?: SalaryStructure | null;
};

const CURRENCIES = [
  { code: "USD", name: "US Dollar" },
  { code: "GBP", name: "British Pound" },
  { code: "INR", name: "Indian Rupee" },
  { code: "EUR", name: "Euro" },
  { code: "CAD", name: "Canadian Dollar" },
  { code: "AUD", name: "Australian Dollar" },
  { code: "SGD", name: "Singapore Dollar" },
];

function dateForInput(
  value?: string | null
): string {
  if (!value) return "";
  return value.substring(0, 10);
}

export default function SalaryForm({
  employee,
  salary,
}: SalaryFormProps) {
  const router = useRouter();

  const isEditing = Boolean(salary);

  const [submitError, setSubmitError] = useState("");

  const {
    register,
    handleSubmit,
    watch,
    formState: { errors, isSubmitting },
  } = useForm<SalaryFormValues>({
    resolver: zodResolver(salarySchema),
    defaultValues: {
      base_salary:
        salary?.base_salary?.toString() || "",

      housing_allowance:
        salary?.housing_allowance?.toString() || "0",

      conveyance_allowance:
        salary?.conveyance_allowance?.toString() || "0",

      special_allowance:
        salary?.special_allowance?.toString() || "0",

      currency: salary?.currency || "USD",

      effective_from:
        dateForInput(salary?.effective_from) ||
        new Date().toISOString().substring(0, 10),

      effective_to:
        dateForInput(salary?.effective_to),
    },
  });

  const values = watch();

  const grossSalary = useMemo(() => {
    return (
      Number(values.base_salary || 0) +
      Number(values.housing_allowance || 0) +
      Number(values.conveyance_allowance || 0) +
      Number(values.special_allowance || 0)
    );
  }, [
    values.base_salary,
    values.housing_allowance,
    values.conveyance_allowance,
    values.special_allowance,
  ]);

  const onSubmit = async (
    values: SalaryFormValues
  ) => {
    setSubmitError("");

    try {
      const payload = {
        salary_structure: {
          base_salary: Number(values.base_salary),
          housing_allowance: Number(
            values.housing_allowance
          ),
          conveyance_allowance: Number(
            values.conveyance_allowance
          ),
          special_allowance: Number(
            values.special_allowance
          ),
          currency: values.currency,
          effective_from: values.effective_from,
          effective_to:
            values.effective_to || null,
        },
      };

      let response: SalaryStructureResponse;

      if (salary) {
        response =
          await apiFetch<SalaryStructureResponse>(
            `/employees/${employee.id}/salary_structures/${salary.id}`,
            {
              method: "PATCH",
              body: JSON.stringify(payload),
            }
          );
      } else {
        response =
          await apiFetch<SalaryStructureResponse>(
            `/employees/${employee.id}/salary_structures`,
            {
              method: "POST",
              body: JSON.stringify(payload),
            }
          );
      }

      router.push(`/employees/${employee.id}`);
    } catch (error) {
      setSubmitError(
        error instanceof Error
          ? error.message
          : "Unable to save salary structure"
      );
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div className="mb-6">
        <button
          type="button"
          onClick={() =>
            router.push(`/employees/${employee.id}`)
          }
          className="mb-3 inline-flex items-center gap-2 text-sm font-medium text-slate-500 hover:text-slate-900"
        >
          <ArrowLeft className="h-4 w-4" />
          Back to employee
        </button>

        <div className="flex items-center gap-4">
          <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-blue-50 text-blue-600">
            <Wallet className="h-6 w-6" />
          </div>

          <div>
            <h1 className="text-2xl font-semibold text-slate-900">
              {isEditing
                ? "Edit Salary Structure"
                : "Add Salary Structure"}
            </h1>

            <p className="mt-1 text-sm text-slate-500">
              {employee.full_name} ·{" "}
              {employee.employee_code}
            </p>
          </div>
        </div>
      </div>

      {submitError && (
        <div className="mb-6 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {submitError}
        </div>
      )}

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        {/* Salary fields */}

        <div className="lg:col-span-2">
          <div className="rounded-xl border border-slate-200 bg-white shadow-sm">
            <div className="border-b border-slate-200 px-6 py-5">
              <h2 className="text-lg font-semibold text-slate-900">
                Compensation
              </h2>

              <p className="mt-1 text-sm text-slate-500">
                Define the employee's salary and allowances.
              </p>
            </div>

            <div className="grid grid-cols-1 gap-6 p-6 md:grid-cols-2">
              <FormField
                label="Base Salary"
                required
                error={errors.base_salary?.message}
              >
                <input
                  type="number"
                  step="0.01"
                  min="0"
                  {...register("base_salary")}
                  className={inputClass(
                    Boolean(errors.base_salary)
                  )}
                  placeholder="100000.00"
                />
              </FormField>

              <FormField
                label="Currency"
                required
                error={errors.currency?.message}
              >
                <select
                  {...register("currency")}
                  className={inputClass(
                    Boolean(errors.currency)
                  )}
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
              </FormField>

              <FormField
                label="Housing Allowance"
                required
                error={
                  errors.housing_allowance?.message
                }
              >
                <input
                  type="number"
                  step="0.01"
                  min="0"
                  {...register("housing_allowance")}
                  className={inputClass(
                    Boolean(
                      errors.housing_allowance
                    )
                  )}
                  placeholder="10000.00"
                />
              </FormField>

              <FormField
                label="Conveyance Allowance"
                required
                error={
                  errors.conveyance_allowance?.message
                }
              >
                <input
                  type="number"
                  step="0.01"
                  min="0"
                  {...register("conveyance_allowance")}
                  className={inputClass(
                    Boolean(
                      errors.conveyance_allowance
                    )
                  )}
                  placeholder="5000.00"
                />
              </FormField>

              <FormField
                label="Special Allowance"
                required
                error={
                  errors.special_allowance?.message
                }
              >
                <input
                  type="number"
                  step="0.01"
                  min="0"
                  {...register("special_allowance")}
                  className={inputClass(
                    Boolean(
                      errors.special_allowance
                    )
                  )}
                  placeholder="5000.00"
                />
              </FormField>
            </div>
          </div>

          {/* Effective period */}

          <div className="mt-6 rounded-xl border border-slate-200 bg-white shadow-sm">
            <div className="border-b border-slate-200 px-6 py-5">
              <h2 className="text-lg font-semibold text-slate-900">
                Effective Period
              </h2>

              <p className="mt-1 text-sm text-slate-500">
                Define when this salary structure applies.
              </p>
            </div>

            <div className="grid grid-cols-1 gap-6 p-6 md:grid-cols-2">
              <FormField
                label="Effective From"
                required
                error={
                  errors.effective_from?.message
                }
              >
                <input
                  type="date"
                  {...register("effective_from")}
                  className={inputClass(
                    Boolean(errors.effective_from)
                  )}
                />
              </FormField>

              <FormField
                label="Effective To"
                error={errors.effective_to?.message}
              >
                <input
                  type="date"
                  {...register("effective_to")}
                  className={inputClass(
                    Boolean(errors.effective_to)
                  )}
                />

                <p className="mt-1.5 text-xs text-slate-400">
                  Leave blank for the current salary
                  structure.
                </p>
              </FormField>
            </div>
          </div>
        </div>

        {/* Summary */}

        <div>
          <div className="sticky top-24 rounded-xl border border-slate-200 bg-white shadow-sm">
            <div className="border-b border-slate-200 px-6 py-5">
              <div className="flex items-center gap-2">
                <Calculator className="h-5 w-5 text-blue-600" />

                <h2 className="font-semibold text-slate-900">
                  Salary Summary
                </h2>
              </div>
            </div>

            <div className="space-y-4 p-6">
              <SummaryRow
                label="Base Salary"
                value={formatCurrency(
                  Number(values.base_salary || 0),
                  values.currency || "USD"
                )}
              />

              <SummaryRow
                label="Housing"
                value={formatCurrency(
                  Number(
                    values.housing_allowance || 0
                  ),
                  values.currency || "USD"
                )}
              />

              <SummaryRow
                label="Conveyance"
                value={formatCurrency(
                  Number(
                    values.conveyance_allowance || 0
                  ),
                  values.currency || "USD"
                )}
              />

              <SummaryRow
                label="Special"
                value={formatCurrency(
                  Number(
                    values.special_allowance || 0
                  ),
                  values.currency || "USD"
                )}
              />

              <div className="border-t border-slate-200 pt-4">
                <div className="text-sm text-slate-500">
                  Gross Salary
                </div>

                <div className="mt-1 text-2xl font-semibold text-slate-900">
                  {formatCurrency(
                    grossSalary,
                    values.currency || "USD"
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="mt-6 flex flex-col-reverse gap-3 border-t border-slate-200 pt-6 sm:flex-row sm:justify-end">
        <button
          type="button"
          onClick={() =>
            router.push(`/employees/${employee.id}`)
          }
          className="rounded-lg border border-slate-300 px-5 py-2.5 text-sm font-medium text-slate-700 hover:bg-slate-50"
        >
          Cancel
        </button>

        <button
          type="submit"
          disabled={isSubmitting}
          className="inline-flex items-center justify-center gap-2 rounded-lg bg-blue-600 px-5 py-2.5 text-sm font-medium text-white shadow-sm hover:bg-blue-700 disabled:cursor-not-allowed disabled:opacity-60"
        >
          {isSubmitting ? (
            <>
              <Loader2 className="h-4 w-4 animate-spin" />
              Saving...
            </>
          ) : (
            <>
              <Save className="h-4 w-4" />
              {isEditing
                ? "Save Changes"
                : "Create Salary Structure"}
            </>
          )}
        </button>
      </div>
    </form>
  );
}

function FormField({
  label,
  required,
  error,
  children,
}: {
  label: string;
  required?: boolean;
  error?: string;
  children: React.ReactNode;
}) {
  return (
    <div>
      <label className="mb-2 block text-sm font-medium text-slate-700">
        {label}

        {required && (
          <span className="ml-1 text-red-500">*</span>
        )}
      </label>

      {children}

      {error && (
        <p className="mt-1.5 text-xs text-red-600">
          {error}
        </p>
      )}
    </div>
  );
}

function SummaryRow({
  label,
  value,
}: {
  label: string;
  value: string;
}) {
  return (
    <div className="flex items-center justify-between gap-4">
      <span className="text-sm text-slate-500">
        {label}
      </span>

      <span className="text-sm font-medium text-slate-900">
        {value}
      </span>
    </div>
  );
}

function inputClass(hasError: boolean) {
  return [
    "w-full rounded-lg border bg-white px-3.5 py-2.5 text-sm text-slate-900",
    "outline-none transition",
    "placeholder:text-slate-400",
    "focus:border-blue-500 focus:ring-2 focus:ring-blue-500/10",
    hasError
      ? "border-red-300"
      : "border-slate-300",
  ].join(" ");
}