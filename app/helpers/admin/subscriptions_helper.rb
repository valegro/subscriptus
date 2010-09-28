module Admin::SubscriptionsHelper
  def render_result_row(result)
    content_tag('tr',
                content_tag( 'td', link_to( result.user.try(:fullname), '/' ) ) +
                content_tag( 'td', result.user.try(:email) ) +
                content_tag( 'td', result.publication.try(:name) ) +
                content_tag( 'td', result.state ) +
                content_tag( 'td', result.expires_at.try(:strftime, "%d/%m/%Y") ) +
                content_tag( 'td', result.created_at.try(:strftime, "%d/%m/%Y") )
                )
  end
end
