import { jsPDF } from "jspdf";
import html2canvas from "html2canvas";

export const JSPDF = {
  mounted() {
    this.handleEvent("participant_stats", async (obj) => {
      let path = obj.file_name + ".pdf";
      const orientation = obj.orientation;
      let table = document.getElementById("participant_statistics_table");

      if (table) {
        // Wait for the table to fully render if needed
        await new Promise(resolve => setTimeout(resolve, 1000));

        theme = localStorage.getItem("theme");
        if (theme && theme === "dark") {
          table = change_text_color(table, true)
        }
      
        // Capture the table using html2canvas
        let canvas = await html2canvas(table, {
          scale: 3, // Higher scale for better resolution
          useCORS: true,
          willReadFrequently: true,
        });

        if (theme && theme === "dark") {
          change_text_color(table, false);
        }

        // Convert the canvas to an image
        let imgData = canvas.toDataURL("image/png");

        // Create a new jsPDF instance
        let doc = new jsPDF({
          orientation: orientation, //'portrait',
          unit: 'mm',
          format: 'a4',
        });

        let imgWidth;
        let imgHeight;

        if (orientation === "portrait") {
          imgWidth = 190; // Width of the A4 page in mm minus margins
          imgHeight = (canvas.height * imgWidth) / canvas.width;
        } else {
          imgWidth = 277; // Width of the A4 page in landscape mode minus margins
          imgHeight = (canvas.height * imgWidth) / canvas.width;
        }

        // Add the image to the PDF
        doc.addImage(imgData, 'PNG', 10, 10, imgWidth, imgHeight);

        // Save the PDF
        doc.save(path);
        this.pushEvent("finished_download", {});

      } else {
        console.error("Table element not found.");
      }
    });
  }
}

function change_text_color(table, to_black) {
  remove_class = to_black ? "text-[var(--primary-color-text)]" : "text-black";
  new_class = to_black ? "text-black" : "text-[var(--primary-color-text)]";

  var headers = table.getElementsByTagName("th");
  for (var i = 0; i < headers.length; i++) {
    headers[i].classList.remove(remove_class);
    headers[i].classList.add(new_class);
  }

  var cells = table.getElementsByTagName("td");
  for (var i = 0; i < cells.length; i++) {
    var paragraphs = cells[i].getElementsByTagName("p");
    for (var j = 0; j < paragraphs.length; j++) {
      paragraphs[j].classList.remove(remove_class);
      paragraphs[j].classList.add(new_class);
    }
  }
  return table
}
