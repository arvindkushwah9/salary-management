"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";

import AppShell from "@/components/layout/AppShell";
import EmployeeForm from "@/components/employees/EmployeeForm";
import { isAuthenticated } from "@/lib/auth";

export default function NewEmployeePage() {
  const router = useRouter();

  useEffect(() => {
    if (!isAuthenticated()) {
      router.replace("/login");
    }
  }, [router]);

  if (!isAuthenticated()) {
    return null;
  }

  return (
    <AppShell>
      <EmployeeForm />
    </AppShell>
  );
}