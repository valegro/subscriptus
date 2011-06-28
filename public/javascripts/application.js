// This file is automatically included by javascript_include_tag :defaults

var Offer = {
  generate_link: function(offer_id, source_id) {
    var link = "https://subscribe.crikey.com.au/subscribe?offer_id=";
    link = link + offer_id;
    link = link + "&source=" + source_id;
    return link;
  }
}


