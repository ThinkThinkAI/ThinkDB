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
      console.log(id);

      const response = await fetch(url, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
        },
      });

      if (!response.ok) {
        throw new Error("Network response was not ok");
      }

      const data = await response.json();
      console.log(data);

      if (data.data_source.connected) {
        window.location.href = "/query";
      } else {
        const element = document.querySelector(id);

        element.className = "btn btn-primary btn-sm";
        element.textContent = "connect";
      }
    } catch (error) {
      console.error("Error fetching data:", error);
    }
  }
}
