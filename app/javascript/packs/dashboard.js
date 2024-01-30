import { fetch } from "./http";

// Tile handling
const SPINNER = '#tile-content-loading';
const TILE_CONTENT = '#tile-content-table';

// Visualize btns
const VULNS_BTN = '#v-vulnerabilities';
const REPORTS_BTN = '#v-reports';
const VM_SCANS_BTN = '#v-vm-scans';
const WA_SCANS_BTN = '#v-wa-scans';
const ACTIONS_BTN = '#v-actions';

// Handlers de clics
$(VULNS_BTN).click( function() {
  fetchVulnsStats();
});

$(REPORTS_BTN).click( function() {
  fetchLastReports();
});

$(VM_SCANS_BTN).click( function() {
  fetchVmScans();
});

$(WA_SCANS_BTN).click( function() {
  fetchWaScans();
});

$(ACTIONS_BTN).click( function() {
  fetchLastActiveActions();
});

function tile_fetch(url) {
  fetch(url, TILE_CONTENT, SPINNER);
}

// Récupération des données
function fetchVulnsStats() {
  tile_fetch("/dashboard/vulnerabilities");
}

function fetchLastReports() {
  tile_fetch("/dashboard/last_reports");
}

function fetchLastActiveActions() {
  tile_fetch("/dashboard/last_active_actions");
}

function fetchVmScans() {
  tile_fetch("/dashboard/last_vm_scans");
}

function fetchWaScans() {
  tile_fetch("/dashboard/last_wa_scans");
}

// Gestion chargement dashboard_default_card
// On cherche s'il existe un sticker vert symbolisant la vue par défaut
// Si oui on simule un clic sur le bouton de visualisation des données sous forme de table
const defaultViewElement = $('.card-btns-default-view.text-success');
if(defaultViewElement != undefined) {
  defaultViewElement.parents('.card-btns-v').click();
}

console.log('Dashboard loaded !');
