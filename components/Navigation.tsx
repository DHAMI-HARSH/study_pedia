"use client"

import { motion } from "framer-motion"
import Link from "next/link"

export default function Navigation() {
  return (
    <motion.nav
      className="fixed top-0 left-0 right-0 z-50 bg-background/80 backdrop-blur-md border-b border-border"
      initial={{ opacity: 0, y: -20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
    >
      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
        <div className="flex justify-between items-center">
          <motion.div
            className="text-2xl font-bold bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent"
            whileHover={{ scale: 1.05 }}
          >
            Refer Earn
          </motion.div>
          <div className="flex gap-6">
            <Link href="#features" className="text-muted-foreground hover:text-primary transition">
              Features
            </Link>
            <Link href="#stats" className="text-muted-foreground hover:text-primary transition">
              Stats
            </Link>
            <motion.button
              className="bg-primary text-primary-foreground px-6 py-2 rounded-full font-semibold"
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              Get Started
            </motion.button>
          </div>
        </div>
      </div>
    </motion.nav>
  )
}
