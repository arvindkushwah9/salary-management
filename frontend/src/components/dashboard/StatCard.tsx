"use client";

import Link from "next/link";
import { ArrowUpRight, LucideIcon } from "lucide-react";

type StatCardProps = {
  title: string;
  value: string;
  description: string;
  icon: LucideIcon;
  href?: string;
};

export default function StatCard({
  title,
  value,
  description,
  icon: Icon,
  href,
}: StatCardProps) {
  const content = (
    <div
      className={`group rounded-xl border border-slate-200 bg-white p-5 shadow-sm transition ${
        href
          ? "cursor-pointer hover:-translate-y-0.5 hover:border-indigo-200 hover:shadow-md"
          : ""
      }`}
    >
      <div className="flex items-start justify-between">
        <div>
          <p className="text-sm font-medium text-slate-500">
            {title}
          </p>

          <p className="mt-2 text-2xl font-semibold tracking-tight text-slate-900">
            {value}
          </p>

          <p className="mt-1 text-xs text-slate-500">
            {description}
          </p>
        </div>

        <div className="rounded-lg bg-indigo-50 p-2.5 text-indigo-600">
          <Icon size={20} />
        </div>
      </div>

      {href && (
        <div className="mt-4 flex items-center gap-1 text-xs font-medium text-indigo-600 opacity-0 transition group-hover:opacity-100">
          View details
          <ArrowUpRight size={14} />
        </div>
      )}
    </div>
  );

  if (!href) {
    return content;
  }

  return (
    <Link href={href} className="block">
      {content}
    </Link>
  );
}