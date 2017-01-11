#GNOME Usage

New GNOME Usage!

## Actual TODO:
- [x] Processor Usage
- [x] Memory usage
- [x] Network usage
- [x] RPM packages
- [x] Add loading ProcessListBox when open app 
- [x] Show fancy clear Process Box
- [x] Tweak network usage
- [x] Add Running/Sleeping/Dead label
- [ ] Support other architectures than x86_64 (netinfo precompiled library) 
- [ ] Fix bug with refreshing ProcessListBox 50% (focus, and click when refresh)
- [ ] DEB packages
- [ ] Storage view - 0%
- [ ] Power view (Design?)
- [ ] Disk usage (What library we can use?)
- [ ] Data view - 0%

##Installation from RPM
[Download RPM](https://github.com/petr-stety-stetka/gnome-usage/raw/master/rpmbuild/RPMS/x86_64/gnome-usage-0.3.7-1.x86_64.rpm)

##Run
In terminal run ```gnome-usage``` command or run GNOME Usage application from app launcher.

##Version
Actual version is 0.3.7

##Compilation from sources:
```
autovala update
cd build
cmake ..
make
sudo make install
sudo setcap cap_net_raw,cap_net_admin=eip /usr/local/bin/gnome-usage
```

##Building RPMs:
```
cd rpmbuild
rpmbuild --define "_topdir `pwd`" -ba SPECS/gnome-usage.spec
```

##License
Code is under GNU GPLv3 license.

##Screenshots:
More screenshots is in screenshots subdirectory (sorry screenshots may not be current).

![Screenshot](screenshots/screenshot11.png?raw=true )

![Screenshot](screenshots/screenshot10.png?raw=true )

##Design:
<img src="https://raw.githubusercontent.com/gnome-design-team/gnome-mockups/master/usage/usage-wires.png">
