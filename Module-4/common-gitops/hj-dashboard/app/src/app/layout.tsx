import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "CI/CD 체험하기",
  description: "Dashboard for blue-green deployment",
  icons: {
      // icon: "/gear.svg"
      icon: "jenkins.webp"
    },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${inter.className} w-screen h-screen`}>{children}</body>
    </html>
  );
}
