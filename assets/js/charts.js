import Chart from 'chart.js/auto';

export const ChartJS = {
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
          backgroundColor: ['#22c55e', '#d62020', '#d1d5db'],
          borderColor: ['#126e33', '#570d0d', '#78797a'],
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