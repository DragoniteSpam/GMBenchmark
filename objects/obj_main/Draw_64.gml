self.container.Render();
EmuOverlay.Render();

scribble(string("[c_ltgray]GameMaker version {0}", GM_runtime_version))
    .align(fa_left, fa_bottom)
    .draw(32, window_get_height() - 24);