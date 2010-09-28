function add_field(field) {
  field.insertBefore($('#filter_name'));
}

function add_selected_field() {
  add_field(filter_element_for($('#filter_name').val()));
}

function remove_field(field) {
  field.insertBefore($('#end_of_fields'));
}

function disable_current_field() {
  $('#filter_name option[value=' + $('#filter_name').val() + ']').attr('disabled', 'disabled');
  $('#filter_name').val('')
}

function enable_field( field_name ) {
  $('#filter_name option[value=' + field_name + ']').removeAttr('disabled');
}

function filter_element_for(name) {
  switch(name) {
    case 'name':
    case 'status':
    case 'renewal':
    case 'publication':
    case 'gift':
      return $('#' + name + '_field');
    case '':
      return $('');
    default:
      return $('<p>' + name + '</p>');
  }
}
