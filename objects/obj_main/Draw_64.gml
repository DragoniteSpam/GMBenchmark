self.container.Render();
EmuOverlay.Render();

scribble($"[c_ltgray]GameMaker version {GM_runtime_version}")
    .align(fa_left, fa_bottom)
    .draw(32, window_get_height() - 24);