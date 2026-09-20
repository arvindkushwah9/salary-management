"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { Loader2 } from "lucide-react";

import AppShell from "@/components/layout/AppShell";
import EmployeeForm from "@/components/employees/EmployeeForm";
import { apiFetch } from "@/lib/api";
import { isAuthenticated } from "@/lib/auth";
import type {
  Employee,
  EmployeeResponse,
} from "@/lib/types";

export default function EditEmployeePage() {
  const router = useRouter();
  const params = useParams<{ id: string }>();

  const [employee, setEmployee] =
    useState<Employee | null>(null);

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!isAuthenticated()) {
      router.replace("/login");
      return;
    }

    async function loadEmployee() {
      try {
        setLoading(true);

        const response =
          await apiFetch<EmployeeResponse>(
            `/employees/${params.id}`
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

    loadEmployee();
  }, [params.id, router]);

  if (!isAuthenticated()) {
    return null;
  }

  return (
    <AppShell>
      {loading && (
        <div className="flex min-h-[400px] items-center justify-center">
          <Loader2 className="h-7 w-7 animate-spin text-blue-600" />
        </div>
      )}

      {!loading && error && (
        <div className="rounded-xl border border-red-200 bg-red-50 p-6 text-sm text-red-700">
          {error}
        </div>
      )}

      {!loading && !error && employee && (
        <EmployeeForm employee={employee} />
      )}
    </AppShell>
  );
}