import os
import datetime
import logging
import yaml

ORDER = 999
BLOG_PATH = 'blog/'
PROJECT_PATH = 'projects/'
POSTS = []

from django.template import Context
from django.template.loader import get_template
from django.template.loader_tags import BlockNode, ExtendsNode

def getNode(template, context=Context(), name='subject'):
	"""
	Get django block contents from a template.
	http://stackoverflow.com/questions/2687173/
	django-how-can-i-get-a-block-from-a-template
	"""
	for node in template:
		if isinstance(node, BlockNode) and node.name == name:
			return node.render(context)
		elif isinstance(node, ExtendsNode):
			return getNode(node.nodelist, context, name)
	raise Exception("Node '%s' could not be found in template." % name)


def preBuild(site):

	global POSTS

	# Build all the posts
	for page in site.pages():
		if page.path.startswith(BLOG_PATH) or page.path.startswith(PROJECT_PATH):
			with open(page.full_source_path) as f:
				font_matter, body = f.read().split("---")
				postContext = yaml.load(font_matter)
				postContext['body'] = body
			postContext['path'] = page.path
			postContext['category'] = 'blog' if page.path.startswith(BLOG_PATH) else 'projects'
			postContext['cover'] = '/static/covers/' + postContext['cover']
			POSTS.append(postContext)

	# Sort the posts by date
	POSTS = sorted(POSTS, key=lambda x: x['date'])
	POSTS.reverse()

	indexes = xrange(0, len(POSTS))

	for i in indexes:
		if i+1 in indexes: POSTS[i]['prevPost'] = POSTS[i+1]
		if i-1 in indexes: POSTS[i]['nextPost'] = POSTS[i-1]


def preBuildPage(site, page, context, data):
	"""
	Add the list of posts to every page context so we can
	access them from wherever on the site.
	"""
	context['blog'] = [post for post in POSTS if post['category'] == 'blog']
	context['projects'] = [post for post in POSTS if post['category'] == 'projects']

	for post in POSTS:
		if post['path'] == page.path:
			context.update(post)

	return context, data
