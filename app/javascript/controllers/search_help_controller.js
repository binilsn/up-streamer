import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["dialog"];

  connect() {
    // Close dialog on backdrop click
    this.dialogTarget.addEventListener("click", (event) => {
      if (event.target === this.dialogTarget) {
        this.close();
      }
    });
  }

  show() {
    this.dialogTarget.showModal();
  }

  close() {
    this.dialogTarget.close();
  }

  // Close on Escape key
  keydown(event) {
    if (event.key === "Escape") {
      this.close();
    }
  }
}
