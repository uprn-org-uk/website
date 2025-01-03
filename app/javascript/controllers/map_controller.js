import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Initialize the map
    this.map = L.map('map').setView([51.505, -0.09], 13);

    // Add OpenStreetMap tiles
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '© OpenStreetMap contributors'
    }).addTo(this.map);

    // Add event listener for map movement
    this.map.on('moveend', this.loadUprns.bind(this));
  }

  async loadUprns() {
    const bounds = this.map.getBounds();
    
    try {
      const response = await fetch(`/uprns?min_lat=${bounds.getSouth()}&max_lat=${bounds.getNorth()}&min_lng=${bounds.getWest()}&max_lng=${bounds.getEast()}`);
      const data = await response.json();
      
      // Clear existing markers
      if (this.markers) {
        this.markers.forEach(marker => marker.remove());
      }
      this.markers = [];

      // Add new markers
      data.forEach(uprn => {
        const marker = L.marker([uprn.latitude, uprn.longitude])
          .bindPopup(`UPRN: ${uprn.uprn}`)
          .addTo(this.map);
        this.markers.push(marker);
      });
    } catch (error) {
      console.error('Error loading UPRNs:', error);
    }
  }
} 