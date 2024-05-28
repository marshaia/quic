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
          // barThickness: 15,
        }]
      },
      options: {
        // indexAxis: 'y',
        // scales: { 
        //   x: { 
        //     display: true,
        //     grid: { display: false },
        //     ticks: { display: false }
        //   },
        //   y: { 
        //     beginAtZero: true,
        //     grid: { display: false },
        //   }
        //   // y: { beginAtZero: true, display: false}
        // },
        // elements: { 
        //   bar: { 
        //     // borderWidth: 2,
        //     // borderColor: 'green',
        //     backgroundColor: 'green'
        //   }
        // },
        responsive: true,
        plugins: {
          legend: {
            display: false,
          }
        }
      },
    
    };
    const chart = new Chart(ctx, data);
    // this.handleEvent("update-points", function(payload){ 
    //   chart.data.datasets[0].data = payload.points;
    //   chart.update();
    // })
  },

  updated() {
    this.el.chart.data.datasets[0].data = this.dataset()
    this.el.chart.data.labels = this.labels()
  }
} 