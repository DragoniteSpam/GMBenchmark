# GMBenchmark

Hi, I made a tool for benchmarking code in [GameMaker](https://gamemaker.io/en).

![image](https://github.com/DragoniteSpam/GMBenchmark/assets/7087495/57b86e45-bb51-4dc6-9a14-adc351a13b6a)

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

If your tests require any additional setup you can also pass an `init` function to the TestCase constructor. The `init` function also takes the iteration count in case you need that for setup. The `init` function will not be counted towards the benchmark time.

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
    ]),
    #endregion

## Data

You can decide how many trials of how many iterations you want to run in the tool's GUI. I recommend having at least 4 or 5 trials. Trials will be interleaved. The number of iterations you should use will vary depending on how expensive the code you're benchmarking is. The Suggest Iterations button will run a brief trial of the benchmark and try to extrapolate how many iterations you can reasonably expect to give a useful result. **This will not work well for benchmarking algorithms that scale in non-linear time, particularly in tests where you use the iteration value as the size of the data set.**

You can view the results as a bar chart or a pie chart. The bar chart also allows you to show the raw timings, the timings relative to the best performer, and the average number of times you'll be able to run a single iteration per millisecond.

## Command line benchmarks

If you just wanna see results without clicking on a bunch of stuff, you can use some command line arguments.

You can pass command line arguments as:

- a name of a benchmark (use a quoted string if the name contains spaces) (this behaves correctly in Windows PowerShell, not sure about other terminals)
- `-trials` or -iter followed by a number to set the trial and iteration count of the previous benchmark (defaults to 4 and 100,000 if not specified, the same as in the GUI)
- `-file` followed by the name of the file to output; if the file is a .csv it’ll output a spreadsheet like the one you can export through the GUI, otherwise it’ll output a text file with the results written out in a list
- `-dontkill`, if you don’t want the GUI to immediately close if it outputs results; the benchmarks that you ran through the command line will have their results shown in the list

For example:

    GMBenchmark.exe "Fast inverse square root" -trials 5 -file "results.txt" "Math Functions" "Fast Loops"

will run `Fast inverse square root` with 5 trials, and `Math Functions` and `Fast Loops` with 4 trials, and output the results to `results.txt`.

<img width="1115" height="628" alt="image" src="https://github.com/user-attachments/assets/e891680d-1b7e-4093-9b2b-4fe90ab15265" />

The GameMaker IDE currently doesn’t support command line arguments, so if you want to emulate this behavior through the IDE, go down to the bottom of the file GM_Benchmark and edit the ide_cmd_args array with the same arguments as if they were command line arguments.

    var ide_cmd_args = [
        "Fast inverse square root", "-trials", 5,
        "-dontkill", "-file", "C:/Users/drago/results.txt",
        "Math Functions", "Fast Loops"
    ];

## Disclaimers, Context, and Best Practices

 - Unless you flush the draw pipeline, this will only count what happens on the CPU. Benchmarking the submitting of large vertex buffers or very weak hardware (mobile, etc) won't show very accurate results unless you flush the draw pipeline first. Calling `draw_flush()` is probably the easiest way to do that.
 - **Small or individual operations,** eg math functions, that rank within about 5% of each other are highly subject to random noise and will generally be equivalent in the real world. This is not necessarily true of larger procedures or algortithms, as code that takes longer to run has more time to smooth out the noise and the runtime is usually more consistent.
 - Benchmarks that take less than about a millisecond or so probably won't be very reliable because at that point random fluctuations from other things happening on your computer will start to become significant. You should probably increase the iteration count.
 - As of 2024.11, if there's a runtime function that does the same thing as your code, the runtime function will win if your implementation is more than about **three arithmetic operations** in VM and about **six arithmetic operations** in YYC. This figure has evolved as both VM and YYC have continued to be developed and is likely to change in GMRT.
 - Context matters: a 40 ms operation in the Room Start event is much less offensive than a 5 ms operation in the Step event.
 - Don't be awful to people who you see writing "slow" code, because god knows the GameMaker community has a problem with this.
 - Don't be awful to YYG for GML execution speed being slow, either. They already have to deal with me.
 - GameMaker is (mostly) single-threaded, and therefore so is your code, so single-core CPU performance matters more than anything else. GameMaker will see a much bigger difference going from a Core i3-7100 to a Core i3-13100 than there will be going from a Core i3-13100 to a Ryzen 9 7950X, despite the 7950X having a 4x higher thread count than the 13100.
 - In terms of making your game run fast, reducing the algorithmic complexity is infinitely more important than whatever some angry loser in a Usenet archive from 1991 has to say. Both [x86](https://c9x.me/x86/html/file_module_x86_id_116.html) and [ARM](https://developer.arm.com/documentation/ddi0406/c/Application-Level-Architecture/Instruction-Details/Alphabetical-list-of-instructions/VSQRT) chips have had hardware routines for things like square root for many years now. The obsession with never doing trig, multiplying by 0.5 instead of dividing by 2, and using Manhattan distance squared instead of point_distance seriously needs to die. Please stop making your own code worse based on information hasn't been relevant since the days of the Soviet Union. **See the first two tests for Quake's fast inverse square root, and other math functions.**

## Contributing

### Tests

If anyone has any fun benchmarks they want to add, I'll merge them in. Your own benchmarks should:
 - Run consistently - don't do anything that would cause the results to change dramatically between trials, or change the results of other trials
 - Run reasonably quickly - some code takes longer to run than others so the exact number of iterations you should use may vary, but try to have each complete in less than a second or so
 - Avoid using this to test algorithms with runtimes of N squared or higher. Depending on the inputs and iteration count, these can take obnoxiously long to complete and the program could hang.

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
