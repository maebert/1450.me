deploy:
	aws s3 sync web s3://1450.me --exclude "*.less" --exclude ".DS_Store" --acl public-read --cache-control "public, max-age=86400"

all:
	git add --all
	git commit -m "Site update"
	git push
	deploy
