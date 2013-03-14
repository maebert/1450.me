#! /usr/binpython
# encoding: utf-8
import yaml
import codecs
import os
import markdown
from jinja2 import Environment, FileSystemLoader
import pygments
from pygments.lexers import PythonLexer
from pygments.formatters import HtmlFormatter
import re
import shutil
import time
import distutils.dir_util

code_pattern = re.compile(r"^<code><pre>(.+)</pre></code>", re.MULTILINE)
config = {
    'content': 'content',
    'output': '/Users/maebert/projects/maebert.github.com',
    'media': '/Users/maebert/projects/portwempreludium/media',
    'content': '/Users/maebert/projects/portwempreludium/content'
}


class Blog:
    entries = []

    def add_folder(self, path):
        for filename in os.listdir(path):
            full_filename = os.path.join(path, filename)
            if os.path.isfile(full_filename)  and full_filename.endswith("txt"):
                self.add_entry(full_filename)

    def get_category(self, category):
        return [e for e in self.entries if e['category'] == category]

    def write_partial(self, entry, template):
        html = template.render(entry=entry)
        with codecs.open(get_abs_path(os.path.join(entry["category"], entry["slug"] + ".html")), mode='w', encoding="utf-8") as f:
            f.write(html)

    def add_entry(self, filename):
        with codecs.open(filename, encoding="utf-8") as f:
            content = f.read()
            slug = os.path.basename(filename)
            front_matter_start = content.find('---')
            front_matter_end = content.find('---', front_matter_start+3)
            front_matter = content[front_matter_start+3:front_matter_end]
            entry = yaml.load(front_matter)
            entry['markdown'] = content[front_matter_end+4:]
            html = markdown.markdown(entry['markdown'])

            # for code in soup.find_all('pre'):
            #     hl = pygments.highlight(code.text, PythonLexer(), HtmlFormatter())
            #     #print hl
            #     code.string.replace_with(hl)
            entry['html'] = html
            entry['slug'] = slug[:slug.find(".")]
            entry['month'] = entry['date'].strftime("%b")
            #print time.strptime("%Y-%M-%d", entry['date'])

            if not entry.has_key('thumbnail'):
                mediafile = os.path.join("media", "banners", entry['slug'])

            if type(entry['tags']) is str:
                entry['tags'] = [t.strip() for t in entry['tags'].split(",")]

            self.entries.append(entry)
            return entry

def get_abs_path(filename, mkdir=False):
    path = os.path.join(config['output'], filename)
    if mkdir:
        try:
            os.mkdir(path)
        except:
            pass
    return path

distutils.dir_util.copy_tree

if __name__ == "__main__":
    blog = Blog()
    content_path = os.path.expanduser(config['content'])
    blog.add_folder(os.path.join("content", "blog"))
    blog.add_folder(os.path.join("content", "portofolio"))

    env = Environment(loader=FileSystemLoader('templates'))
    template = env.get_template('index.html')
    index = template.render(portofolio=blog.get_category("portofolio"), blog=blog.get_category("blog"))
    with codecs.open(get_abs_path('index.html'), mode='w', encoding="utf-8") as f:
        f.write(index)

    media_dst = get_abs_path("media", mkdir=True)
    distutils.dir_util.copy_tree(config['media'], media_dst)
    for entry in blog.get_category("portofolio"):
        get_abs_path("portofolio", mkdir=True)
        template = env.get_template(entry["category"] + ".partial")
        blog.write_partial(entry, template)
