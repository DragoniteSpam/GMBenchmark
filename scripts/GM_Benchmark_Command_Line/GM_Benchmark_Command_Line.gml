function deal_with_cmd_args(args) {
    var results = "";
    var kill = true;
    var n = array_length(args);
    
    var tests = [];
    
    for (var i = 0; i < n; i++) {
        switch (args[i]) {
            case "-file":
                if (i < n - 1) {
                    results = args[i + 1];
                }
                break;
            case "-dontkill":
                kill = false;
                break;
            
            case "-trials":
                if (array_length(tests) > 0 && i < n - 1) {
                    array_last(tests).trials = real(args[i + 1]);
                }
                break;
            case "-iter":
                if (array_length(tests) > 0 && i < n - 1) {
                    array_last(tests).iterations = real(args[i + 1]);
                }
                break;
            
            default:
                for (var j = 0; j < array_length(Benchmarks); j++) {
                    if (Benchmarks[j].source_name == args[i]) {
                        array_push(tests, {
                            benchmark: Benchmarks[j],
                            trials: 4,
                            iterations: 100_000
                        });
                    }
                }
                break;
        }
    }
    
    if (array_length(tests) > 0) {
        array_foreach(tests, function(test) {
            test.benchmark.Run(test.trials, test.iterations);
        });
        
        if (kill) {
            game_end();
        }
    }
}