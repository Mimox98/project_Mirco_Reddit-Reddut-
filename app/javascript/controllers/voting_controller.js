import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["up", "down", "score", "pill"]
  static values  = { postId: Number }

  connect() { this.applyUi() }

  voteUp()   { this.vote("up") }
  voteDown() { this.vote("down") }

  vote(direction) {
    const id = this.postIdValue
    const state = this.getState(id) // "none"|"up"|"down"
    let delta = 0, next = state

    if (direction === "up") {
      if (state === "none")      { delta = +1; next = "up"   }
      else if (state === "up")   { delta = -1; next = "none" }
      else if (state === "down") { delta = +2; next = "up"   }
    } else {
      if (state === "none")      { delta = -1; next = "down" }
      else if (state === "down") { delta = +1; next = "none" }
      else if (state === "up")   { delta = -2; next = "down" }
    }

    this.setState(id, next)
    this.applyUi()
    if (delta !== 0) this.sendDelta(id, delta)
  }

  applyUi() {
    const state = this.getState(this.postIdValue)

    // highlight individual arrows (optional)
    if (this.hasUpTarget)   this.upTarget.classList.toggle("text-orange-600", state === "up")
    if (this.hasDownTarget) this.downTarget.classList.toggle("text-purple-600", state === "down")

    // style the pill (Reddit-like)
    if (this.hasPillTarget) {
      // reset to neutral
      this.pillTarget.classList.remove(
        "bg-orange-600","bg-indigo-600","text-white","border-transparent"
      )
      this.pillTarget.classList.add("bg-gray-100","text-gray-800","border")

      if (state === "up") {
        this.pillTarget.classList.remove("bg-gray-100","text-gray-800","border")
        this.pillTarget.classList.add("bg-orange-600","text-white","border-transparent")
      } else if (state === "down") {
        this.pillTarget.classList.remove("bg-gray-100","text-gray-800","border")
        this.pillTarget.classList.add("bg-indigo-600","text-white","border-transparent")
      }
    }
  }

  async sendDelta(id, delta) {
    const token = document.querySelector('meta[name="csrf-token"]')?.content || ""
    const resp = await fetch(`/posts/${id}/nudge_score`, {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": token },
      body: JSON.stringify({ delta })
    })
    const json = await resp.json()
    if (this.hasScoreTarget) this.scoreTarget.textContent = json.score
  }

  key(id)           { return `post:${id}:vote` }
  getState(id)      { return localStorage.getItem(this.key(id)) || "none" }
  setState(id, val) { localStorage.setItem(this.key(id), val) }
}
