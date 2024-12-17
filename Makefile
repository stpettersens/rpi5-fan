COMPILER=ldc2
PROGRAM=control_fan

make:
	$(COMPILER) $(PROGRAM).d
	rm -f $(PROGRAM).o
	strip $(PROGRAM)
	upx -9 $(PROGRAM)

install:
	@echo Please run make install with sudo/doas.
	cp -f $(PROGRAM) /usr/local/bin
	cp -f $(PROGRAM)_systemd.service /etc/systemd/system/$(PROGRAM).service
	systemctl enable $(PROGRAM)
	systemctl start $(PROGRAM)
	systemctl status $(PROGRAM)

uninstall:
	@echo Please run make uninstall with sudo/doas.
	systemctl stop $(PROGRAM)
	sleep 5
	systemctl disable $(PROGRAM)
	rm -f /etc/systemd/system/$(PROGRAM).service
	rm -f /usr/local/bin/$(PROGRAM)

clean:
	rm -f $(PROGRAM)
