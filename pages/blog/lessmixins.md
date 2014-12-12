title: Less-Mixins
draft: true
date: 2012-07-30
cover: instragram.jpg
---
If you want to get your icons retina-ready, there are two ways to go:

* Use font icons such as [Font Awesome](http://fortawesome.github.com/Font-Awesome/)
* Supply alternative double-sized images that should be used for retina displays.

While I'm a fan of font icons, those restrict you to use monochromatic icons. Mixins and polyfills like [retina.js](http://www.retinajs.com) work great as well, but are still very cumbersome if you want to use sprites to combine your icons into single image files (which you should)! Here's a little [LESS](http://lesscss.org/) mixin that does all the manual work for you. Basically, if you have an image like that:

![Picture](https://coderwall-assets-0.s3.amazonaws.com/uploads/picture/file/1263/explanation.png)

And HTML like that:

    <i class="facebook"></i>
    <i class="google"></i>
    <i class="dribbble"></i>

Using the following `.sprite` mixin

    @highdpi: ~"(-webkit-min-device-pixel-ratio: 1.5), (min--moz-device-pixel-ratio: 1.5), (-o-min-device-pixel-ratio: 3/2), (min-resolution: 1.5dppx)";

    .sprite (@path, @size, @w, @h, @pad: 0) when (isstring(@path))
        {
        background-image: url(@path);
        width: @size;
        height: @size;
        display: inline-block;
        @at2x_path: ~`@{path}.replace(/\.[\w\?=]+$/, function(match) { return "@2x" + match; })`;
        font-size: @size + @pad;
        @media @highdpi
            {
            background-image: url("@{at2x_path}");
            background-size: (@size + @pad) * @w   (@size + @pad) * @h;
            }
        }

    .sprite(@x, @y)
        {
        background-position: -@x * 1em -@y * 1em;
        }


You can specify your sprites like that:

    i
        {
        .sprite("icons.png", 20px, 3, 2, 5px);
        &.github   { .sprite(0, 0) }
        &.dribbble { .sprite(1, 0) }
        &.linkedin { .sprite(2, 0) }
        &.twitter  { .sprite(0, 1) }
        &.google   { .sprite(1, 1) }
        &.facebook { .sprite(2, 1) }
        }

The first time we call `.sprite`, we set the path to the image, the width of the icon, the number of icons in each row and column, and the padding between icons. Then for each different icon class, we set the position of the icon in the sprite file starting from `(0, 0)` in the upper left corner.

On retina displays, `icons.png` will be replaces with icons@2x.png, so you will have to provide these two images. This uses the little trick of setting the `font-size` of the `i` element to sprite width + padding to figure out the right offset on the individual icon calls. That restricts us to using square sprites; if anybody has a better idea please let me know!
