import Chart from 'chart.js/auto';

export const ChartJS = {
  // this functions will help deserialize the dataset
  dataset() { return JSON.parse(this.el.dataset.points); },
  labels() { return JSON.parse(this.el.dataset.labels); },

  mounted() {
    const ctx = this.el;
    const data = {
      type: 'doughnut',
      data: {
        labels: this.labels(),
        datasets: [{
          data: this.dataset(), 
          backgroundColor: ['#22c55e', '#B91C1C', '#d1d5db'],
          borderColor: ['#22c55e', '#B91C1C', '#d1d5db'],
          borderWidth: 1,
        }]
      },
      options: {
        responsive: true,
        plugins: {
          legend: {
            display: false,
          }
        }
      },
    
    };
    this.chart = new Chart(ctx, data);

    this.handleEvent("update-points", (payload) => {
      if (payload.id === this.el.id) {
        this.chart.data.datasets[0].data = payload.points;
        this.chart.update();
      }
    });
  },
} 