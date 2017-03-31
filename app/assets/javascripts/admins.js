$(document).ready(function() {
  $('.delete-rights').click(function(event) {
    event.preventDefault();
    $.ajax({
      data: {
        permissions: event.target.getAttribute('permissions'),
      },
      method: 'DELETE',
      dataType: 'script',
      url: '/rights',
    });
  });
});
