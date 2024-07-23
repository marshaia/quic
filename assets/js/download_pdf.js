import { jsPDF } from "jspdf";
import html2canvas from "html2canvas";

export const JSPDF = {
  mounted() {
    this.handleEvent("download_page", (obj) =>  {
      this.download_page(obj.file_name, obj.html_element, obj.is_table)
    })

    // this.handleEvent("participant_stats", async (obj) => {
      // let path = obj.file_name + ".pdf";
      // const orientation = obj.orientation;
      // let table = document.getElementById("participant_statistics_table");

      // if (table) {
      //   //table = p_tag_with_margin_top(table, false)
      //   theme = localStorage.getItem("theme");
      //   if (theme && theme === "dark") {
      //     table = change_text_color(table, true)
      //   }
      
      //   // Capture the table using html2canvas
      //   let canvas = await html2canvas(table, {
      //     scale: 3, // Higher scale for better resolution
      //     useCORS: true,
      //     willReadFrequently: true,
      //   });

      //   // table = p_tag_with_margin_top(table, true)
      //   if (theme && theme === "dark") {
      //     change_text_color(table, false);
      //   }

      //   // Convert the canvas to an image
      //   let imgData = canvas.toDataURL("image/png");

      //   // Create a new jsPDF instance
      //   let doc = new jsPDF({
      //     orientation: orientation,
      //     unit: 'mm',
      //     format: 'a4',
      //   });

      //   let imgWidth;
      //   let imgHeight;

      //   if (orientation === "portrait") {
      //     imgWidth = 190; // Width of the A4 page in mm minus margins
      //     imgHeight = (canvas.height * imgWidth) / canvas.width;
      //   } else {
      //     imgWidth = 277; // Width of the A4 page in landscape mode minus margins
      //     imgHeight = (canvas.height * imgWidth) / canvas.width;
      //   }

      //   // Add the image to the PDF
      //   doc.addImage(imgData, 'PNG', 10, 10, imgWidth, imgHeight);

      //   // Save the PDF
      //   doc.save(path);
      //   this.pushEvent("finished_download", {});

      // } else {
      //   console.error("Table element not found.");
      // }
      //this.download_page(obj.file_name, "participant_statistics_table")
    // });
  },

  async download_page(file_name, html_element, is_table) {
    let content = document.getElementById(html_element);
    const margin = 20; // Margin in points

    theme = localStorage.getItem("theme")
    put_quiz_name_black(true)
    if (is_table && theme && theme === "dark") {
      content = change_text_color(content, true)
    } 

    html2canvas(content, { scale: 3, useCORS: true }).then(canvas => {
      const imgData = canvas.toDataURL('image/png');
      const pdf = new jsPDF({
        orientation: 'portrait',
        unit: 'pt',
        format: 'a4'
      });

      put_quiz_name_black(false)
      if (is_table && theme && theme === "dark") {
        content = change_text_color(content, false)
      } 

      const pdfWidth = pdf.internal.pageSize.getWidth();
      const pdfHeight = pdf.internal.pageSize.getHeight();

      // Calculate the available width and height for the image
      const contentWidth = pdfWidth - 2 * margin;
      const contentHeight = pdfHeight - 2 * margin;

      // Calculate the image height keeping the aspect ratio
      const imgProps = pdf.getImageProperties(imgData);
      const imgHeight = (imgProps.height * contentWidth) / imgProps.width;
      let heightLeft = imgHeight;
      let position = margin;

      // Add the image to the PDF
      pdf.addImage(imgData, 'PNG', margin, position, contentWidth, imgHeight);
      heightLeft -= contentHeight;

      while (heightLeft > 0) {
        position = heightLeft - imgHeight + margin;
        pdf.addPage();
        pdf.addImage(imgData, 'PNG', margin, position, contentWidth, imgHeight);
        heightLeft -= contentHeight;
      }

      pdf.save(file_name + ".pdf");
      this.pushEvent("finished_download", {});
    });
  }
}


function put_quiz_name_black(to_black) {
  quiz_name = document.getElementById("session_quiz_name")
  if (quiz_name) {
    if (to_black) {
      quiz_name.classList.replace("text-gradient", "text-black")
    } else {
      quiz_name.classList.replace("text-black", "text-gradient")
    }
  }
}


function change_text_color(content, to_black) {
  remove_class = to_black ? "text-[var(--primary-color-text)]" : "text-black";
  new_class = to_black ? "text-black" : "text-[var(--primary-color-text)]";

  var rows = content.getElementsByTagName("tr");
  for (var i = 0; i < rows.length; i++) {
    if (to_black) {
      rows[i].classList.replace("border-[var(--border)]", "border-[#dfe7ef]");
    } else {
      rows[i].classList.replace("border-[#dfe7ef]", "border-[var(--border)]");
    }
  }

  var headers = content.getElementsByTagName("th");
  for (var i = 0; i < headers.length; i++) {
    headers[i].classList.remove(remove_class);
    headers[i].classList.add(new_class);
  }

  var paragraphs = content.getElementsByTagName("p");
  for (var i = 0; i < paragraphs.length; i++) {
    paragraphs[i].classList.remove(remove_class);
    paragraphs[i].classList.add(new_class);
  }

  return content
}


// function p_tag_with_margin_top(table, remove_margin) {
//   var paragraphs = table.getElementsByTagName("p");
//   for (var i = 0; i < paragraphs.length; i++) {
//     if (remove_margin) {
//       paragraphs[i].classList.add("mt-0");
//     } else {
//       paragraphs[i].classList.add("-mt-4");
//     }
//   }
//   return table
// }