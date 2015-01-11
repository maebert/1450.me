title: Solving the Instagram Engineering Challenge
draft: true
date: 2012-07-30
cover: instagram.jpg
preview: The folks at Instagram posed an interesting challenge: Basically, your task was to take an shredded image and undo the random shredding process with a few lines of code in a language of your choice. In their blog post, they wrote it took them 150 lines of code in python. So I thought a reasonable challenge would be be to solve the task in 15 lines of code.
---

The folks at Instagram posed an [interesting challenge](http://instagram-engineering.tumblr.com/post/12651721845) last week. Basically, your task was to take an image like this:

<img src="http://media.tumblr.com/tumblr_luigsoCv3s1qm4rc3.png" />

and undo the random shredding process with a few lines of code in a language of your choice. Bonus points for determining the width of the shreds from the image. In their blog post, they wrote it took them 150 lines of code in python. So I thought a reasonable challenge would be be to solve the task in 15 lines of code (comments omitted; I will explain the code later in this post).

    import PIL.Image, numpy, fractions
    image = numpy.asarray(PIL.Image.open('TokyoPanoramaShredded.png').convert('L'))
    diff = numpy.diff([numpy.mean(column) for column in image.transpose()])
    threshold, width = 1, 0

    while width < 5 and threshold < 255:
        boundaries = [index+1 for index, d in enumerate(diff) if d &gt; threshold]
        width = reduce(lambda x, y: fractions.gcd(x, y), boundaries) if boundaries else 0
        threshold += 1

    shreds = range(image.shape[1] / width)
    bounds = [(image[:,width*shred], image[:,width*(shred+1)-1]) for shred in shreds]
    D = [[numpy.linalg.norm(bounds[s2][1] - bounds[s1][0]) if s1 != s2 else numpy.inf for s2 in shreds] for s1 in shreds]
    neighbours = [numpy.argmin(D[shred]) for shred in shreds]
    walks = [sequence(neighbours, start) for start in shreds]
    new_order = max(walks)[1]

Without blank lines, that's exactly 14 lines of code (admittedly of varying beauty and elegance), including imports. It requires however a little function called sequence, which traverses a graph - given a list where each element is the index of the successor of the element, it returns a walk through the graph until it hits a cycle:

    def sequence(conn, start):
        seq = [start]
        while conn[seq[0]] not in seq:
            seq.insert(0, conn[seq[0]])
        return len(seq), seq

If you count this graph algorithm, we're at 19 lines of code, still acceptable. From a data scientist's point of view, I consider the problem solved. If you insist on some output, this will produce an unshredded version of the image:

    source_im = PIL.Image.open('TokyoPanoramaShredded.png')
    unshredded = PIL.Image.new("RGBA", source_im.size)
    for target, shred in enumerate(new_order):
        source = source_im.crop((shred*width, 0, (shred+1)*width, image.shape[1]))
        destination = (target*width, 0)
        unshredded.paste(source, destination)
    unshredded.save("solution.png")

## So, ehm, what exactly does it do?

    import PIL.Image, numpy, fractions
    image = numpy.asarray(PIL.Image.open('TokyoPanoramaShredded.png').convert('L')).astype('float')
    threshold, width = 1, 0

We're using the [Python Imaging Library](http://www.pythonware.com/products/pil),[numpy](http://numpy.scipy.org) and, to compute the greatest common denominator, the fractions module. We can of course write our own gcd function instead:

    def gcd(a, b):
        return a if b == 0 else gcd(b, a % b)

The second line loads the image, converts it to grayscale and turns it into a 2-dimensional numpy array. Next, we're going to compute the mean value of each column of pixels and use numpy to compute the difference between adjacent columns. Now, the idea for detecting the width of the shred the following: the greatest differences of mean column pixel value should occur at boundaries. The indices of these boundaries are multiples of the shred width. So we'll raise the threshold of what we consider to be a big difference until all the boundaries occur at multiples of some reasonably large width, ie. until they share a greatest common denominator > some minimal shred width:

    while width < 5 and threshold > 255:
        boundaries = [index+1 for index, d in enumerate(diff) if d > threshold]
        width = reduce(lambda x, y: fractions.gcd(x, y), boundaries) if boundaries else 0
        threshold += 1

The second line walks through our array of differences and remembers the index of all differences that are larger than our current shreshold. We add one because the `numpy.diff` operation dropped our leftmost pixel. The next line computes the GCD of a list using the incredibly useful but little known reduce `reduce` function, which iteratively replaces the first two elements of a list by the output of some function (in our case, the GCD) that we apply to them until there is only one value left in the list.

Assuming this works, we will have the shred width saved in the `width` variable after the loop terminates. Time for the real magic

    shreds = range(image.shape[1] / width)
    bounds = [(image[:,width*shred], image[:,width*(shred+1)-1]) for shred in shreds]

This first creates a list of all shred indices, and then a list with tuples containing the leftmost and rightmost pixel columns of each shred. The idea is that shreds belong together if their boundaries (their outer columns of pixel) match. So in the next line, we'll construct a matrix _D_ where _D<sub>ij</sub>_ will be a measure of how much the leftmost column of shred _D_ matches the righmost column of shred _j_. You can come up with a lot of clever measures for matching pixels here, I'll just interpret the pixel columns as vectors and calculate their euclidean distance using `numpy.linalg.norm`:

    D = [[numpy.linalg.norm(bounds[s2][1] - bounds[s1][0]) for s2 in shreds] \
        if s1 != s2 else numpy.Inf\
        for s1 in shreds]

We set the diagonal to a infinite value to make sure no shred matches itself.

For the next line, assume our algorithm is so good that the lowest difference will always be the actual neighbouring shred (in fact, it is). We can construct a simple directed neighbourhood graph in a single line of code:

    neighbours = [numpy.argmin(D[shred]) for shred in shreds]

Almost done, `neighbours[i]` will now be the left neighbour of shred _i_, but what is the leftmost shred? Well, since it doesn't have any leftmost neighbour in the source image, the neighbour the algorithm finds will be more or less random. This would induce cycles into our neighbourhood graph, and we can exploit this: only if we pick the correct rightmost shred, we should be able to traverse the neighbourhood graph and visit each node exactly once before ending up in a cycle. So we'll just construct the walks using the `sequence` method defined above and pick the longest walk as our new order of shreds.

    walks = [sequence(neighbours, start) for start in shreds]
    new_order = max(walks)[1]

`sequence` conviniently returns tuples containing the length of the walk as the first element and the walk as such as the second, this is why `max(walks)` works. Done. You can fork the code on my [GitHub Gist](https://gist.github.com/1382972).