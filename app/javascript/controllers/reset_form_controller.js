import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "button"]

  connect() {
    this.inputElement = this.hasInputTarget ? this.inputTarget : this.element.querySelector('.chat-input')
    this.buttonElement = this.hasButtonTarget ? this.buttonTarget : this.element.querySelector('.chat-submit-button')

    if (this.inputElement && this.buttonElement) {
      this.enableButton()
    }
  }

  reset() {
    this.element.reset()

    if (this.inputElement) {
      this.inputElement.style.height = 'auto'
    }

    if (this.buttonElement) {
      this.buttonElement.disabled = true
    }
  }

  enableButton(event) {
    if (this.inputElement && this.buttonElement) {
      this.buttonElement.disabled = !this.inputElement.value.trim()

      this.inputElement.style.height = 'auto'
      this.inputElement.style.height = Math.min(this.inputElement.scrollHeight, 120) + 'px'
    }
  }
}
