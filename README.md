# plasma-applet-places-widget

Plasma 5 widget that gives access to user places

![Screen shot of plasma-applet-places-widget](places-widget.png)

## Installation

### From openDesktop.org

1. Go to [https://www.opendesktop.org/p/1084935/](https://www.opendesktop.org/p/1084935/)
2. Click on the `Files` tab
3. Click the `Install` button

### From source

```
git clone https://github.com/dfaust/plasma-applet-places-widget
cd plasma-applet-places-widget
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
make
sudo make install
```

Dependencies:

* plasma-workspace >= 5.6
* plasma-framework-devel
