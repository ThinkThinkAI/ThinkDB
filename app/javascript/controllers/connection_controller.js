import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {}

  connected(e) {
    e.preventDefault();
    e.stopImmediatePropagation();

    this.fetchData(e.params.url, e.params.id);
  }

  async fetchData(url, id) {
    try {
      const response = await fetch(url, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
        },
      });

      const data = await response.json();

      if (response.ok) {
        if (data.data_source.connected) {
          window.location.href = "/query";
        } else {
          window.location.href = "/data_sources";
        }
      } else {
        const element = document.querySelector("#error_text");
        element.textContent = "Error: " + data.message;

        const myModal = new bootstrap.Modal("#error_modal", {});
        myModal.show();
      }
    } catch (error) {
      console.error("Error fetching data:", error);
    }
  }
}
