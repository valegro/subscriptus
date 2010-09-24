module SortingHelper
  def sort_link(title, column, options = {})
    condition = options[:unless] if options.has_key?(:unless)
    sort_dir = params[:d] == 'up' ? 'down' : 'up'
    image = sort_dir == 'up' ? image_tag("admin/icons/sort-asc.png") : image_tag("admin/icons/sort-desc.png")
    result = link_to_unless(condition, title, request.parameters.merge({ :c => column, :d => sort_dir }))
    if params[:c].to_s == column.to_s
      result << content_tag(:span, image)
    end
    result
  end
end
