import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "slug"]

  connect() {
    this.userEdited = this.slugTarget.value.length > 0 &&
      this.slugTarget.value !== this.slugify(this.sourceTarget.value)
  }

  update() {
    if (this.userEdited) return
    this.slugTarget.value = this.slugify(this.sourceTarget.value)
  }

  markEdited() {
    this.userEdited = true
  }

  slugify(value) {
    return value
      .toString()
      .toLowerCase()
      .trim()
      .replace(/[^a-z0-9\s-]/g, "")
      .replace(/\s+/g, "-")
      .replace(/-+/g, "-")
      .replace(/^-|-$/g, "")
  }
}
