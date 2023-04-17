var ew = 320;
var eh = 32;

self.container = new EmuCore(0, 0, window_get_width(), window_get_height()).AddContent([
    new EmuList(32, EMU_AUTO, ew, eh, "Benchmarks:", eh, 12, function() {
        var bench = self.GetSelectedItem();
        var item_list = self.GetSibling("BENCHMARK ITEM LIST");
        if (item_list) {
            if (bench) {
                item_list.SetVacantText("No items in this benchmark")
                item_list.SetList(bench.tests);
            } else {
                item_list.SetVacantText("Select a benchmark")
                item_list.SetList(-1);
            }
        }
    })
        .SetAllowDeselect(false)
        .SetVacantText("No benchmark tests")
        .SetList(Benchmarks)
        .SetEntryTypes(E_ListEntryTypes.STRUCTS)
        .SetID("BENCHMARK LIST"),
    new EmuList(32, EMU_AUTO, ew, eh, "Results:", eh, 8, function() {
    })
        .SetVacantText("Select a benchmark")
        .SetEntryTypes(E_ListEntryTypes.STRUCTS)
        .SetID("BENCHMARK ITEM LIST")
]);