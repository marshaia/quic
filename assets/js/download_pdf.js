import { jsPDF } from "jspdf";
import html2canvas from "html2canvas";

export const JSPDF = {
  mounted() {
    this.handleEvent("participant_stats", async (obj) => {
      let path = obj.file_name + ".pdf";
      const orientation = obj.orientation;
      let table = document.getElementById("participant_statistics_table");

      if (table) {
        table = p_tag_with_margin_top(table, false)
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

        table = p_tag_with_margin_top(table, true)
        if (theme && theme === "dark") {
          change_text_color(table, false);
        }

        // Convert the canvas to an image
        let imgData = canvas.toDataURL("image/png");

        // Create a new jsPDF instance
        let doc = new jsPDF({
          orientation: orientation,
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

  var rows = table.getElementsByTagName("tr");
  for (var i = 0; i < rows.length; i++) {
    if (to_black) {
      rows[i].classList.replace("border-[var(--border)]", "border-[#dfe7ef]");
    } else {
      rows[i].classList.replace("border-[#dfe7ef]", "border-[var(--border)]");
    }
  }

  var headers = table.getElementsByTagName("th");
  for (var i = 0; i < headers.length; i++) {
    headers[i].classList.remove(remove_class);
    headers[i].classList.add(new_class);
  }

  var paragraphs = table.getElementsByTagName("p");
  for (var i = 0; i < paragraphs.length; i++) {
    paragraphs[i].classList.remove(remove_class);
    paragraphs[i].classList.add(new_class);
  }

  return table
}


function p_tag_with_margin_top(table, remove_margin) {
  var paragraphs = table.getElementsByTagName("p");
  for (var i = 0; i < paragraphs.length; i++) {
    if (remove_margin) {
      paragraphs[i].classList.add("mt-0");
    } else {
      paragraphs[i].classList.add("-mt-5");
    }
  }
  return table
}