THISDIR = $(shell pwd)
ROMFS_DIR = $(ROOTDIR)/romfs
all:

clean:

romfs:
	cp -R hp $(ROMFS_DIR)/etc_ro
	$(ROMFSINST) -p +x+r /sbin/mdev_lp
	$(ROMFSINST) -p +x+r /usr/sbin/start
	$(ROMFSINST) -p +x+r $(THISDIR)/mdnsd/dns-sd /usr/sbin/dns-sd
	$(ROMFSINST) -p +x+r $(THISDIR)/mdnsd/mdnsd /usr/sbin/mdnsd
	$(ROMFSINST) $(THISDIR)/mdnsd/libdns_sd.so /lib/libdns_sd.so