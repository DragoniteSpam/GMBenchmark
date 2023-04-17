# GMBenchmark

Hi, I made a tool for benchmarking code in [GameMaker](https://gamemaker.io/en).

## Using it

Clone the repository, open the GameMaker project, and run it. You'll see a pretty little UI and some data relatingn to the performance of different bits of code.

To add your own tests, go into the `GM_Benchmarks` and edit (or add to) the list of items in the `Benchmarks` array.

A `Benchmark` object is a constructor which takes a name as a string, and a series of `TestCase` instances. The `Benchmark` constructor is variadic and will accept as many test cases as you feel like giving it.

A `TestCase` object is a constructor which takes a name as a string, and a function containing the code you want to time. I recommend putting the relevant bits of code in a repeat loop of several thousand (or more) iterations to get a good average and smooth out random performance fluctuations caused by your OS's tasks scheduler.

For example:

    new Benchmark("Growable Collections x 10,000",
        new TestCase("array_push", function() {
            var array = [];
            repeat (10_000) {
                array_push(array, 0);
            }
        }), new TestCase("ds_list_add", function() {
            var list = ds_list_create();
            repeat (10_000) {
                ds_list_add(list, 0);
            }
            ds_list_destroy(list);
        }), new TestCase("buffer_grow", function() {
            var buffer = buffer_create(1, buffer_grow, 1);
            repeat (10_000) {
                buffer_write(buffer, buffer_u32, 0);
            }
            buffer_delete(buffer)
        })
    )

If your tests require any additional setup you may consider tossing a few global variables in the `GM_Benchmark_Setup` code file so that it doesn't bog down the results of the actual test. Don't worry, I won't tell the GameMaker police.

## Contributing

### Tests

If anyone has any fun benchmarks they want to add, I'll merge them in. Your own benchmarks should:
 - Run consistently - don't do anything that would cause the results to change dramatically between trials, or change the results of other trials
 - Run reasonably quickly - some code takes longer to run than others so the exact number of iterations you should use may vary, but try to have each complete in less than a second or so

Feel free to use this to benchmark other extensions or libraries, but I won't be merging in any changes that bring in anything external.

### Charts

I'll probably add a few more data visualizations to the UI eventually. For now, if you want to add your own, have a look at `obj_main::DrawPieChart()` to see how that one's drawn.

`shd_dither` is a useful shader for dithering a 2D colored primitive.

## GameMaker version

This should work on GMS2023.2 or later. It might work on earlier versions back to 2022.11, haven't tried. I use a few features added in 2022.11 so it won't work in anything earlier than that.

## Credits

The UI is based on [Emu](https://dragonite.itch.io/emu), which I made, which in turn uses Juju's [Scribble 8.0.1b1](https://github.com/JujuAdams/Scribble) to render text in the UI. There isn't anyting else that's very exciting in here.
