#coding:utf-8
from django.template.base import Library


register = Library()
def current_page_name(context):
    """
    Returns the current page name without slashes
    """
    page = context['__CACTUS_CURRENT_PAGE__']

    return page.final_url

register.simple_tag(takes_context=True)(current_page_name)
