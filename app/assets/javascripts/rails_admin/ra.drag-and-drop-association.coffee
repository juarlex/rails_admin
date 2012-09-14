$ = jQuery

draggable_link = (resource) ->
  $(resource).removeClass('ui-droppable')
  $(resource).removeClass('ui-draggable-dragging')
  $(resource).draggable(revert: 'valid')
  $(resource).css('position', '')

droppable_link = (resource) ->
  $(resource).removeClass('ui-droppable')
  $(resource).draggable(revert: 'invalid')
  $(resource).css('position', '')
  droppable_least_of_all_me(resource)

move_records_per_association = (orig_resource, dest_resource) ->
  new_id = $(dest_resource.parentNode.parentNode).find('#bulk_ids_')[0].value
  association_name = $(orig_resource).attr('data-acceptable-association')
  $.ajax
    url: $(orig_resource).attr('href')
    type: 'PUT'
    data:
      new_id: new_id
      association_name: association_name
    dataType: 'html'
    async: false
    success: (data) ->
      orig_resource.children().first().html(association_name + ': 0')
      orig_resource.parent().contents().filter(->
          !$(this).hasClass('drag-and-drop-associated-records')
        ).remove()
      droppable_link(orig_resource)
      $(dest_resource.parentNode).html(data)
      droppable_link(dest_resource)

droppable_least_of_all_me = (orig_resource) ->
  association_name = $(orig_resource).attr('data-acceptable-association')
  $('.drag-and-drop-associated-records.'+association_name).each ->
    if (this.href != orig_resource.href) && ($(this).attr('data-acceptable-association') == association_name)
      $(this).droppable
        accept: '.'+association_name
        activeClass: 'ui-state-hover'
        hoverClass: 'ui-state-active'

$('.drag-and-drop-associated-records').live 'hover', ->
  droppable_least_of_all_me(this)
  draggable_link(this)

$('.drag-and-drop-associated-records').live 'drop', (event, ui) ->
  if confirm('Do you want to move these records')
    move_records_per_association(ui.draggable, this)
  else
    draggable_link(ui.draggable)

$('.drag-and-drop-associated-records').live 'click', (e) ->
  e.preventDefault()

false
