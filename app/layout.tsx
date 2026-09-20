import type { Metadata } from "next";
import "./globals.css";

import { ToastProvider } from "@/components/ui/ToastProvider";

export const metadata: Metadata = {
  title: "SalaryHub",
  description: "HR Salary Management System",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        <ToastProvider>
          {children}
        </ToastProvider>
      </body>
    </html>
  );
}