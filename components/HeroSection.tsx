"use client"

import { motion } from "framer-motion"

export default function HeroSection() {
  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.2,
        delayChildren: 0.3,
      },
    },
  }

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: { duration: 0.8 },
    },
  }

  return (
    <section className="min-h-screen flex items-center justify-center pt-20 px-4 sm:px-6 lg:px-8 relative overflow-hidden">
      {/* Animated background elements */}
      <motion.div
        className="absolute top-20 right-10 w-72 h-72 bg-secondary rounded-full mix-blend-multiply filter blur-3xl opacity-20"
        animate={{ y: [0, 30, 0], x: [0, 30, 0] }}
        transition={{ duration: 8, repeat: Number.POSITIVE_INFINITY }}
      />
      <motion.div
        className="absolute bottom-20 left-10 w-72 h-72 bg-primary rounded-full mix-blend-multiply filter blur-3xl opacity-20"
        animate={{ y: [0, -30, 0], x: [0, -30, 0] }}
        transition={{ duration: 8, repeat: Number.POSITIVE_INFINITY, delay: 1 }}
      />

      <motion.div
        className="text-center z-10 max-w-4xl"
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        <motion.h1 className="text-5xl sm:text-6xl lg:text-7xl font-bold mb-6 leading-tight" variants={itemVariants}>
          Share the <span className="bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent">Love</span>,{" "}
          <span className="bg-gradient-to-r from-accent to-primary bg-clip-text text-transparent">Earn Credits</span>
        </motion.h1>

        <motion.p className="text-lg sm:text-xl text-muted-foreground mb-8 leading-relaxed" variants={itemVariants}>
          Invite your friends and earn rewards instantly. No limits, no catches. Just pure referral bliss.
        </motion.p>

        <motion.div className="flex flex-col sm:flex-row gap-4 justify-center" variants={itemVariants}>
          <motion.button
            className="bg-primary text-primary-foreground px-8 py-4 rounded-full font-semibold text-lg"
            whileHover={{ scale: 1.05, boxShadow: "0 20px 40px rgba(255, 107, 157, 0.3)" }}
            whileTap={{ scale: 0.95 }}
          >
            Start Referring
          </motion.button>
          <motion.button
            className="border-2 border-primary text-primary px-8 py-4 rounded-full font-semibold text-lg hover:bg-muted"
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            Learn More
          </motion.button>
        </motion.div>
      </motion.div>
    </section>
  )
}
