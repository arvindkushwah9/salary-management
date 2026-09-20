"use client";

import { Bell, Search } from "lucide-react";
import { getUser } from "@/lib/auth";

export default function Header() {
  const user = getUser();

  return (
    <header className="fixed inset-x-0 top-0 z-30 h-16 border-b border-slate-200 bg-white lg:left-64">
      <div className="flex h-full items-center justify-between px-4 sm:px-6">
        <div className="flex items-center gap-3">
          <div className="relative hidden sm:block">
            <Search
              size={18}
              className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400"
            />

            <input
              type="search"
              placeholder="Search employees..."
              className="h-9 w-64 rounded-lg border border-slate-200 bg-slate-50 pl-10 pr-4 text-sm outline-none transition focus:border-blue-400 focus:bg-white"
            />
          </div>
        </div>

        <div className="flex items-center gap-4">
          <button className="relative rounded-lg p-2 text-slate-500 hover:bg-slate-50 hover:text-slate-700">
            <Bell size={19} />
            <span className="absolute right-1.5 top-1.5 h-1.5 w-1.5 rounded-full bg-blue-600" />
          </button>

          <div className="flex items-center gap-3 border-l border-slate-200 pl-4">
            <div className="flex h-9 w-9 items-center justify-center rounded-full bg-blue-100 text-sm font-semibold text-blue-700">
              {user?.email?.charAt(0).toUpperCase() || "H"}
            </div>

            <div className="hidden sm:block">
              <p className="text-sm font-medium text-slate-800">
                {user?.email || "HR Manager"}
              </p>

              <p className="text-xs text-slate-500">
                HR Manager
              </p>
            </div>
          </div>
        </div>
      </div>
    </header>
  );
}