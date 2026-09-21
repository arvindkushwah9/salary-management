"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { Loader2 } from "lucide-react";

import AppShell from "@/components/layout/AppShell";
import SalaryForm from "@/components/salary/SalaryForm";
import { apiFetch } from "@/lib/api";
import { isAuthenticated } from "@/lib/auth";
import type {
  Employee,
  EmployeeResponse,
  SalaryStructure,
  SalaryStructureResponse,
} from "@/lib/types";

export default function EditSalaryPage() {
  const router = useRouter();

  const params = useParams<{
    id: string;
    salaryId: string;
  }>();

  const [employee, setEmployee] =
    useState<Employee | null>(null);

  const [salary, setSalary] =
    useState<SalaryStructure | null>(null);

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!isAuthenticated()) {
      router.replace("/login");
      return;
    }

    async function loadData() {
      try {
        const [
          employeeResponse,
          salaryResponse,
        ] = await Promise.all([
          apiFetch<EmployeeResponse>(
            `/employees/${params.id}`
          ),

          apiFetch<SalaryStructureResponse>(
            `/employees/${params.id}/salary_structures/${params.salaryId}`
          ),
        ]);

        setEmployee(employeeResponse.data);
        setSalary(salaryResponse.data);
      } catch (error) {
        setError(
          error instanceof Error
            ? error.message
            : "Unable to load salary structure"
        );
      } finally {
        setLoading(false);
      }
    }

    loadData();
  }, [params.id, params.salaryId, router]);

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

      {!loading && !error && employee && salary && (
        <SalaryForm
          employee={employee}
          salary={salary}
        />
      )}
    </AppShell>
  );
}