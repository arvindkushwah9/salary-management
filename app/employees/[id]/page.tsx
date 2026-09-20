"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useParams, useRouter } from "next/navigation";
import {
  ArrowLeft,
  BriefcaseBusiness,
  CalendarDays,
  Mail,
  MapPin,
  Pencil,
  UserRound,
} from "lucide-react";

import AppShell from "@/components/layout/AppShell";
import StatusBadge from "@/components/employees/StatusBadge";
import { apiFetch } from "@/lib/api";
import { isAuthenticated } from "@/lib/auth";
import { formatCurrency, formatDate } from "@/lib/formatters";
import {
  Employee,
  EmployeeResponse,
  SalaryStructure,
  SalaryStructureListResponse,
} from "@/lib/types";

export default function EmployeeDetailsPage() {
  const params = useParams();
  const router = useRouter();

  const employeeId = params.id as string;

  const [employee, setEmployee] = useState<Employee | null>(null);
  const [salaryStructures, setSalaryStructures] = useState<
    SalaryStructure[]
  >([]);

  const [loading, setLoading] = useState(true);
  const [salaryLoading, setSalaryLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!isAuthenticated()) {
      router.replace("/login");
      return;
    }

    loadEmployee();
    loadSalaryStructures();
  }, [employeeId, router]);

  async function loadEmployee() {
    try {
      setLoading(true);
      setError("");

      const response = await apiFetch<EmployeeResponse>(
        `/employees/${employeeId}`
      );

      setEmployee(response.data);
    } catch (error) {
      setError(
        error instanceof Error
          ? error.message
          : "Unable to load employee"
      );
    } finally {
      setLoading(false);
    }
  }

  async function loadSalaryStructures() {
    try {
      setSalaryLoading(true);

      const response =
        await apiFetch<SalaryStructureListResponse>(
          `/employees/${employeeId}/salary_structures`
        );

      setSalaryStructures(response.data);
    } catch {
      setSalaryStructures([]);
    } finally {
      setSalaryLoading(false);
    }
  }

  if (loading) {
    return (
      <AppShell>
        <div className="flex min-h-[400px] items-center justify-center">
          <p className="text-sm text-slate-500">
            Loading employee...
          </p>
        </div>
      </AppShell>
    );
  }

  if (error || !employee) {
    return (
      <AppShell>
        <div className="space-y-4">
          <Link
            href="/employees"
            className="inline-flex items-center gap-2 text-sm font-medium text-slate-600 hover:text-blue-600"
          >
            <ArrowLeft size={17} />
            Back to employees
          </Link>

          <div className="rounded-xl border border-red-200 bg-red-50 p-5 text-sm text-red-700">
            {error || "Employee not found"}
          </div>
        </div>
      </AppShell>
    );
  }

  const currentSalary =
    salaryStructures.find((salary) => {
      const from = new Date(salary.effective_from);
      const to = salary.effective_to
        ? new Date(salary.effective_to)
        : null;

      const today = new Date();

      return from <= today && (!to || to >= today);
    }) || salaryStructures[0];

  return (
    <AppShell>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
          <div>
            <Link
              href="/employees"
              className="mb-4 inline-flex items-center gap-2 text-sm font-medium text-slate-500 hover:text-blue-600"
            >
              <ArrowLeft size={17} />
              Back to employees
            </Link>

            <div className="flex items-center gap-4">
              <div className="flex h-14 w-14 items-center justify-center rounded-xl bg-blue-50 text-lg font-semibold text-blue-600">
                {employee.first_name.charAt(0)}
                {employee.last_name.charAt(0)}
              </div>

              <div>
                <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
                  {employee.full_name}
                </h1>

                <p className="mt-1 text-sm text-slate-500">
                  {employee.employee_code}
                </p>
              </div>
            </div>
          </div>

          <Link
            href={`/employees/${employee.id}/edit`}
            className="inline-flex items-center justify-center gap-2 rounded-lg border border-slate-200 bg-white px-4 py-2.5 text-sm font-medium text-slate-700 shadow-sm transition hover:bg-slate-50"
          >
            <Pencil size={17} />
            Edit Employee
          </Link>
        </div>

        {/* Employee information */}
        <div className="grid gap-6 lg:grid-cols-3">
          <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm lg:col-span-2">
            <div className="mb-5">
              <h2 className="font-semibold text-slate-900">
                Employee Information
              </h2>

              <p className="mt-1 text-sm text-slate-500">
                Personal and contact information.
              </p>
            </div>

            <div className="grid gap-5 sm:grid-cols-2">
              <InfoItem
                icon={Mail}
                label="Email"
                value={employee.email}
              />

              <InfoItem
                icon={MapPin}
                label="Country"
                value={employee.country}
              />

              <InfoItem
                icon={BriefcaseBusiness}
                label="Department"
                value={employee.department?.name || "—"}
              />

              <InfoItem
                icon={UserRound}
                label="Designation"
                value={employee.job_title || "—"}
              />

              <InfoItem
                icon={CalendarDays}
                label="Joined"
                value={formatDate(employee.joined_date)}
              />

              <div>
                <p className="mb-2 text-xs font-medium uppercase tracking-wider text-slate-400">
                  Status
                </p>

                <StatusBadge
                  status={
                    employee.status as
                      | "active"
                      | "terminated"
                      | "on_leave"
                  }
                />
              </div>
            </div>
          </div>

          {/* Current salary */}
          <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
            <div className="mb-5">
              <h2 className="font-semibold text-slate-900">
                Current Salary
              </h2>


              <p className="mt-1 text-sm text-slate-500">
                Active compensation structure.
              </p>
            </div>

            {salaryLoading ? (
              <p className="text-sm text-slate-500">
                Loading salary...
              </p>
            ) : currentSalary ? (
              <div>
                <Link
                  href={`/employees/${employee.id}/salary/${currentSalary.id}/edit`}
                  className="text-sm font-medium text-blue-600 hover:text-blue-700"
                >
                  Edit
                </Link>
                <p className="text-3xl font-semibold tracking-tight text-slate-900">
                  {formatCurrency(
                    currentSalary.gross_salary,
                    currentSalary.currency
                  )}
                </p>


                <p className="mt-1 text-sm text-slate-500">
                  Gross salary
                </p>

                <div className="mt-5 space-y-3 border-t border-slate-100 pt-5">
                  <SalaryLine
                    label="Base salary"
                    value={currentSalary.base_salary}
                    currency={currentSalary.currency}
                  />

                  <SalaryLine
                    label="Housing"
                    value={currentSalary.housing_allowance}
                    currency={currentSalary.currency}
                  />

                  <SalaryLine
                    label="Conveyance"
                    value={currentSalary.conveyance_allowance}
                    currency={currentSalary.currency}
                  />

                  <SalaryLine
                    label="Special"
                    value={currentSalary.special_allowance}
                    currency={currentSalary.currency}
                  />
                </div>
              </div>
            ) : (
              <div className="rounded-lg bg-slate-50 p-4 text-sm text-slate-500">
                No salary structure has been configured.
              </div>
            )}
          </div>
        </div>

        {/* Salary history */}

        <div className="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
          
          <div className="border-b border-slate-200 px-5 py-4">
          <Link
            href={`/employees/${employee.id}/salary/new`}
            className="inline-flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2.5 text-sm font-medium text-white shadow-sm hover:bg-blue-700"
          >
            Add Salary Structure
          </Link>
            <h2 className="font-semibold text-slate-900">
              Salary History
            </h2>


            <p className="mt-1 text-sm text-slate-500">
              Historical compensation structures for this employee.
            </p>
          </div>



          {salaryLoading ? (
            <div className="flex min-h-[200px] items-center justify-center">
              <p className="text-sm text-slate-500">
                Loading salary history...
              </p>
            </div>
          ) : salaryStructures.length === 0 ? (
            <div className="flex min-h-[200px] items-center justify-center">
              <p className="text-sm text-slate-500">
                No salary history available.
              </p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-slate-200 bg-slate-50 text-left text-xs uppercase tracking-wider text-slate-400">
                    <th className="px-5 py-3 font-medium">
                      Effective From
                    </th>
                    <th className="px-5 py-3 font-medium">
                      Effective To
                    </th>
                    <th className="px-5 py-3 font-medium">
                      Base Salary
                    </th>
                    <th className="px-5 py-3 font-medium">
                      Allowances
                    </th>
                    <th className="px-5 py-3 font-medium">
                      Gross Salary
                    </th>
                    <th className="px-5 py-3 font-medium">
                      Currency
                    </th>
                  </tr>
                </thead>

                <tbody>
                  {salaryStructures.map((salary) => (
                    <tr
                      key={salary.id}
                      className="border-b border-slate-100 last:border-0"
                    >
                      <td className="px-5 py-4 font-medium text-slate-800">
                        {formatDate(salary.effective_from)}
                      </td>

                      <td className="px-5 py-4 text-slate-500">
                        {formatDate(salary.effective_to)}
                      </td>

                      <td className="px-5 py-4 text-slate-600">
                        {formatCurrency(
                          salary.base_salary,
                          salary.currency
                        )}
                      </td>

                      <td className="px-5 py-4 text-slate-600">
                        {formatCurrency(
                          salary.housing_allowance +
                            salary.conveyance_allowance +
                            salary.special_allowance,
                          salary.currency
                        )}
                      </td>

                      <td className="px-5 py-4 font-semibold text-slate-900">
                        {formatCurrency(
                          salary.gross_salary,
                          salary.currency
                        )}
                      </td>

                      <td className="px-5 py-4 font-medium text-slate-700">
                        {salary.currency}
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

function InfoItem({
  icon: Icon,
  label,
  value,
}: {
  icon: typeof Mail;
  label: string;
  value: string;
}) {
  return (
    <div>
      <div className="mb-2 flex items-center gap-2 text-xs font-medium uppercase tracking-wider text-slate-400">
        <Icon size={14} />
        {label}
      </div>

      <p className="text-sm font-medium text-slate-800">
        {value}
      </p>
    </div>
  );
}

function SalaryLine({
  label,
  value,
  currency,
}: {
  label: string;
  value: number;
  currency: string;
}) {
  return (
    <div className="flex items-center justify-between gap-4">
      <span className="text-sm text-slate-500">{label}</span>

      <span className="text-sm font-medium text-slate-800">
        {formatCurrency(value, currency)}
      </span>
    </div>
  );
}