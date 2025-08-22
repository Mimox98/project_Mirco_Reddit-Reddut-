import { Controller } from "@hotwired/stimulus"

// data-controller="count-up"
export default class extends Controller {
  static targets = ["stat"]
  static values = {
    duration: { type: Number, default: 1200 }, // ms
    once: { type: Boolean, default: true }
  }

  connect() {
    // Observe when the section enters the viewport
    this.observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.start()
          if (this.onceValue) this.observer.disconnect()
        }
      })
    }, { threshold: 0.2 })
    this.observer.observe(this.element)
  }

  start() {
    this.statTargets.forEach(el => this.animate(el))
  }

  animate(el) {
    // Get target number from data attribute
    const target = Number(el.dataset.countup)
    const start = 0
    const startTime = performance.now()
    const dur = this.durationValue

    const step = (now) => {
      const t = Math.min((now - startTime) / dur, 1)
      const value = Math.floor(start + (target - start) * this.easeOutCubic(t))
      el.textContent = this.format(value, el.dataset.format)
      if (t < 1) requestAnimationFrame(step)
    }
    requestAnimationFrame(step)
  }

  // Nice easing
  easeOutCubic(t) { return 1 - Math.pow(1 - t, 3) }

  // Formats: "abbr-plus" -> 110M+, 22B+, etc.
  format(n, format) {
    if (format === "abbr-plus") {
      const abs = Math.abs(n)
      if (abs >= 1_000_000_000) return `${(n/1_000_000_000).toFixed(0)}B+`
      if (abs >= 1_000_000)     return `${(n/1_000_000).toFixed(0)}M+`
      if (abs >= 1_000)         return `${(n/1_000).toFixed(0)}K+`
    }
    return n.toLocaleString()
  }
}
