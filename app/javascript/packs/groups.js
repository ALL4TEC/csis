import { fetch } from './http';

// Cards handling
const USERS_CARD_CONTENT = '#groups-users-card';
const STAFF_CARD_CONTENT = '#groups-staff-card';
const CONTACT_CARD_CONTENT = '#groups-contact-card';
const USERS_CARD_CONTENT_SPINNER = '#groups-users-card-spinner';
const STAFF_CARD_CONTENT_SPINNER = '#groups-staff-card-spinner';
const CONTACT_CARD_CONTENT_SPINNER = '#groups-contact-card-spinner';

// Récupération des données users
function fetchUsers() {
  fetch("/groups/users", USERS_CARD_CONTENT, USERS_CARD_CONTENT_SPINNER);
}

function fetchStaffGroup() {
  fetch("/groups/staff", STAFF_CARD_CONTENT, STAFF_CARD_CONTENT_SPINNER);
}

function fetchContactGroup() {
  fetch("/groups/contact", CONTACT_CARD_CONTENT, CONTACT_CARD_CONTENT_SPINNER);
}

$(document).ready(function() {
  fetchUsers();
  fetchStaffGroup();
  fetchContactGroup();
});

console.log('Groups loaded !');
