import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  clearOnEscape(event) {
    if (event.key === "Escape") {
      event.target.value = ""
    }
  }

  reset() {
    this.element.reset()
  }
}
