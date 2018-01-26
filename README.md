Tmux gate.io ticker
===================

Enables displaying prices of coins from [gate.io](https://gate.io/) in tmux status bar

Usage
-----

This is done by introducing a new format string:

- `#{gateio_ticker}` - display prices


Add it to `status-right` or `status-left` tmux option:

```
set -g status-right "#{gateio_ticker}"
```

Preview:

```
BTC/USD: $11431.12, XRP/USDT: -8.25%, DOGE/USDT: 3.03%
```

Installation
------------

**via tpm (recommended)**

1.  Installation [tpm](https://github.com/tmux-plugins/tpm).

2.  Add plugin to the list of tpm plugins in `.tmux.conf`:

    ```
    set -g @plugin 'modood/tmux-gateio-ticker'
    ```

3.  Hit `prefix + I` to fetch the plugin and source it.
4.  If format strings are added to `status-right` or `status-left`, they should now be visible.

----
**manual Installation**

1.  Clone the repo:

    ```
    $ git clone https://github.com/modood/tmux-gateio-ticker ~/clone/path
    ```

2.  Add this line to the bottom of `.tmux.conf`:

    ```
    run-shell ~/clone/path/gateio_ticker.tmux
    ```

3.  Reload TMUX environment:

    ```
    $ tmux source-file ~/.tmux.conf
    ```

4.  If format strings are added to `status-right` or `status-left`, they should now be visible.

Contributing
------------

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

License
-------

This repo is released under the [MIT License](http://www.opensource.org/licenses/MIT).
