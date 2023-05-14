# GMBenchmark

Hi, I made a tool for benchmarking code in [GameMaker](https://gamemaker.io/en).

## Using it

Clone the repository, open the GameMaker project, and run it. You'll see a pretty little UI and some data relating to the performance of different bits of code.

To add your own tests, go into the `GM_Benchmarks` and edit (or add to) the list of items in the `Benchmarks` array.

A `Benchmark` object is a constructor which takes a name as a string, and an array of `TestCase` instances.

A `TestCase` object is a constructor which takes a name as a string, and a function containing the code you want to time. The function will accept a number of iterations for it to be run.

For example:

    #region variable access
    new Benchmark("Variable access", [
        new TestCase("dot operator", function(iterations) {
            var struct = { x: 0 };
            repeat (iterations) {
                var val = struct.x;
            }
        }),
        new TestCase("struct accessor", function(iterations) {
            var struct = { x: 0 };
            repeat (iterations) {
                var val = struct[$ "x"];
            }
        }), new TestCase("variable hash", function(iterations) {
            var struct = { x: 0 };
            var hash = variable_get_hash("x");
            repeat (iterations) {
                var val = struct_get_from_hash(struct, hash);
            }
        })
    ]),
    #endregion

If your tests require any additional setup you can also pass an `init` function to the TestCase constructor. The `init` function also takes the iteration count in case you need that for setup.

    #region loop iterations
    new Benchmark("Fast Loops", [
        new TestCase("for over array size", function(iterations) {
            var test_array = self.test_array;
            for (var i = 0; i < array_length(test_array); i++) {
                var val = test_array[i];
            }
        }, function(iterations) {
            self.test_array = array_create(iterations);
        }),
        
        new TestCase("for over cached array size", function(iterations) {
            var test_array = self.test_array;
            for (var i = 0, n = array_length(test_array); i < n; i++) {
                var val = test_array[i];
            }
        }, function(iterations) {
            self.test_array = array_create(iterations);
        }),
        
        new TestCase("repeat over array", function(iterations) {
            var test_array = self.test_array;
            var i = 0;
            repeat (array_length(test_array)) {
                var val = test_array[i];
                i++;
            }
        }, function(iterations) {
            self.test_array = array_create(iterations);
        }),
    #endregion
    

![image](https://user-images.githubusercontent.com/7087495/232585003-00a37367-fc97-4250-b349-f0774bf216b9.png)

## Data

You can decide how many trials of how many iterations you want to run in the tool's GUI. I recommend having at least 4 or 5 trials. The number of iterations you should use will vary depending on how expensive the code you're benchmarking is. The Suggest Iterations button will run a brief trial of the benchmark and try to extrapolate how many iterations you can reasonably expect to give a useful result. **This will not work well for benchmarking algorithms that scale in non-linear time, particularly in tests where you use the iteration value as the size of the data set.**

You can view the results as a bar chart or a pie chart. The bar chart also allows you to show the raw timings, the timings relative to the best performer, and the average number of times you'll be able to run a single iteration per millisecond.

## Contributing

### Tests

If anyone has any fun benchmarks they want to add, I'll merge them in. Your own benchmarks should:
 - Run consistently - don't do anything that would cause the results to change dramatically between trials, or change the results of other trials
 - Run reasonably quickly - some code takes longer to run than others so the exact number of iterations you should use may vary, but try to have each complete in less than a second or so

Feel free to use this to benchmark other extensions or libraries, but I won't be merging in any changes that bring in anything external.

### Charts

If you're bored you can add some other chart types, but the bar chart and pie chart are probably the main ones you'd want. Have a look at `obj_main::DrawPieChart()` to see how that one's drawn.

`shd_dither` is a useful shader for dithering a 2D colored primitive.

## GameMaker version

This should work on GMS2023.4 or later. It might work on earlier versions back to 2022.11, haven't tried. I use a few features added in 2022.11 so it won't work in anything earlier than that.

### To do

Whenever I have other work that I don't feel like doing, I'll probably add:

 - An Export Results button

## Credits

The UI is based on [Emu](https://dragonite.itch.io/emu), which I made, which in turn uses Juju's [Scribble 8.0.1b1](https://github.com/JujuAdams/Scribble) to render text in the UI. There isn't anyting else that's very exciting in here.
