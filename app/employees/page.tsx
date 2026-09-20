"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  ChevronLeft,
  ChevronRight,
  Mail,
  Plus,
  Search,
  Users,
} from "lucide-react";

import AppShell from "@/components/layout/AppShell";
import StatusBadge from "@/components/employees/StatusBadge";
import { apiFetch } from "@/lib/api";
import { isAuthenticated } from "@/lib/auth";
import {
  Department,
  Employee,
  EmployeeListResponse,
} from "@/lib/types";
import { formatDate } from "@/lib/formatters";
const PAGE_SIZE = 20;

export default function EmployeesPage() {
  const router = useRouter();

  const [employees, setEmployees] = useState<Employee[]>([]);
  const departments: Department[] = [];
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("");
  const [country, setCountry] = useState("");
  const [departmentId, setDepartmentId] = useState("");

  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalCount, setTotalCount] = useState(0);

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const countries = useMemo(() => {
    return [...new Set(employees.map((employee) => employee.country))].sort();
  }, [employees]);

  useEffect(() => {
    if (!isAuthenticated()) {
      router.replace("/login");
    }
  }, [router]);

  useEffect(() => {
    if (!isAuthenticated()) return;

    const timer = setTimeout(() => {
      loadEmployees();
    }, 250);

    return () => clearTimeout(timer);
  }, [page, search, status, country, departmentId]);

  async function loadEmployees() {
    try {
      setLoading(true);
      setError("");

      const params = new URLSearchParams();

      params.set("page", String(page));
      params.set("items", String(PAGE_SIZE));

      if (search.trim()) {
        params.set("search", search.trim());
      }

      if (status) {
        params.set("status", status);
      }

      if (country) {
        params.set("country", country);
      }

      if (departmentId) {
        params.set("department_id", departmentId);
      }

      const response = await apiFetch<EmployeeListResponse>(
        `/employees?${params.toString()}`
      );

      setEmployees(response.data);

      setTotalPages(response.meta?.pages || 1);
      setTotalCount(response.meta?.total || response.data.length);
    } catch (error) {
      setError(
        error instanceof Error
          ? error.message
          : "Unable to load employees"
      );
    } finally {
      setLoading(false);
    }
  }

  function handleFilterChange(
    setter: (value: string) => void,
    value: string
  ) {
    setter(value);
    setPage(1);
  }

  return (
    <AppShell>
      <div className="space-y-6">
        {/* Heading */}
        <div className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <p className="text-sm font-medium text-blue-600">
              Workforce
            </p>

            <h1 className="mt-1 text-2xl font-semibold tracking-tight text-slate-900">
              Employees
            </h1>

            <p className="mt-1 text-sm text-slate-500">
              Manage employee records and salary information.
            </p>
          </div>

          <Link
            href="/employees/new"
            className="inline-flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2.5 text-sm font-medium text-white shadow-sm hover:bg-blue-700"
          >
            <Plus className="h-4 w-4" />
            Add Employee
          </Link>
        </div>

        {/* Filters */}
        <div className="rounded-xl border border-slate-200 bg-white p-4 shadow-sm">
          <div className="grid gap-3 lg:grid-cols-[minmax(240px,1fr)_180px_180px_220px]">
            <div className="relative">
              <Search
                size={18}
                className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400"
              />

              <input
                type="search"
                value={search}
                onChange={(event) =>
                  handleFilterChange(setSearch, event.target.value)
                }
                placeholder="Search employees..."
                className="h-10 w-full rounded-lg border border-slate-200 bg-white pl-10 pr-4 text-sm outline-none transition focus:border-blue-400"
              />
            </div>

            <select
              value={status}
              onChange={(event) =>
                handleFilterChange(setStatus, event.target.value)
              }
              className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm text-slate-700 outline-none focus:border-blue-400"
            >
              <option value="">All statuses</option>
              <option value="active">Active</option>
              <option value="on_leave">On leave</option>
              <option value="terminated">Terminated</option>
            </select>

            <select
              value={country}
              onChange={(event) =>
                handleFilterChange(setCountry, event.target.value)
              }
              className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm text-slate-700 outline-none focus:border-blue-400"
            >
              <option value="">All countries</option>

              {countries.map((item) => (
                <option key={item} value={item}>
                  {item}
                </option>
              ))}
            </select>

            <select
              value={departmentId}
              onChange={(event) =>
                handleFilterChange(
                  setDepartmentId,
                  event.target.value
                )
              }
              className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm text-slate-700 outline-none focus:border-blue-400"
            >
              <option value="">All departments</option>

              {departments.map((department) => (
                <option key={department.id} value={department.id}>
                  {department.name}
                </option>
              ))}
            </select>
          </div>
        </div>

        {/* Error */}
        {error && (
          <div className="rounded-xl border border-red-200 bg-red-50 p-4 text-sm text-red-700">
            {error}
          </div>
        )}

        {/* Table */}
        <div className="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
          <div className="border-b border-slate-200 px-5 py-4">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="font-semibold text-slate-900">
                  Employee Directory
                </h2>

                <p className="mt-1 text-sm text-slate-500">
                  {totalCount.toLocaleString()} employees
                </p>
              </div>

              <Users
                size={20}
                className="text-slate-400"
              />
            </div>
          </div>

          {loading ? (
            <div className="flex min-h-[300px] items-center justify-center">
              <p className="text-sm text-slate-500">
                Loading employees...
              </p>
            </div>
          ) : employees.length === 0 ? (
            <div className="flex min-h-[300px] flex-col items-center justify-center px-6 text-center">
              <div className="flex h-12 w-12 items-center justify-center rounded-full bg-slate-100 text-slate-400">
                <Users size={22} />
              </div>

              <h3 className="mt-4 font-medium text-slate-900">
                No employees found
              </h3>

              <p className="mt-1 text-sm text-slate-500">
                Try changing your search or filters.
              </p>
            </div>
          ) : (
            <>
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="border-b border-slate-200 bg-slate-50 text-left text-xs uppercase tracking-wider text-slate-400">
                      <th className="px-5 py-3 font-medium">
                        Employee
                      </th>
                      <th className="px-5 py-3 font-medium">
                        Department
                      </th>
                      <th className="px-5 py-3 font-medium">
                        Designation
                      </th>
                      <th className="px-5 py-3 font-medium">
                        Country
                      </th>
                      <th className="px-5 py-3 font-medium">
                        Status
                      </th>
                      <th className="px-5 py-3 font-medium">
                        Joined
                      </th>
                    </tr>
                  </thead>

                  <tbody>
                    {employees.map((employee) => (
                      <tr
                        key={employee.id}
                        className="border-b border-slate-100 last:border-0 hover:bg-slate-50"
                      >
                        <td className="px-5 py-4">
                          <Link
                            href={`/employees/${employee.id}`}
                            className="group"
                          >
                            <div className="font-medium text-slate-900 group-hover:text-blue-600">
                              {employee.full_name}
                            </div>

                            <div className="mt-0.5 flex items-center gap-1 text-xs text-slate-500">
                              <span>
                                {employee.employee_code}
                              </span>

                              <span>•</span>

                              <Mail size={12} />

                              <span>{employee.email}</span>
                            </div>
                          </Link>
                        </td>

                        <td className="px-5 py-4 text-slate-600">
                          {employee.department?.name || "—"}
                        </td>

                        <td className="px-5 py-4 text-slate-600">
                          {employee.job_title}
                        </td>

                        <td className="px-5 py-4 font-medium text-slate-700">
                          {employee.country}
                        </td>

                        <td className="px-5 py-4">
                          <StatusBadge status={employee.status} />
                        </td>

                        <td className="px-5 py-4 text-slate-500">
                          {formatDate(employee.joined_date)}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>

              {/* Pagination */}
              <div className="flex items-center justify-between border-t border-slate-200 px-5 py-4">
                <p className="text-sm text-slate-500">
                  Page {page} of {totalPages}
                </p>

                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    disabled={page <= 1}
                    onClick={() =>
                      setPage((current) =>
                        Math.max(1, current - 1)
                      )
                    }
                    className="inline-flex h-9 items-center gap-1 rounded-lg border border-slate-200 px-3 text-sm font-medium text-slate-600 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-40"
                  >
                    <ChevronLeft size={16} />
                    Previous
                  </button>

                  <button
                    type="button"
                    disabled={page >= totalPages}
                    onClick={() =>
                      setPage((current) =>
                        Math.min(totalPages, current + 1)
                      )
                    }
                    className="inline-flex h-9 items-center gap-1 rounded-lg border border-slate-200 px-3 text-sm font-medium text-slate-600 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-40"
                  >
                    Next
                    <ChevronRight size={16} />
                  </button>
                </div>
              </div>
            </>
          )}
        </div>
      </div>
    </AppShell>
  );
}