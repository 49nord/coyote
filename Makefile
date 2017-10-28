VERSION=1.0
DEBNAME=coyote_$(VERSION)-1

$(DEBNAME).deb:
	rm -rf $(DEBNAME)
	mkdir $(DEBNAME)

	@# binary
	mkdir -p $(DEBNAME)/usr/bin
	cp coyote $(DEBNAME)/usr/bin

	@# systemd files
	mkdir -p $(DEBNAME)/lib/systemd/system
	cp coyote@.service coyote@.timer $(DEBNAME)/lib/systemd/system/

	@# nginx support
	mkdir -p $(DEBNAME)/etc/nginx/sites-available/
	cp 00_acme-challenge $(DEBNAME)/etc/nginx/sites-available/

	@# control
	cp -r DEBIAN $(DEBNAME)/

	@# build
	chmod -R a+rX $(DEBNAME)
	fakeroot dpkg-deb --build $(DEBNAME)

clean:
	rm -rf $(DEBNAME) $(DEBNAME).deb

.PHONY: $(DEBNAME).deb clean
