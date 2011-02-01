function add_field(field) {
  field.insertBefore($('#filter_block'));
}

function add_selected_field() {
  add_field(filter_element_for($('#filter_name').val()));
}

function remove_field(field) {
  field.insertBefore($('#end_of_fields'));
}

function disable_current_option() {
  disable_option( $('#filter_name').val() );
}
function disable_option( option_name ) {
  $('#filter_name option[value=' + option_name + ']').attr('disabled', 'disabled');
  $('#filter_name').val('');
}

function enable_option( option_name ) {
  $('#filter_name option[value=' + option_name + ']').removeAttr('disabled');
}

function filter_element_for(name) {
  switch(name) {
    case 'id':
    case 'name':
    case 'email':
    case 'status':
    case 'state':
    case 'renewal':
    case 'publication':
    case 'gift':
    case 'created_at':
      return $('#' + name + '_field');
    case '':
      return $('');
    default:
      return $('<p>' + name + '</p>');
  }
}

function reset_form() {
  $(':input','#searchform')
     .not(':button, :submit, :reset, :hidden')
      .val('')
       .removeAttr('checked')
        .removeAttr('selected');
}
