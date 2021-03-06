$(document).ready ->

  if $('#horizontal_nav ul.nav > li.active').count() > 0
    $('#horizontal_nav ul.nav > li').removeClass('under_this_category')

  if $('#horizontal_nav ul.nav > li.under_this_category').count() > 1
    $('#horizontal_nav ul.nav > li.under_this_category:not(:last)').removeClass('under_this_category')

  if $('#horizontal_nav ul.nav').height() > $('#horizontal_nav ul.nav > li:first').height() * 1.1
    $('#horizontal_nav ul.nav > li').each ->
      li = $(this)
      if li.data('short')
        li.find('a').text(li.data('short'))
      else
        max_length = 20
        if li.find('a').text().length > max_length
          li.find('a').text(li.find('a').text().substr(0, max_length) + "...")