"use client";

import { useEffect, useState } from "react";
import {
  CircleDollarSign,
  UserCheck,
  UserMinus,
  Users,
} from "lucide-react";

import AppShell from "@/components/layout/AppShell";
import StatCard from "@/components/dashboard/StatCard";
import CountryDistribution from "@/components/dashboard/CountryDistribution";
import SalaryByCurrency from "@/components/dashboard/SalaryByCurrency";

import { apiFetch } from "@/lib/api";
import { DashboardData } from "@/lib/types";
import { useRouter } from "next/navigation";
import { isAuthenticated } from "@/lib/auth";

type DashboardResponse = {
  data: DashboardData;
};

export default function DashboardPage() {
  const router = useRouter();

  const [dashboard, setDashboard] =
    useState<DashboardData | null>(null);

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!isAuthenticated()) {
      router.replace("/login");
      return;
    }

    async function loadDashboard() {
      try {
        const response =
          await apiFetch<DashboardResponse>("/dashboard");

        setDashboard(response.data);
      } catch (error) {
        setError(
          error instanceof Error
            ? error.message
            : "Unable to load dashboard"
        );
      } finally {
        setLoading(false);
      }
    }

    loadDashboard();
  }, [router]);

  if (loading) {
    return (
      <AppShell>
        <div className="flex min-h-[500px] items-center justify-center">
          <div className="text-sm text-slate-500">
            Loading dashboard...
          </div>
        </div>
      </AppShell>
    );
  }

  if (error) {
    return (
      <AppShell>
        <div className="rounded-xl border border-red-200 bg-red-50 p-5 text-sm text-red-700">
          {error}
        </div>
      </AppShell>
    );
  }

  if (!dashboard) {
    return null;
  }

  return (
    <AppShell>
      <div className="space-y-6">
        {/* Page heading */}

        <div>
          <p className="text-sm font-medium text-blue-600">
            HR Overview
          </p>

          <h1 className="mt-1 text-2xl font-semibold tracking-tight text-slate-900">
            Salary Management Dashboard
          </h1>

          <p className="mt-1 text-sm text-slate-500">
            Overview of your workforce and salary data.
          </p>
        </div>

        {/* KPI cards */}

        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
          <StatCard
            title="Total Employees"
            value={dashboard.employees.total.toLocaleString()}
            description={`${dashboard.countries.count} countries`}
            icon={Users}
            href="/employees"
          />

          <StatCard
            title="Active Employees"
            value={dashboard.employees.active.toLocaleString()}
            description={`${(
              (dashboard.employees.active /
                dashboard.employees.total) *
              100
            ).toFixed(1)}% of workforce`}
            icon={UserCheck}
            href="/employees?status=active"
          />

          <StatCard
            title="Inactive Employees"
            value={dashboard.employees.inactive.toLocaleString()}
            description="Currently inactive"
            icon={UserMinus}
            href="/employees?status=inactive"
          />

          <StatCard
            title="Employees With Salary"
            value={dashboard.salary.employees_with_salary.toLocaleString()}
            description={`${dashboard.salary.currencies.length} currencies`}
            icon={CircleDollarSign}
            href="/employees?has_salary=true"
          />
        </div>

        {/* Charts */}

        <div className="grid gap-6 xl:grid-cols-2">
          <CountryDistribution
            data={
              dashboard.countries
                .employee_count_by_country
            }
          />

          <SalaryByCurrency
            data={
              dashboard.salary
                .statistics_by_currency
            }
          />
        </div>
      </div>
    </AppShell>
  );
}