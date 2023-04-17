var ew = 256;
var eh = 32;

self.container = new EmuCore(0, 0, window_get_width(), window_get_height()).AddContent([
    new EmuList(32, EMU_AUTO, ew, eh, "Benchmarks:", eh, 12, function() {
    }).SetList(Benchmarks)
]);