#! /usr/binpython
# encoding: utf-8
import knyfe
import yaml
import os
import markdown
import codecs
from jinja2 import Environment, FileSystemLoader
import pygments
from pygments.lexers import PythonLexer
from pygments.formatters import HtmlFormatter
import re
import shutil
import time

code_pattern = re.compile(r"^<code><pre>(.+)</pre></code>", re.MULTILINE)
config = {
    'content': '~/code/portwem/content'
}


class Blog(knyfe.Data):
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
            code_pattern
            # for code in soup.find_all('pre'):
            #     hl = pygments.highlight(code.text, PythonLexer(), HtmlFormatter())
            #     #print hl
            #     code.string.replace_with(hl)
            entry['html'] = html
            entry['slug'] = slug[:slug.find(".")]
            entry['month'] = entry['date'].strftime("%b")
            #print time.strptime("%Y-%M-%d", entry['date'])

            banner = os.path.join(os.path.dirname(filename), "img", entry['slug'])
            mediafile = os.path.join("media", "banners",entry['slug'])
            if os.path.exists(banner+".png"):
                mediafile += ".png"
                banner += ".png"
            elif os.path.exists(banner+".jpg"):
                mediafile += ".png"
                banner += ".jpg"
            else:
                banner = None
                mediafile += ".png"

            if banner:
                shutil.copyfile(banner, mediafile)
            else:
                shutil.copyfile(os.path.join(os.path.dirname(filename), "img", "default.png"), mediafile)

            entry['img'] = mediafile

            if type(entry['tags']) is str:
                entry['tags'] = [t.strip() for t in entry['tags'].split(",")]



            self.data.append(entry)

if __name__ == "__main__":
    blog = Blog()
    for filename in os.listdir(os.path.expanduser(config['content'])):
        full_filename = os.path.join(os.path.expanduser(config['content']), filename)
        if os.path.isfile(full_filename):
            blog.add_entry(full_filename)

    env = Environment(loader=FileSystemLoader('templates'))
    template = env.get_template('index.html')
    index = template.render(entries=blog.data)
    with codecs.open('index.html', mode='w', encoding="utf-8") as f:
        f.write(index)
