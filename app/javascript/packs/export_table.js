const EXPORT_BTN = '.btn-export';

$('#tile-content-table').on('click', EXPORT_BTN, function() {
  console.log(this.dataset.name);
  exportTableToCSV(this.dataset.name);
});

// TODO: convert to JQuery ?
function exportTableToCSV(name) {
  const csv = ["\ufeff"]; //Adding BOM
  const rows = document.querySelectorAll("#" + name + " tr");

  // TODO: handle colors and scoring ?
  for (const row of rows) {
    let csv_line = [], cols = row.querySelectorAll("td, th");
    for (const col of cols) {
      if (!col.hasAttribute('notexportable')) {
        if(col.dataset.export != undefined) {
          csv_line.push(col.dataset.export);
        } else {
          csv_line.push(col.innerText);
        }
      }
    }
    csv.push(csv_line.join(";"));
  }

  // Download CSV file
  let d = new Date();
  downloadCSV(csv.join("\n"), name + "-" + d.toDateString().replace(/ /g, "-") + '.csv');
}

function downloadCSV(csv, filename) {
  let csvFile = new Blob([csv], {type: "text/csv"});
  let downloadLink = document.createElement("a");

  // File name
  downloadLink.download = filename;

  // Create a link to the file
  //TODO: Change how it is created ?
  downloadLink.href = window.URL.createObjectURL(csvFile);

  // Hide download link
  downloadLink.style.display = "none";

  // Add the link to DOM
  document.body.appendChild(downloadLink);

  // Click download link
  downloadLink.click();
}
