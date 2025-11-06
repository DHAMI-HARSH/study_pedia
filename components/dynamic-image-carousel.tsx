"use client"

import { motion, AnimatePresence } from "framer-motion"
import { useState, useEffect } from "react"

const CAROUSEL_IMAGES = [
  {
    id: 1,
    color: "from-primary to-accent",
    title: "Earn",
    emoji: "💰",
  },
  {
    id: 2,
    color: "from-accent to-primary",
    title: "Share",
    emoji: "🎁",
  },
  {
    id: 3,
    color: "from-secondary via-primary to-accent",
    title: "Grow",
    emoji: "📈",
  },
  {
    id: 4,
    color: "from-primary via-accent to-secondary",
    title: "Celebrate",
    emoji: "🎉",
  },
]

export default function DynamicImageCarousel() {
  const [currentIndex, setCurrentIndex] = useState(0)
  const [direction, setDirection] = useState(0)

  useEffect(() => {
    const interval = setInterval(() => {
      setDirection(1)
      setCurrentIndex((prev) => (prev + 1) % CAROUSEL_IMAGES.length)
    }, 4000)
    return () => clearInterval(interval)
  }, [])

  const slideVariants = {
    enter: (dir: number) => ({
      x: dir > 0 ? 300 : -300,
      opacity: 0,
    }),
    center: {
      zIndex: 1,
      x: 0,
      opacity: 1,
    },
    exit: (dir: number) => ({
      zIndex: 0,
      x: dir > 0 ? -300 : 300,
      opacity: 0,
    }),
  }

  return (
    <section className="py-20 px-4 sm:px-6 lg:px-8">
      <div className="max-w-6xl mx-auto">
        <h2 className="text-4xl font-bold text-center mb-16">Why You'll Love It</h2>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-12 items-center">
          {/* Carousel */}
          <motion.div className="relative aspect-square rounded-3xl overflow-hidden shadow-2xl">
            <AnimatePresence initial={false} custom={direction} mode="wait">
              <motion.div
                key={currentIndex}
                custom={direction}
                variants={slideVariants}
                initial="enter"
                animate="center"
                exit="exit"
                transition={{
                  x: { type: "spring", stiffness: 300, damping: 30 },
                  opacity: { duration: 0.5 },
                }}
                className={`absolute inset-0 bg-gradient-to-br ${CAROUSEL_IMAGES[currentIndex].color} flex items-center justify-center`}
              >
                <motion.div className="text-center" animate={{ scale: [1, 1.1, 1] }} transition={{ duration: 0.5 }}>
                  <motion.div
                    className="text-8xl mb-4"
                    animate={{ rotate: [0, 10, -10, 0] }}
                    transition={{ duration: 0.6 }}
                  >
                    {CAROUSEL_IMAGES[currentIndex].emoji}
                  </motion.div>
                  <p className="text-4xl font-bold text-white">{CAROUSEL_IMAGES[currentIndex].title}</p>
                </motion.div>
              </motion.div>
            </AnimatePresence>

            {/* Navigation dots */}
            <div className="absolute bottom-4 left-1/2 -translate-x-1/2 z-50 flex gap-2">
              {CAROUSEL_IMAGES.map((_, index) => (
                <motion.button
                  key={index}
                  className={`w-3 h-3 rounded-full transition-colors ${
                    index === currentIndex ? "bg-white" : "bg-white/40"
                  }`}
                  whileHover={{ scale: 1.2 }}
                  onClick={() => {
                    setDirection(index > currentIndex ? 1 : -1)
                    setCurrentIndex(index)
                  }}
                />
              ))}
            </div>
          </motion.div>

          {/* Info Section */}
          <motion.div
            initial={{ opacity: 0, x: 50 }}
            whileInView={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8 }}
            className="space-y-6"
          >
            <h3 className="text-3xl font-bold">{CAROUSEL_IMAGES[currentIndex].title} Credits Effortlessly</h3>
            <p className="text-lg text-muted-foreground leading-relaxed">
              Our simple referral program lets you earn rewards without any complex steps. Share your unique link with
              friends, and watch your credits grow in real-time.
            </p>
            <ul className="space-y-4">
              {["Instant credit verification", "No monthly limits or caps", "Track earnings in real-time"].map(
                (item, i) => (
                  <motion.li key={i} className="flex items-center gap-3" whileHover={{ x: 5 }}>
                    <span className="text-primary text-xl">✓</span>
                    <span>{item}</span>
                  </motion.li>
                ),
              )}
            </ul>
          </motion.div>
        </div>
      </div>
    </section>
  )
}
