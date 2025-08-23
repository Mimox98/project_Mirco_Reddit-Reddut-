import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tabTextBtn", "tabImageBtn", "textPanel", "imagePanel", "titleCount"]

  connect() {
    // default to Text tab
    this.showText()
    // simple title char count (optional)
    const title = document.getElementById("post_title")
    if (title && this.hasTitleCountTarget) {
      this.titleCountTarget.textContent = title.value.length
      title.addEventListener("input", () => {
        this.titleCountTarget.textContent = title.value.length
      })
    }
  }

  showText()  { this.#activate("text") }
  showImage() { this.#activate("image") }

  #activate(which) {
    const isText = which === "text"

    this.textPanelTarget.classList.toggle("hidden", !isText)
    this.imagePanelTarget.classList.toggle("hidden", isText)

    // tab button styles
    this.tabTextBtnTarget.classList.toggle("border-blue-600", isText)
    this.tabTextBtnTarget.classList.toggle("text-blue-700",  isText)
    this.tabTextBtnTarget.classList.toggle("border-transparent", !isText)
    this.tabTextBtnTarget.classList.toggle("text-gray-600", !isText)

    this.tabImageBtnTarget.classList.toggle("border-blue-600", !isText)
    this.tabImageBtnTarget.classList.toggle("text-blue-700",  !isText)
    this.tabImageBtnTarget.classList.toggle("border-transparent", isText)
    this.tabImageBtnTarget.classList.toggle("text-gray-600", isText)
  }
}
