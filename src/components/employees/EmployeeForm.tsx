"use client";

import { useEffect, useState } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import {
  ArrowLeft,
  Loader2,
  Save,
  UserRound,
} from "lucide-react";
import { useRouter } from "next/navigation";

import { apiFetch } from "@/lib/api";
import type {
  Department,
  DepartmentListResponse,
  Employee,
  EmployeeResponse,
} from "@/lib/types";

const employeeSchema = z.object({
  employee_code: z
    .string()
    .trim()
    .min(1, "Employee code is required"),

  first_name: z
    .string()
    .trim()
    .min(1, "First name is required"),

  last_name: z
    .string()
    .trim()
    .min(1, "Last name is required"),

  email: z
    .string()
    .trim()
    .email("Enter a valid email address"),

  department_id: z
    .string()
    .min(1, "Department is required"),

  designation: z
    .string()
    .trim()
    .min(1, "Designation is required"),

  country: z
    .string()
    .min(1, "Country is required"),

  status: z.enum(["active", "terminated", "on_leave"]),

  joined_date: z
    .string()
    .min(1, "Joined date is required"),
});

type EmployeeFormValues = z.infer<typeof employeeSchema>;

type EmployeeFormProps = {
  employee?: Employee | null;
};

const COUNTRIES = [
  { code: "US", name: "United States" },
  { code: "UK", name: "United Kingdom" },
  { code: "IN", name: "India" },
  { code: "DE", name: "Germany" },
  { code: "CA", name: "Canada" },
  { code: "AU", name: "Australia" },
  { code: "SG", name: "Singapore" },
  { code: "NL", name: "Netherlands" },
];

const STATUS_OPTIONS = [
  { value: "active", label: "Active" },
  { value: "on_leave", label: "On leave" },
  { value: "terminated", label: "Terminated" },
] as const;

function formatDateForInput(value?: string | null) {
  if (!value) return "";

  return value.substring(0, 10);
}

export default function EmployeeForm({
  employee,
}: EmployeeFormProps) {
  const router = useRouter();

  const isEditing = Boolean(employee);

  const [departments, setDepartments] = useState<Department[]>([]);
  const [loadingDepartments, setLoadingDepartments] = useState(true);
  const [loadingEmployee, setLoadingEmployee] = useState(false);
  const [submitError, setSubmitError] = useState("");

  const {
      register,
      handleSubmit,
      reset,
      formState: { errors, isSubmitting },
    } = useForm<EmployeeFormValues>({
      resolver: zodResolver(employeeSchema),
      defaultValues: {
        employee_code: "",
        first_name: "",
        last_name: "",
        email: "",
        department_id: "",
        designation: "",
        country: "",
        status: "active",
        joined_date: "",
      },
    });

  useEffect(() => {
    async function loadDepartments() {
      try {
        setLoadingDepartments(true);

        const response =
          await apiFetch<DepartmentListResponse>(
            "/departments"
          );

        setDepartments(response.data);
      } catch (error) {
        setSubmitError(
          error instanceof Error
            ? error.message
            : "Unable to load departments"
        );
      } finally {
        setLoadingDepartments(false);
      }
    }

    loadDepartments();
  }, []);

  useEffect(() => {
    if (!employee || departments.length === 0) return;

    reset({
      employee_code: employee.employee_code || "",
      first_name: employee.first_name || "",
      last_name: employee.last_name || "",
      email: employee.email || "",
      department_id: employee.department?.id || "",
      designation: employee.designation || "",
      country: employee.country || "",
      status:
        employee.status === "terminated"
          ? "terminated"
          : employee.status === "on_leave"
            ? "on_leave"
            : "active",
      joined_date: formatDateForInput(employee.joined_date),
    });
  }, [employee, departments, reset]);

  const onSubmit = async (values: EmployeeFormValues) => {
    setSubmitError("");

    try {
      const payload = {
        employee: {
          employee_code: values.employee_code,
          first_name: values.first_name,
          last_name: values.last_name,
          email: values.email,
          department_id: values.department_id,
          designation: values.designation,
          country: values.country,
          status: values.status,
          joined_date: values.joined_date,
        },
      };

      let response: EmployeeResponse;

      if (employee) {
        response = await apiFetch<EmployeeResponse>(
          `/employees/${employee.id}`,
          {
            method: "PATCH",
            body: JSON.stringify(payload),
          }
        );
      } else {
        response = await apiFetch<EmployeeResponse>(
          "/employees",
          {
            method: "POST",
            body: JSON.stringify(payload),
          }
        );
      }

      router.push(`/employees/${response.data.id}`);
    } catch (error) {
      setSubmitError(
        error instanceof Error
          ? error.message
          : "Unable to save employee"
      );
    }
  };

  if (loadingEmployee) {
    return (
      <div className="flex items-center justify-center py-20">
        <Loader2 className="h-6 w-6 animate-spin text-blue-600" />
      </div>
    );
  }
  console.log("employee", employee)
  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div className="mb-6 flex items-center justify-between gap-4">
        <div>
          <button
            type="button"
            onClick={() =>
              router.push(
                employee
                  ? `/employees/${employee.id}`
                  : "/employees"
              )
            }
            className="mb-3 inline-flex items-center gap-2 text-sm font-medium text-slate-500 hover:text-slate-900"
          >
            <ArrowLeft className="h-4 w-4" />
            {employee
              ? "Back to employee"
              : "Back to employees"}
          </button>

          <div className="flex items-center gap-4">
            <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-blue-50 text-blue-600">
              <UserRound className="h-6 w-6" />
            </div>

            <div>
              <h1 className="text-2xl font-semibold text-slate-900">
                {isEditing
                  ? "Edit Employee"
                  : "Add Employee"}
              </h1>

              <p className="mt-1 text-sm text-slate-500">
                {isEditing
                  ? "Update employee information."
                  : "Create a new employee record."}
              </p>
            </div>
          </div>
        </div>
      </div>

      {submitError && (
        <div className="mb-6 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {submitError}
        </div>
      )}

      <div className="rounded-xl border border-slate-200 bg-white shadow-sm">
        <div className="border-b border-slate-200 px-6 py-5">
          <h2 className="text-lg font-semibold text-slate-900">
            Employee Information
          </h2>

          <p className="mt-1 text-sm text-slate-500">
            Personal, employment and contact information.
          </p>
        </div>

        <div className="grid grid-cols-1 gap-6 p-6 md:grid-cols-2">
          <FormField
            label="Employee Code"
            required
            error={errors.employee_code?.message}
          >
            <input
              {...register("employee_code")}
              placeholder="EMP-10001"
              className={inputClass(
                Boolean(errors.employee_code)
              )}
            />
          </FormField>

          <FormField
            label="Email"
            required
            error={errors.email?.message}
          >
            <input
              type="email"
              {...register("email")}
              placeholder="employee@example.com"
              className={inputClass(Boolean(errors.email))}
            />
          </FormField>

          <FormField
            label="First Name"
            required
            error={errors.first_name?.message}
          >
            <input
              {...register("first_name")}
              placeholder="John"
              className={inputClass(
                Boolean(errors.first_name)
              )}
            />
          </FormField>

          <FormField
            label="Last Name"
            required
            error={errors.last_name?.message}
          >
            <input
              {...register("last_name")}
              placeholder="Doe"
              className={inputClass(
                Boolean(errors.last_name)
              )}
            />
          </FormField>

          <FormField
            label="Country"
            required
            error={errors.country?.message}
          >
            <select
              {...register("country")}
              className={inputClass(Boolean(errors.country))}
            >
              <option value="">Select country</option>

              {COUNTRIES.map((country) => (
                <option
                  key={country.code}
                  value={country.code}
                >
                  {country.name} ({country.code})
                </option>
              ))}
            </select>
          </FormField>

          <FormField
            label="Department"
            required
            error={errors.department_id?.message}
          >
            <select
              {...register("department_id")}
              disabled={loadingDepartments}
              className={inputClass(
                Boolean(errors.department_id)
              )}
            >
              <option value="">
                {loadingDepartments
                  ? "Loading departments..."
                  : "Select department"}
              </option>

              {departments.map((department) => (
                <option
                  key={department.id}
                  value={department.id}
                >
                  {department.name}
                </option>
              ))}
            </select>
          </FormField>

          <FormField
            label="Designation"
            required
            error={errors.designation?.message}
          >
            <input
              {...register("designation")}
              placeholder="Software Engineer"
              className={inputClass(
                Boolean(errors.designation)
              )}
            />
          </FormField>

          <FormField
            label="Joined Date"
            required
            error={errors.joined_date?.message}
          >
            <input
              type="date"
              {...register("joined_date")}
              className={inputClass(
                Boolean(errors.joined_date)
              )}
            />
          </FormField>

          <FormField
            label="Status"
            required
            error={errors.status?.message}
          >
            <select
              {...register("status")}
              className={inputClass(Boolean(errors.status))}
            >
              {STATUS_OPTIONS.map((status) => (
                <option
                  key={status.value}
                  value={status.value}
                >
                  {status.label}
                </option>
              ))}
            </select>
          </FormField>
        </div>

        <div className="flex flex-col-reverse gap-3 border-t border-slate-200 px-6 py-5 sm:flex-row sm:justify-end">
          <button
            type="button"
            onClick={() =>
              router.push(
                employee
                  ? `/employees/${employee.id}`
                  : "/employees"
              )
            }
            className="rounded-lg border border-slate-300 px-5 py-2.5 text-sm font-medium text-slate-700 hover:bg-slate-50"
          >
            Cancel
          </button>

          <button
            type="submit"
            disabled={isSubmitting || loadingDepartments}
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
                  : "Create Employee"}
              </>
            )}
          </button>
        </div>
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