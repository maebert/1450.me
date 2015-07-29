from markdown import markdown

ORDER = 999
BLOG_PATH = 'blog/'
PROJECT_PATH = 'projects/'
POSTS = []


def load_post(path):
    def parse_value(value):
        if not isinstance(value, basestring):
            return value
        if value.strip().lower() == "none":
            return None
        if value.startswith('"'):
            return value.strip('"')
        if value.strip().lower() == "true":
            return True
        if value.strip().lower() == "false":
            return False
        try:
            return int(value)
        except ValueError:
            pass
        try:
            return float(value)
        except ValueError:
            pass
        if value == "[]":
            return []
        elif value.startswith("["):
            l = value.strip("[]").split(",")
            return [parse_value(e.strip()) for e in l]
        else:
            return value.strip()

    with open(path) as f:
        front_matter, body = f.read().decode('utf-8').split("---")
        result = {'body': body}
        for line in front_matter.splitlines():
            key, value = line.split(":", 1)
            result[key.strip()] = parse_value(value)
        return result


def ampersandise(text):
    return text.replace(" & ", " <span class='amp'>&amp;</span> ")


def preBuild(site):

    global POSTS

    # Build all the posts
    for page in site.pages():
        if page.path.startswith(BLOG_PATH) or page.path.startswith(PROJECT_PATH):
            post = load_post(page.full_source_path)
            post['path'] = page.path
            post['category'] = 'blog' if page.path.startswith(BLOG_PATH) else 'projects'
            post['cover'] = '/static/covers/' + post['cover']
            post['preview'] = post.get('preview') or post['body']
            post['body'] = ampersandise(post['body'])
            post['title'] = ampersandise(post['title'])
            post['preview'] = ampersandise(markdown(post['preview']))
            if not post.get('draft'):
                POSTS.append(post)

    # Sort the posts by date
    POSTS = sorted(POSTS, key=lambda x: x['date'])
    POSTS.reverse()

    indexes = xrange(0, len(POSTS))

    for i in indexes:
        if i + 1 in indexes:
            POSTS[i]['prevPost'] = POSTS[i + 1]
        if i - 1 in indexes:
            POSTS[i]['nextPost'] = POSTS[i - 1]


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
