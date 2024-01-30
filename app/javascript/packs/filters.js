const FILTER_ID = "#filter-body";
const FILTERS_CLASS = "#card-filters-a";

$(FILTER_ID).on("show.bs.collapse", function() {
    $(FILTERS_CLASS).removeClass("p-0");
});

$(FILTER_ID).on("hide.bs.collapse", function() {
    $(FILTERS_CLASS).addClass("p-0");
});